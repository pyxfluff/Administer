--!strict
local Spinner = require(script.Parent.Parent.UIComponents.Spinner)


function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(390, 490)
	HolderFrame.Transparency = 1
	
	local Spin = Spinner()

	Spin.Spinner.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		Spin.Destroy()
		HolderFrame:Destroy()	
	end
end

return story