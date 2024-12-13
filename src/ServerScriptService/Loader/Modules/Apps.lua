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
	AppMeta: table | nil
): table
	Utils.Logging.Print(`[-] Loading app from source {(typeof(Path) == "Instance" and Path:GetFullName() or Path)}`)

	local AppConfig, TargetApp, StartTick =  require(Path).Init(), nil, tick()
	AppConfig.AppContent.Parent = script.Parent.Parent.LocalApps

	repeat
		xpcall(function() TargetApp = require(script.AppAPI).AllApps[AppConfig.AppName] end, function() end)
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
end

function App.Initialize()
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

--// Marketplace functions
function ServerAPI.GetList(SpecificServer)
	local FullList = {}
	local Raw

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
): table
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
		Utils.Logging.Warn(`Failed to connect to the app server, is it running? (statuscode {SC}`)

		return {false, "Something unexpected happened, please check logs."}
	end)
end

function ServerAPI.GetApp(
	Player: Player,
	AppServer: string,
	AppID: number
): table
	HTTP.GetRoute(AppServer, `/app/{AppID}`, function(Content)
		return Content
	end, function(SC)
		return {
			["Error"] = "Something went wrong, try again later.", 
			["Message"] = Content
		}
	end)
end