local ImageButton = require(script.Parent.Parent.UIComponents.ImageButton)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(660, 142)
	HolderFrame.Transparency = 1

	local EditButton = ImageButton("rbxassetid://16467780710", nil, UDim2.fromScale(0.005, 0.791), function() end)
	local ButtonWithSubIcon = ImageButton(
		"rbxassetid://16467780710",
		"rbxassetid://18512489355",
		UDim2.fromScale(0.05, 0.791),
		function() end
	)

	EditButton.Parent = HolderFrame
	ButtonWithSubIcon.Parent = HolderFrame

	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story
