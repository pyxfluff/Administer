--!strict
local TextInput = require(script.Parent.Parent.UIComponents.TextInput)

local Controls = {
	PlaceholderText = "TEST",
}

function story(props)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(337, 94)
	HolderFrame.Transparency = 1
	
	--local AppDrawer = Button("rbxassetid://14865439768", nil, "APPS", UDim2.fromScale(0.8, 0.142), function() end)
	local Input = TextInput(props.controls.PlaceholderText, UDim2.fromScale(0.033, 0.586), UDim2.fromScale(0.44, 0.32), function() end)
	
	props.subscribe(function(values, infos)
		Input:Destroy()
		
		Input = TextInput(values.PlaceholderText, UDim2.fromScale(0.033, 0.586), UDim2.fromScale(0.44, 0.32), function() end)
		Input.Parent = HolderFrame
	end)
	
	--AppDrawer.Parent = HolderFrame
	Input.Parent = HolderFrame

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