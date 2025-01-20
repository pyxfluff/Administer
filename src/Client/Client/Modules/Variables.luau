--// Administer (2.0.0)

--// Administer Team (2024-2025)

local Variables = {}

Variables.AdministerRoot = script.Parent.Parent.Parent
Variables.Remotes = game.ReplicatedStorage:WaitForChild("AdministerRemotes", 10)

Variables.MainFrame = Variables.AdministerRoot:WaitForChild("Main", 10)
Variables.AppAPIVersion = 2.0
Variables.VersionString = "2.0"
Variables.WidgetConfigIdealVersion = "1.0"
Variables.Mobile = false
Variables.InitErrored = false
Variables.IsOpen = true
Variables.IsPanelAnimating = false
Variables.EnableEditableImages = true
Variables.LastPage = "Home"

Variables.Panel = nil
Variables.OpenSound = script.Parent --// TODO

Variables.Services = {
	AssetService = game:GetService("AssetService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
}

function Variables.init() end

return Variables
