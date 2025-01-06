--// # Administer #

--// PyxFluff & FloofyPlasma 2022-2025

--// https://github.com/pyxfluff/Administer

--// The following code is free to use, look at, and modify. 
--// Please refrain from modifying core functions as it can break everything.
--// All modifications can be done via apps.

--// WARNING: Use of Administer's codebase for AI training is STRICTLY PROHIBITED and you will face consequences if you do it.
--// Do NOT use this script or any in this model to train your AI or else.

local Core = script.Core
local Modules = script.Modules

local Configuration = require(Core.Configuration)
local Var           = require(Core.Variables)
local AdminRunner   = require(Modules.AdminRunner)
local AppsModule    = require(Modules.Apps)
local Debugging     = require(Modules.Debugging)
local FrontendAPI   = require(Modules.Frontend)
local SettingsAPI   = require(Modules.Settings)
local Utils         = require(Modules.Utilities)

print(`[✓] Modules OK in {os.clock() - Var.InitClock["RealInit"]}s`)

Var.InitClock.TempInit = os.clock()
Var.Init()

print(`[✓] Init() OK in {os.clock() - Var.InitClock["TempInit"]}s`)

Var.InitClock.TempInit = os.clock()
xpcall(function()
	Var.DataStores.AppDB:GetAsync("AdministerConnectionTest")

	print(`[✓] DataStore connection established in {os.clock() - Var.InitClock["TempInit"]}s`)
end, function()
	error(`[X] Administer cannot connect to the DataStoreService. Please ensure Studio APIs are enabled and try again.`)
end)

Var.InitClock.TempInit = os.clock()
AppsModule.Initialize()

print(`[✓] OK in {os.clock() - Var.InitClock["TempInit"]}s`)

Var.Services.Players.PlayerAdded:Connect(AdminRunner.PlayerAdded)

print("[-] Mounting frontend API..")
local function NewRemote(Name, AuthRequired, Cbk)
	return Utils.NewRemote("RemoteFunction", Name, AuthRequired, Cbk)
end

NewRemote("Ping", false, function(Player)
	return "PONG"
end)

--// Translation routes
NewRemote("GetTranslationModule", true, function(Player, Locale)
	return require(script.Core.Locales[Locale])
end)

NewRemote("SendClientLocale", true, function(Player, LocaleCode)
	Var.CachedLocales[Player.UserId] = LocaleCode

	return {true, "OK"}
end)

NewRemote("DirectTranslate", true, function(Player, Key)
	return Utils.t(Player, Key)
end)

--// Utilities
NewRemote("CheckForUpdates", true, function(Player)
	return FrontendAPI.VersionCheck(Player)
end)

--// Admin routes

NewRemote("")