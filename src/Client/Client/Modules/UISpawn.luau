--// Administer

--// Administer Team 2025

local UI = {}

function UI.HomePage()
	local UI = require(script.Parent.UI.src)
	local New = UI.New
	local Event = UI.Event
	local State = UI.State

	local UIComponents = script.Parent.Parent.Parent.roblox_packages["ui-components"]

	local UIViews = script.Parent.UIViews
	local Main = require(UIViews.Main)
	local Header = require(UIComponents.Header)
	local Home = require(UIViews.Home)
	local Widget = require(UIComponents.Widget)

	local HeaderTile = State("<b>Administer</b> · Home")
	local AppLogo = State("rbxassetid://14918096838")
	local Counters = {}
	local Widget1 = Widget(function() end, function() end, function() end, "Unassigned")
	local Widget2 = Widget(function() end, function() end, function() end, "Unassigned")

	local Home = Home(Counters, Widget1, Widget2, function() end)

	local Header = Header(HeaderTile, AppLogo, function() end, function() end)

	local MainFrame, MainGroupTransparency = Main(Header, Home)

	local Focused = false
	local MainFrameOpen = false

	MainFrameOpen = not MainFrameOpen

	MainGroupTransparency:Set(MainFrameOpen and 0 or 1)

	MainFrame.Parent = script.Parent
end

return UI
