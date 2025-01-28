--// # Administer #
--// (pyxfluff + FloofyPlasma) 2024 - 2025

--// https://github.com/pyxfluff/Administer

--// The following code is free to use, look at, and modify. 
--// Please refrain from modifying core functions as it can break everything.
--// All modifications can be done via apps.

--// WARNING: Use of Administer's codebase for AI training is STRICTLY PROHIBITED and you will face consequences if you do it.
--// Do NOT use this script or any in this model to train your AI or else.
-- stylua: ignore start

local Core           = script.Core
local Modules        = script.Modules

local AdminRunner    = require(Modules.AdminRunner)
local AppsModule     = require(Modules.Apps)
local _Debugging     = require(Modules.Debugging)
local FrontendAPI    = require(Modules.Frontend)
local HttpRunner     = require(Modules.HTTPRunner)
local _SettingsAPI   = require(Modules.SettingsAPI)
local Utils          = require(Modules.Utilities)

local Configuration  = require(Core.Configuration)
local Types          = require(Core.Types)
local Var            = require(Core.Variables)

-- stylua: ignore end

Utils.Logging.Print(`[✓] Modules OK in {os.clock() - Var.InitClock["RealInit"]}s`)

Var.InitClock.TempInit = os.clock()
Var.Init()

Utils.Logging.Print(`[✓] Init() OK in {os.clock() - Var.InitClock["TempInit"]}s`)

Var.InitClock.TempInit = os.clock()
xpcall(function()
	Var.IsFirstBoot = Var.DataStores.Settings:GetAsync("HasInit") == nil and true or false

	Utils.Logging.Print(`[✓] DataStoreService connection established in {os.clock() - Var.InitClock["TempInit"]}s`)

	if Var.IsFirstBoot then
		require(script.Modules.Helpers.BootstrapGame)()

		--// This system is better than the old one because it allows the user
		--// to uninstall AOS without causing the system to overwrite stuff
		Var.DataStores.Settings:SetAsync("HasInit", true)
	end

	--// Now load settings
	--SettingsAPI(Configuration.Settings)
end, function(e)
	Utils.Logging.Warn(e)
	Utils.Logging.Error(
		`[X] Cannot connect to the DataStoreService. Please ensure Studio APIs are enabled and try again.`
	)
end)

Var.InitClock.TempInit = os.clock()
AppsModule.Initialize()

Utils.Logging.Print(`[✓] OK in {os.clock() - Var.InitClock["TempInit"]}s`)

AdminRunner.Scan(false)
Var.Services.Players.PlayerAdded:Connect(AdminRunner.PlayerAdded)

Utils.Logging.Print("[-] Mounting frontend API..")
Var.InitClock.TempInit = os.clock()

local function NewRemote(Name: string, AuthRequired: boolean, Cbk: (Player, ...any) -> any)
	return Utils.NewRemote("RemoteFunction", Name, AuthRequired, function(Player: Player, ...)
		return Cbk(Player, ...)
	end)
end

NewRemote("Ping", false, function(Player)
	return "PONG"
end)

--// Translation routes
NewRemote("GetTranslationModule", true, function(Player, Locale)
	return require(script.Core.Locales[Locale]) :: any
end)

NewRemote("SendClientLocale", true, function(Player, LocaleCode): Types.Response
	Var.CachedLocales[Player.UserId] = LocaleCode

	return { true, "OK" }
end)

NewRemote("DirectTranslate", true, function(Player, Key)
	return Utils.t(Player, Key)
end)

--// Utilities
NewRemote("CheckForUpdates", true, function(Player)
	return FrontendAPI.VersionCheck(Player)
end)

--// Admin routes

Utils.Logging.Print(`[✓] OK in {os.clock() - Var.InitClock["TempInit"]}s`)

Utils.Logging.Print(`[-] Running startup jobs!`)

HttpRunner.PostRoute(Var.DefaultAppServer, "/api/report-version", {
	version = Configuration.VersData.NoExtraData,
	branch = Var.CurrentBranch["BranchName"],
}, function(A, B)
    print(A, B)
	return {}
end, function(A, B)
    print(A, B)
	return {}
end)
