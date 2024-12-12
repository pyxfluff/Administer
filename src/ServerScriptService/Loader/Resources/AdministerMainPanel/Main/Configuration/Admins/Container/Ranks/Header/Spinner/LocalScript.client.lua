game:GetService("ContentProvider"):PreloadAsync({script.Parent})
local TS = game:GetService("TweenService")
local Tween = TS:Create(script.Parent, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false,0), {Rotation = 360})

while true do
	Tween:Play()
	Tween.Completed:Wait()
	script.Parent.Rotation = 0
end
