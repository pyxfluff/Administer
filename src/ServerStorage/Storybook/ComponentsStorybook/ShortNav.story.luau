local NavBar = require(script.Parent.Parent.UIComponents.ConfigNavBar)

return function(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(660, 142)
	HolderFrame.Transparency = 1

	local NBar = NavBar()

	NBar.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end
