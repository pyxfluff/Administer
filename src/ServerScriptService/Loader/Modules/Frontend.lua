--// pyxfluff 2024

local FrontendAPI = {}

local Var = require(script.Parent.Parent.Core.Variables)
local Utils = require(script.Parent.Utilities)
local Config = Var.Config

function FrontendAPI.NewUpdateLogText(ParentFrame, Text)
	local Template = ParentFrame.ScrollingFrame.TextLabel:Clone()

	Template.Visible = true
	Template.Text = Text
	Template.Name = Text
	Template.Parent = ParentFrame.ScrollingFrame
end

function FrontendAPI.VersionCheck(
	Player: Player
): ()
	local VersModule, Frame = require(Var.CurrentBranch["UpdateLog"]), Player.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails

	for i, Label in Frame.ScrollingFrame:GetChildren() do
		if Label:IsA("TextLabel") and Label.Name ~= "TextLabel" then
			Label:Destroy()
		end
	end

	if (VersModule.Version.Major > Config.VersData.Major or 
			VersModule.Version.Minor > Config.VersData.Minor or
			VersModule.Version.Tweak > Config.VersData.Tweak
		) then
		Frame.Version.Text = `Version {Config.VersData.String}` --// don't include the date bc we don't store that here
		Utils.NewNotification(Player, 
			`{Config["Name"]} is out of date. Please update your module.`, 
			"Version check complete", 
			"rbxassetid://9894144899", 15, nil, {
				--{
				--	["Text"] = "Reboot servers with Soft Shutdown+",
				--	["Icon"] = "",
				--	["Callback"] = function()
				--		--// TODO
				--		return
				--	end,
				--}})
			})
		FrontendAPI.NewUpdateLogText(`A new version is available! {VersModule.Version.String} was released on {VersModule.ReleaseDate}. Showing the logs from that update.`)
	else
		Frame.Version.Text = `Version {VersModule.Version.String} ({VersModule.ReleaseDate})`
	end

	for i, Note in VersModule.ReleaseNotes do
		FrontendAPI.NewUpdateLogText(Note)
	end
end




return FrontendAPI