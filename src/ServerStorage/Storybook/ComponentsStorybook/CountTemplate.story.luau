local CountTemplate = require(script.Parent.Parent.UIComponents.CountTemplate)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(645, 48)
	HolderFrame.Transparency = 1

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Parent = HolderFrame

	local NoToggle = CountTemplate("rbxassetid://9368579295", "No Toggle Example", "Example", nil)
	local Toggle = CountTemplate("rbxassetid://9368579295", "Toggle Example", "Example", function() end)

	Toggle.Parent = HolderFrame
	NoToggle.Parent = HolderFrame

	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end

return story
