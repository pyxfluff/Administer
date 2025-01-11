local WidgetEditing = require(script.Parent.Parent.UIComponents.WidgetEditing)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(660, 142)
	HolderFrame.Transparency = 1
	
	local Editing = WidgetEditing(function() end, function() end)

	Editing.Parent = HolderFrame


	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()	
	end
end

return story