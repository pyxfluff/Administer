--// pyxfluff 2024

--// Initialization
local App = {}
local ServerAPI = {}

--// Dependencies
local Utils = require(script.Parent.Utilities)
local Var = require(script.Parent.Parent.Core.Variables)
local Config = require(script.Parent.Parent.Core.Configuration)
local HTTP = require(script.Parent.HTTPRunner)

--// Core App functions
function App.LoadLocal(
	Path: Instance | number,
	AppMeta: {InstallDate: number, InstallSource: string, AppID: number}
): {boolean | string}
	Utils.Logging.Print(`[-] Loading app from source {(typeof(Path) == "Instance" and Path:GetFullName() or Path)}`)

	local AppConfig, TargetApp, StartTick =  require(Path).Init(), nil, tick()
	AppConfig.AppContent.Parent = script.Parent.Parent.LocalApps

	repeat
		xpcall(function() TargetApp = require(script.Parent.AppAPI).AllApps[AppConfig.AppName] end, function() end)
	until TargetApp ~= nil

	xpcall(function()
		TargetApp.BuildTime = string.sub(tostring(tick() - StartTick), 1, 5)
		TargetApp.PrivateAppDesc = AppConfig.Description
		TargetApp.InstalledSince = AppMeta.InstallDate
		TargetApp.InstallSource = AppMeta.InstallSource
		TargetApp.Version = AppConfig.Version or "v0"
		TargetApp.AppID = (typeof(Path) == "number") and Path or AppMeta.AppID

		Utils.Logging.Print(`[✓] App bootstrap OK in {string.sub(tostring(tick() - StartTick), 1, 6)}s`)
	end, function(e)
		Utils.Logging.Error(`[X] Failed bootstrapping app: {e}`)
	end)

	return {true, "OK"}
end

function App.Initialize(): boolean
	local DelaySetting, Apps = Utils.GetSetting("AppLoadDelay"), Var.DataStores.AppDB:GetAsync("AppList") or {}
	local AppsCount, i, TotalAttempts, Start = #Apps, 0, 0, tick()
	
	Utils.Logging.Print("Bootstrapping apps...")

	if Utils.GetSetting("DisableApps") then
		Utils.Logging.Print(`App Bootstrapping disabled due to configuration, please disable!`)
		return false
	end

	if DelaySetting == "InStudio" and Var.Services.RunService:IsStudio() then
		task.wait(3)
	elseif DelaySetting == "All" then
		task.wait(3)
	end
	
	for i, App in script.Parent.Parent.LocalApps:GetChildren() do
		table.insert(Apps, {
			ID = App,
			InstallDate = 0,
			InstallSource = ""
		})
	end

	for _, AppObj in Apps do
		task.defer(function()
			App.LoadLocal(
				AppObj.ID,
				{
					InstallDate = AppObj.InstallDate,
					InstallSource = AppObj.InstallSource,
					AppID = AppObj.ID
				}
			)
		end)
	end

	repeat 
		task.wait(.05) 
		TotalAttempts += 1
	until i == AppsCount or TotalAttempts == 50

	if TotalAttempts == 50 then
		Utils.Logging.Warn(`[{Config.Name}]: Failed to initialize some apps after the polling limit! Try looking for faulty apps ({i/AppsCount}% of {AppsCount} cloud apps loaded in {TotalAttempts} tries/{tick() - Start}s).`)
	end

	Var.DidBootstrap = true

	return true
end

function App.Uninstall(
	AppID: number
): {boolean | string}
	local Apps = Var.DataStores.AppDB:GetAsync("AppList")
	Utils.Logging.Warn(`Removing app {AppID}`)

	for i, App in Apps do
		if App["ID"] == AppID then
			Utils.Logging.Print("Successfully uninstalled", App)
			Apps[i] = nil
		end
	end

	Var.DataStores.AppDB:SetAsync("AppList", Apps)
	return {true, "OK"}
end

function App.GetAll(
	Source: string
): {boolean | string}
	if Source == nil or Source == "Bootstrapped" then
		return require(script.Parent.AppAPI).AllApps
	elseif Source == "DataStore_Raw" then
		return Var.DataStores.AppDB:GetAsync("AppList")
	elseif Source == "Combined" then
		local AppList = Var.DataStores.AppDB:GetAsync("AppList")
		local Final = {}

		for i, Object in AppList do
			Object["ObjSource"] = "DataStore"
			table.insert(Final, Object)
		end

		for i, Object in require(script.Parent.AppAPI).AllApps do
			Object["ObjSource"] = "AppAPI"
			table.insert(Final, Object)
		end

		return Final
	end

	return {false, "No data"}
end

function App.Install(
	AppID: number,
	InstallContext: string,
	AppName: string
): {boolean | string}
	--// NEW: Now we run the app in this server to test it. Putting here so I don't forget for the 2.0 logs.
	Utils.Logging.Print(`[-] Attempting to load app`)
	local _, res = xpcall(function()
		App.LoadLocal(AppID, {
			["InstallDate"] = os.time(),
			["InstallSource"] = InstallContext,
			["AppID"] = AppID
		})
	end, function(e)
		Utils.Logging.Warn("[x] This does not seem to be an Administer app or the initial build failed.")
		return {false, "This app isn't valid, check the log."}
	end)

	if res[1] == false then return res end
	Utils.Logging.Print(`[✓] App bootstrap OK, installing!`)

	local AppList = Var.DataStores.AppDB:GetAsync("AppList")
	for i, App in AppList do
		if App["ID"] == AppID then
			Utils.Logging.Warn("[x] Not continuing because this app is a duplicate!")
			return {false, "This app is a duplicate."}
		end
	end

	table.insert(AppList, {
		["ID"] = AppID,
		["InstallDate"] = os.time(),
		["InstallSource"] = InstallContext or "Manual ID install",
		["Name"] = AppName ~= nil and AppName or "Unknown" --// surely wont cause any issues
	})

	Var.DataStores.AppDB:SetAsync("AppList", AppList)
	return {true, "Successfully installed and executed an app!"}
end

--// Marketplace functions
function ServerAPI.GetList(
	SpecificServer: string
): {}
	local FullList = {}

	if Utils.GetSetting("DisableAppServerFetch") == true then
		Utils.Logging.Print("App server call ignored due to configuration.")
		return {}
	end

	for i, Server in (SpecificServer ~= nil and {SpecificServer} or Var.DataStores.AppDB:GetAsync("AppServerList")) do
		HTTP.GetRoute(Server, "list", function(Apps, ResponseData)
			for i, v in Apps do
				v["AppServer"] = Server

				table.insert(FullList, v)
			end
		end, function(sc) return {false, `Failed to fetch apps: {sc}`} end)
	end

	return FullList
end

function ServerAPI.New(
	URL: string
): {boolean | string}
	Utils.Logging.Print("Installing app server...")
	HTTP.GetRoute(URL, "/.administer/server", function(Data, Info)
		if Data["server"] ~= "AdministerAppServer" then
			Utils.Logging.Warn("This URL doesn't seem to be an Administer app server.")
			return {false, "This is not a valid Administer app server."}
		end

		Utils.Logging.Print("This server is valid!")
		Var.DataStores.AppDB:SetAsync("AppServerList", table.insert((Var.DataStores.AppDB:GetAsync("AppServerList") or {}), URL))

		return {true, "Done!"}
	end, function(SC)
		Utils.Logging.Warn(`Failed to connect to the app server, is it running? (statuscode {SC})`)

		return {false, "Something unexpected happened, please check logs."}
	end)

	return {false, "HTTP failed"}
end

function ServerAPI.GetApp(
	Player: Player,
	AppServer: string,
	AppID: number
): {boolean | string}
	HTTP.GetRoute(AppServer, `/app/{AppID}`, function(Content)
		return Content
	end, function(SC)
		return {
			["Error"] = "Something went wrong, try again later.", 
			["Message"] = Content
		}
	end)
	
	return {false, "HTTP failed"}
end

function ServerAPI.InstallFromServer(
	AppID: number,
	ServerURL: string
): {boolean | string}
	HTTP.GetRoute(ServerURL, `/app/{AppID}`, function(Content)
		local RealID = Content["AppInstallID"]
		if RealID == 0 then
			return {false, "This server gave us bad data, please report the error to the server owner."}
		end

		local Result = App.Install(RealID, ServerURL, Content["AppName"])

		if Result[1] then
			HTTP.PostRoute(ServerURL, `/install/{AppID}`, {}, function()
				return {true, "Successfully installed!"}
			end, function()
				return {false, "We couldn't tell the app server about that properly, please try again later."}
			end)

			return {false, "????"}
		else
			Utils.Logging.Warn("Server did not install with an OK status code, ignoring request to tell the server.")
			return {false, Result}
		end
	end, function(c)
		return {false, `Something went wrong (code {c}), please try again later.`}
	end)

	return {false, "i hate strict typing!"}
end