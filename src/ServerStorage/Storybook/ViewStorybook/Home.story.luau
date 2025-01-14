local UIComponents = script.Parent.Parent.UIComponents
local UIViews = script.Parent.Parent.UIViews
local Counter = require(UIComponents.CountTemplate)
local Header = require(UIComponents.Header)
local Home = require(UIViews.Home)
local Main = require(UIViews.Main)
local UI = require(script.Parent.Parent.Modules.UI.init)
local Widget = require(UIComponents.Widget)

local State = UI.State

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromScale(1, 1)
	HolderFrame.Transparency = 1

	local HeaderTile = State("<b>Administer</b> · Home")
	local AppLogo = State("rbxassetid://14918096838")
	local Counters = {}
	local Widget1 = Widget(function() end, function() end, function() end, "Unassigned")
	local Widget2 = Widget(function() end, function() end, function() end, "Unassigned")

	local Home = Home(Counters, Widget1, Widget2)

	local Header = Header(HeaderTile, AppLogo, function() end, function() end)

	local Main = Main(Header, Home)

	Main.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story
