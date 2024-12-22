local UI = require(script.Parent.Parent.Modules.UI.init)
local Header = require(script.Parent.Parent.UIComponents.Header)

local State = UI.State

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(674, 424)
	HolderFrame.Transparency = 1
	
	local HeaderTile = State("<b>Administer</b> · Home")
	local AppLogo = State("rbxassetid://14918096838")
	
	local Editing = Header(HeaderTile, AppLogo, function()  end, function()  end)

	Editing.Parent = HolderFrame

	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story