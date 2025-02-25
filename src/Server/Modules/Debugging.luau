--// Administer
--// pyxfluff 2024 - 2025

local Debugging = {}

local Root = script:FindFirstAncestor("Loader")
local AdminRunner = require(Root.Modules.AdminRunner)
local Var = require(Root.Core.Variables)

Debugging.text = [[
///// ADMINISTER DEBUG OUTPUT \\\\\

* VERSION: 1.0
* GENERATION TIMESTAMP: 1727997091
* GENERATION TIME: 5.000000000s
* SUBMITTED TO APP SERVER: YES

// ENVIORNMENT \\

* LOCATION: RobloxStudio
* IDENTITY: 4
* ROBLOX VERSION: 0.642.0.6420636
* GAME: https://www.roblox.com/games/8787038683
* PLACEID: 8787038683
* HTTP ENABLED: YES
* STUDIO APIS ENABLED: YES
* UPTIME: 38548563.324873842s

// ADMINISTER \\

* VERSION: 1.0.1
* APP API VERSION: 1.0.0
* BRANCH: STABLE
* UP TO DATE: YES (check time: 1727997091)
* DB INITIALIZED: 1727997091
* SERVER ERRORS 0
* SERVER WARNINGS: 0
* SERVER ERROR LOG: []
* VERBOSE LOGS: 0
* INIT TIME: 4.7375452518463135s
* INIT JSON: {"FunctionDefinition":"0.0017399","RegisterStartupEvents":"0.7171185","Services":"0.0000703","AppsBootstrap":"3.3675901","Constants":"0.0000147","DataStoreService":"0.5957047","ConstructRemotes":"0.4938125","BootstrapAdmins":"0.4935016","FullExecute":4.737712383270264}


// APPS \\

* APPS INSTALLED: 3
* LOCAL APPS INSTALLED: 0
* DISABLED APPS: 0
* ENABLED APPS: [{"ID":18116194237,"InstallSource":"https://administer.notpyx.me","InstallDate":1727125991,"Name":"Moderation+"},null,{"ID":104329212775273,"InstallSource":"https://administer.notpyx.me","InstallDate":1727637186,"Name":"Team Manager"},{"ID":89624237695477,"InstallSource":"https://administer.notpyx.me","InstallDate":1727641979,"Name":"Global Announcements"},{"ID":116009468305526,"InstallSource":"https://administer.notpyx.me","InstallDate":1727899707,"Name":"Player Management"}]
* ERRORS IN INIT: YES (1 FAILED)
* INIT TIME: 2.435835982435
* SERVER COUNT: 1
* SERVERS: [{"URL": "https://administer.notpyx.me", "Source": "_setup", "Timestamp": "0000"}]

// ADMINS \\

* TOTAL RANKS: 8
* TOTAL ADMINS: 82
* DOES USE LEGACY MODULE: YES

// CONFIGURATION \\

{"ShortNumberDecimals":{"Name":"ShortNumberDecimals","Value":2},"DisplayHours":{"Name":"DisplayHours","Value":false},"SettingsCheckTime":{"Name":"SettingsCheckTime","Value":30},"AppLoadDelay":{"Name":"AppLoadDelay","Value":"None"},"NotificationCloseTimer":{"Name":"NotificationCloseTimer","Value":15},"PanelKeybind":{"Name":"PanelKeybind","Value":"Z"},"AnimationSpeed":{"Name":"AnimationSpeed","Value":1},"SandboxMode":{"Name":"SandboxMode","Value":true},"Verbose":{"Name":"Verbose","Value":true},"RequireShift":{"Name":"RequireShift","Value":true},"HomepageGreeting":{"Name":"HomepageGreeting","Value":"Welcome to Administer!"},"DisableAppServerFetch":{"Name":"DisableAppServerFetch","Value":false},"TopbarPlus":{"Name":"TopbarPlus","Value":false},"EditableImageRenderingDelay":{"Name":"EditableImageRenderingDelay","Value":false},"EnableEditableImages":{"Name":"EnableEditableImages","Value":true},"AdminCheck":{"Name":"AdminCheck","Value":120},"DisableUnofficialAppWarning":{"Name":"DisableUnofficialAppWarning","Value":false},"DisableApps":{"Name":"DisableApps","Value":false}}

]]

Debugging.Table = {
	["AdministerEnv"] = {
		["Version"] = "1.2",
		["AppAPIVersion"] = "1.0",
		["Branch"] = "LIVE",

		["ParentedTo"] = "game.ServerScriptService",
		["GeneratedAt"] = os.time(),
		["GenerationTime"] = "2.0000000s",
		["Location"] = "RobloxStudio",

		["RobloxVersion"] = "0.642.0.6420636",
		["GameURL"] = "https://www.roblox.com/games/8787038683",
		["PlaceID"] = "8787038683",
	},

	["Permissions"] = {
		["HttpEnabled"] = true,
		["ConnectedToAPIs"] = true,
		["AOSDidPing"] = true,
	},
}

function Debugging.SocketMessage(Msg)
	local Data = Msg["Data"]

	if Data["Message"] == "ForceAdminCheck" then
		for i, Player in Var.Services.Players:GetPlayers() do
			AdminRunner.PlayerAdded(Player, false, false)
		end
	end
end

return Debugging
