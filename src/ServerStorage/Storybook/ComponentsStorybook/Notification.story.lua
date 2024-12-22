local UI = require(script.Parent.Parent.Modules.UI.init)
local Notification = require(script.Parent.Parent.UIComponents.Notification)
local Button = require(script.Parent.Parent.UIComponents.Button)
local ImageButton = require(script.Parent.Parent.UIComponents.ImageButton)

function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(185, 896)
	HolderFrame.Transparency = 1

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0.01, 0)
	ListLayout.Parent = HolderFrame

	local NoButtonNotification = Notification("rbxassetid://18224047110", "rbxassetid://15105863258", "Administer", "Notification Storybook", "This is a test notification in the notification story.", {}, function()  end)
	NoButtonNotification.Parent = HolderFrame

	local TestButton = Button("rbxassetid://18224047110", nil, "EXIT", UDim2.fromScale(0, 0), function()  end)
	local TestButton2 = ImageButton("rbxassetid://18224047110", nil, UDim2.fromScale(0, 0), function()  end)
	TestButton2.Size = UDim2.fromScale(0.6, 0.6)

	local ButtonNotification = Notification("rbxassetid://18224047110", "rbxassetid://15105863258", "Administer", "Notification Storybook", "This is a test notification in the notification story.", {TestButton, TestButton2}, function()  end)
	ButtonNotification.Parent = HolderFrame


	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
		TestButton:Destroy()
		TestButton2:Destroy()
	end
end

return story