--!strict
local AppsSidebarButton = require(script.Parent.Parent.UIComponents.AppsSidebarButton)


function story(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(246, 169)
	HolderFrame.Transparency = 1
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local Apps = AppsSidebarButton("rbxassetid://14534503353", "Apps", function() end)
	local Admins = AppsSidebarButton("rbxassetid://13727401865", "Admins", function() end)

	Admins.Frame.Parent = HolderFrame
	Apps.Frame.Parent = HolderFrame
	UIListLayout.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		Admins.Destroy()
		Apps.Destroy()
		HolderFrame:Destroy()	
	end
end

return story