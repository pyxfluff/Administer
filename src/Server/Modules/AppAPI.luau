--// Administer
--// (pyxfluff + FloofyPlasma) 2024

local App = {
	APIVersion = "2.0",
	Apps = {},
}

local Administer = nil

--// Modules
local Types = require(script.Parent.Parent.Core.Types)

---------------------------------

-- Creates a new app for use in Administer. For more information, please refer to the documentation.
return function(
    Configuration: Types.RichConfig
): () 
	repeat
		task.wait()
	until Administer

	local Events = Instance.new("Folder")
	Events.Name = AppButton["Name"]
	Events.Parent = game.ReplicatedStorage.AdministerApps

	local BuiltAPI = {
		CreateBlip = function(Player: Player, Count: number): { boolean | string }
			local AdministerPanel = Player.PlayerGui:FindFirstChild("AdministerMainPanel")
			if not AdministerPanel then
				return { false, "This person does not have Administer, or their panel is missing this app." }
			end

			return { true, "OK" }
		end,
	}

	task.spawn(function()
		OnBuild(AppConfig, BuiltAPI)
	end)

	App.Apps[AppButton["Name"]] = {
		["AppConfig"] = AppConfig,
		["AppButtonConfig"] = AppButton,
	}
end

