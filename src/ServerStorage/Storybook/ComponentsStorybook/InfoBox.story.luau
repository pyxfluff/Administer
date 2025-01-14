local InfoBox = require(script.Parent.Parent.UIComponents.InfoBox)

return function(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(1563, 579)
	HolderFrame.Transparency = 1

	local Details = InfoBox(Color3.fromRGB(102, 119, 142))

	Details.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end
