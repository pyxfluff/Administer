--!strict
local Button = require(script.Parent.Parent.UIComponents.Button)



local Controls = {
	Icon = "rbxassetid://14865439768",
	SubIcon = 	"rbxassetid://18612263870",
	Tooltip = "TEST",
}

function story(props)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(1563, 48)
	HolderFrame.Transparency = 1
	
	--local AppDrawer = Button("rbxassetid://14865439768", nil, "APPS", UDim2.fromScale(0.8, 0.142), function() end)
	local SubIcon = Button(props.controls.Icon, props.controls.SubIcon, props.controls.Tooltip, UDim2.fromScale(0, 0), function() end)
	
	props.subscribe(function(values, infos)
		SubIcon:Destroy()
		
		SubIcon = Button(values.Icon, values.SubIcon, values.Tooltip, UDim2.fromScale(0, 0), function() end)
		SubIcon.Parent = HolderFrame
	end)
	
	--AppDrawer.Parent = HolderFrame
	SubIcon.Parent = HolderFrame

	HolderFrame.Parent = props.target

	return function()
		HolderFrame:Destroy()	
	end
end

local Story = {
	render = story,
	controls = Controls
}

return Story