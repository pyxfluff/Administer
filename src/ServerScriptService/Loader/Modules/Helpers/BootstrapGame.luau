--// Administer 
--// (pyxfluff + FloofyPlasma) 2024 - 2025

--// This file exists to stop circular imports

local Var = require(script.Parent.Parent.Parent.Core.Variables)
local Admins = require(script.Parent.Parent.AdminRunner)
local Apps = require(script.Parent.Parent.Apps)
local Utils = require(script.Parent.Parent.Utilities)

return function(): ()
	Utils.Logging.Print("[-] Performing first-time setup...")

	Var.IsFirstBoot = true

	--// Make default Admin rank
	Admins.Ranks.New({
		Name = "Administrator",
		Protected = true,
		Members = {
			Utils.GetGameOwner(true)
		},

		AllowedApps = {
			SuperAdmin = true
		},

		CreationReason = "Added by System for first-time setup.",
		ActingUser = 1
	})

	Apps.ServerAPI.New(Var.DefaultAppServer)
	Apps.ServerAPI.InstallFromServer(
		Var.DefaultAppServer, --// Assuming this is (hopefully) AOS
		1
	)

	Utils.Logging.Print("[✓] Welcome to Administer!")
end
