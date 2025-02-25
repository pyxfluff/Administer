--// Administer
--// pyxfluff 2024 - 2025

--// This file exists to stop circular imports

local Root = script:FindFirstAncestor("Loader")
local Admins = require(Root.Modules.AdminRunner)
local Apps = require(Root.Modules.Apps)
local Utils = require(Root.Modules.Utilities)
local Var = require(Root.Core.Variables)

return function(): ()
	Utils.Logging.Print("[-] Performing first-time setup...")

	Var.IsFirstBoot = true

	--// Make default Admin rank
	Admins.Ranks.New({
		Name = "Administrator",
		Protected = true,
		Members = {
			Utils.GetGameOwner(true),
		},

		AllowedApps = {
			SuperAdmin = true,
		},

		CreationReason = "Added by System for first-time setup.",
		ActingUser = 1,
	})

	Apps.ServerAPI.New(Var.DefaultAppServer)
	Apps.ServerAPI.InstallFromServer(
		Var.DefaultAppServer, --// Assuming this is (hopefully) AOS
		1
	)

	Utils.Logging.Print("[✓] Welcome to Administer!")
end
