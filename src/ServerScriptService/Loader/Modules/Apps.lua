--// pyxfluff 2024

--// Initialization
local App = {}

--// Dependencies
local Utils = require(script.Parent.Utilities)
local Var = require(script.Parent.Parent.Core.Variables)
local Config = require(script.Parent.Parent.Core.Configuration)
local HTTP = require(script.Parent.HTTPRunner)

function App.Initialize() --// TODO: Refactor
	Utils.Logging.Print("Bootstrapping apps...")

	if Utils.GetSetting("DisableApps") then
		Utils.Logging.Print(`App Bootstrapping disabled due to configuration, please disable!`)
		return false
	end

	local DelaySetting = Utils.GetSetting("AppLoadDelay")

	if DelaySetting == "InStudio" and Var.Services.RunService:IsStudio() then
		task.wait(3)
	elseif DelaySetting == "All" then
		task.wait(3)
	end

	local Apps = Var.DataStores.AppDB:GetAsync("AppList")

	if Apps == nil then
		--Print(`Bootstrapping apps failed because the App list was nil! This is either a Roblox issue or you have no Apps installed!`)
		Var.DidBootstrap = true
		return false
	end

	local AppsCount, i, TotalAttempts, Start = #Apps, 0, 0, tick()

	for _, AppObj in Apps do
		local _t = tick()
		task.spawn(function()
			local Success, Error = pcall(function()
				local App

				xpcall(function()
					App = require(AppObj["ID"])
				end, function(e)
					Utils.Logging.Warn(`[{Config.Name}]: Failed to require {AppObj["Name"]} ({e})! Please ensure it is public.`)
					Utils.Logging.Error("Failed to fetch an app, please check the log!")
				end)

				local AppName, PrivateDescription, Version = App.Init()
				local _a = 0

				repeat --// this waits until the app is initialized and put into AllApps by the RuntimeAPI
					task.wait()
					local _s, _e = xpcall(function() --// init metadata
						require(script.AppAPI).AllApps[AppName]["BuildTime"] = string.sub(tostring(tick() - _t), 1, 5)
						require(script.AppAPI).AllApps[AppName]["PrivateAppDesc"] = PrivateDescription
						require(script.AppAPI).AllApps[AppName]["InstalledSince"] = AppObj["InstallDate"]
						require(script.AppAPI).AllApps[AppName]["InstallSource"] = AppObj["InstallSource"]
						require(script.AppAPI).AllApps[AppName]["Version"] = Version or "v0"
						require(script.AppAPI).AllApps[AppName]["AppID"] = AppObj["ID"]
					end, function(er)
						Utils.Logging.Print(`Failed to load {AppName}, retrying soon! {er}`)
						task.wait(.05)
					end)
					_a += 1
				until _s or _a >= 50

				if _a == 50 then
					warn(`[{Config.Name}]: Failed to init metadata for {AppObj["Name"]} after 50 tries (limit reached)!`)
				end
			end)

			if not Success then
				i += 1
				warn(`[{Config.Name}]: Failed to App.Init() on {AppObj["Name"]} ({Error})! If this is your app, please verify your main module's init call according to the docs.`)
			else
				i += 1
			end
		end)
	end

	repeat 
		task.wait(.1) 
		TotalAttempts += 1
	until i == AppsCount or TotalAttempts == 10

	if TotalAttempts == 10 then
		Utils.Logging.Warn(`[{Config.Name}]: Failed to initialize some apps after the polling limit! Try looking for faulty apps ({i/AppsCount}% of {AppsCount} cloud apps loaded in {TotalAttempts} tries/{tick() - Start}s).`)
	end

	Var.DidBootstrap = true

	return true
end

--// Marketplace functions
function App.GetMarketplaceList(SpecificServer)
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


