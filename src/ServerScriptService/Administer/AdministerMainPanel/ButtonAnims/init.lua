--[[
Created by @Qinrir

Cleaned up a bit.
]]

return {
	["AddEffect"] = function(UIInstance, Mouse, Duration, Color)
		if UIInstance.ClipsDescendants == false then
			UIInstance.ClipsDescendants = true
		end
		
		if UIInstance.AutoButtonColor == true then
			UIInstance.AutoButtonColor = false
		end
		
		local ASX,ASY = UIInstance.AbsoluteSize.X, UIInstance.AbsoluteSize.Y
		local APX,APY = UIInstance.AbsolutePosition.X, UIInstance.AbsolutePosition.Y
		local MX,MY = Mouse.X,Mouse.Y

		local UI = Instance.new("Frame",UIInstance)
		UI.BackgroundColor3 = Color
		UI.Name = "Ripple"
		UI.ZIndex = math.huge
		
		local Corner = Instance.new("UICorner",UI)
		Corner.CornerRadius = UDim.new(1,0)
		
		UI.AnchorPoint = Vector2.new(0.5,0.5)
		UI.Position = UDim2.new(0, Mouse.X - APX, 0, Mouse.Y - APY)

		UI:TweenSize(
			UDim2.fromOffset(math.max(ASX, ASY), math.max(ASX, ASY)),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			Duration
		)
		
		game:GetService("TweenService"):Create(UI,TweenInfo.new(Duration),{BackgroundTransparency = 1}):Play()
		
		task.wait(Duration)
		UI:Destroy()
	end
}