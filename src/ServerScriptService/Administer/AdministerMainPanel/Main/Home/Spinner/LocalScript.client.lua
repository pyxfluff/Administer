while true do
	local tween = game:GetService("TweenService"):Create(script.Parent, TweenInfo.new(0.3,Enum.EasingStyle.Linear, Enum.EasingDirection.In,0,false,0),{Rotation=360})
	tween:Play()
	tween.Completed:Wait()
	script.Parent.Rotation = 0
end