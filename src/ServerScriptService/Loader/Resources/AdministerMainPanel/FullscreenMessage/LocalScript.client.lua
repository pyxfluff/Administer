--// pyxfluff 2024

local TS = game:GetService("TweenService")

TS:Create(script.Parent, TweenInfo.new(.75, Enum.EasingStyle.Quart), {GroupTransparency = 0, Size = UDim2.new(1,0,1,0)}):Play()

local Blur = script.Blur:Clone()
Blur.Parent = game.Lighting
Blur.Size = 0

TS:Create(Blur, TweenInfo.new(1.5), {Size = 25}):Play()

script.Parent.Exit.MouseButton1Click:Connect(function()
	TS:Create(script.Parent, TweenInfo.new(.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 1, Size = UDim2.new(1.5,0,1.5,0)}):Play()
	TS:Create(Blur, TweenInfo.new(.5), {Size = 0}):Play()
	
	task.wait(.75)
	
	Blur:Destroy()
	script.Parent:Destroy()
end)