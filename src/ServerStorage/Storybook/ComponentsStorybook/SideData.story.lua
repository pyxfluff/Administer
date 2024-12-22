local SideData = require(script.Parent.Parent.UIComponents.SideData)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(660, 142)
	HolderFrame.Transparency = 1
	
	local SideData = SideData("rbxassetid://16467780710", "Unassigned")

	SideData.Parent = HolderFrame


	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()	
	end
end

return story