local UIComponents = script.Parent.Parent.UIComponents
local Header = require(UIComponents.Header)
local Main = require(script.Parent.Parent.UIViews.Main)
local UI = require(script.Parent.Parent.Modules.UI.init)

local State = UI.State

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromScale(1, 1)
	HolderFrame.Transparency = 1

	local HeaderTile = State("<b>Administer</b> · Home")
	local AppLogo = State("rbxassetid://14918096838")

	local Header = Header(HeaderTile, AppLogo, function() end, function() end)

	local Main = Main(Header, {})

	Main.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story
