script.Parent.Size = UDim2.new(0.085,0,0.139,0)
script.Parent.Position = UDim2.new(0.458,0,0.431,0)
game:GetService("ContentProvider"):PreloadAsync({script.Parent})
while true do
	local TS = game:GetService("TweenService")
	local Tween1 = TS:Create(script.Parent, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false,0), {Rotation = 360})
	Tween1:Play()
	Tween1.Completed:Wait()
	script.Parent.Rotation = 0
	local Tween2 = TS:Create(script.Parent, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false,0), {Rotation = 360})
	Tween2:Play()
	Tween2.Completed:Wait()
	script.Parent.Rotation = 0
end
