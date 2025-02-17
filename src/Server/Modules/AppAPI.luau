--// Administer
--// (pyxfluff + FloofyPlasma) 2024

local App = {
	APIVersion = "2.0",
	Apps = {},
}

local Administer = nil

---------------------------------

--[[
local NewButton = function(ButtonIcon, Name, Frame, Tip, HasBG, BGOverride)
	if table.find(ExistingButtons, ExistingButtons[Name]) then return { false, "Button was found already" } end

	local Success, Dock = pcall(function()
		return Administer:WaitForChild("Main"):WaitForChild("Apps"):WaitForChild("MainFrame")
	end)

	if not Success then
		warn(
			`[Administer AppAPI]: Failed finding the AppDock, is the panel fully loaded in? (Failed building AppButtonObject for {Name})`
		)
		return { false, "Something went wrong on our end, try checking the documentation." }
	end

	local Button: TextButton = Dock:WaitForChild("Template"):Clone()

	local Success, Error = pcall(function()
		local LinkID = game:GetService("HttpService"):GenerateGUID(false)

		Button.Visible = true
		Button.Name = Name
		Button.Icon.Image = ButtonIcon
		Button.Desc.Text = Tip
		Button.Reflection.Image = ButtonIcon
		Button.Title.Text = Name
		Button.IconBG.Visible = HasBG ~= nil and HasBG or true
		Button:SetAttribute("LinkID", LinkID)
		Button:SetAttribute("BackgroundOverride", BGOverride)

		local AppFrame = Frame:Clone()
		AppFrame.Parent = Administer.Main
		AppFrame.Name = Frame.Name
		AppFrame.Visible = false
		AppFrame:SetAttribute("LinkID", LinkID)
		AppFrame:SetAttribute("LinkedButton", Button.Name) --// easier server lookups
	end)
	if not Success then
		Button:Destroy()
		return {
			false,
			`Could not build the button! This is likely the result of a misconfiguration to the data passed to Administer. Error: {Error}`,
		}
	else
		Button.Parent = Dock
		return { true, "Success!" }
	end
end

]]

App.Build = function(OnBuild, AppConfig, AppButton)
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

return App
