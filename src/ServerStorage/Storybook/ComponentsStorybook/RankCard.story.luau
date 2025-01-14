local RankCard = require(script.Parent.Parent.UIComponents.RankCard)

return function(target: Frame)
	local HolderFrame = Instance.new("Frame")
	HolderFrame.Size = UDim2.fromOffset(690, 420)
	HolderFrame.Transparency = 1

	local Grid = Instance.new("UIGridLayout")
	Grid.CellPadding = UDim2.fromOffset(5, 5)
	Grid.CellSize = UDim2.fromScale(0.32, 0.4)
	Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Grid.Parent = HolderFrame

	local Rank = RankCard({
		{ Icon = "rbxassetid://10788628137", Title = "App1" },
		{ Icon = "rbxassetid://10788628137", Title = "App2" },
		{ Icon = "rbxassetid://10788628137", Title = "App3" },
		{ Icon = "rbxassetid://10788628137", Title = "App4" },
	})
	local Rank2 = RankCard({
		{ Icon = "rbxassetid://10788628137", Title = "App1" },
		{ Icon = "rbxassetid://10788628137", Title = "App2" },
		{ Icon = "rbxassetid://10788628137", Title = "App3" },
		{ Icon = "rbxassetid://10788628137", Title = "App4" },
	})

	Rank2.Parent = HolderFrame
	Rank.Parent = HolderFrame
	HolderFrame.Parent = target

	return function()
		HolderFrame:Destroy()
	end
end
