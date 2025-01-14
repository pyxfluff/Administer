local Slider = script.Parent
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local Mouse = player:GetMouse()
local MouseLocation
local IsSliding = false

game:GetService("RunService").RenderStepped:Connect(function()
	MouseLocation = UIS:GetMouseLocation()
end)

Slider.MouseButton1Click:Connect(function()
	IsSliding = true
	repeat
		task.wait()

		Slider.Position = UDim2.fromOffset(MouseLocation.X, Slider.Position.Y.Offset)
		Mouse.Button1Down:Connect(function()
			IsSliding = false
		end)
	until IsSliding == false
end)
