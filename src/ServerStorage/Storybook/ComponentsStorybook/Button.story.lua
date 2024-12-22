--!strict
local Button = require(script.Parent.Parent.UIComponents.Button)


function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(1563, 48)
	HolderFrame.Transparency = 1
	
	local AppDrawer = Button("rbxassetid://14865439768", nil, "APPS", UDim2.fromScale(0.8, 0.142), function() end)
	local SubIcon = Button("rbxassetid://14865439768", "rbxassetid://18612263870", "TEST", UDim2.fromScale(0.89, 0.142), function() end)
	
	AppDrawer.Parent = HolderFrame
	SubIcon.Parent = HolderFrame

	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()	
	end
end

return story