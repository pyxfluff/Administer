local UI = require(script.Parent.Parent.Modules.UI.init)
local Widget = require(script.Parent.Parent.UIComponents.Widget)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(674, 424)
	HolderFrame.Transparency = 1
	
	local Editing = Widget(function() end, function() end, function()  end, "Unassigned")

	Editing.Parent = HolderFrame


	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story