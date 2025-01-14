--Credit to Kryptoscythe
local slider = script.Parent
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local MouseLocation
local isSliding = false -- Is the slider is currently sliding

game:GetService("RunService").RenderStepped:Connect(function()
	MouseLocation = UIS:GetMouseLocation() -- 2D Mouse position always getting
end)

slider.MouseButton1Click:Connect(function()
	isSliding = true -- sets is sliding to true
	-- Keeps repeating to copy the same position until mouse is clicked.
	repeat
		task.wait()
		-- View the dev hub for like .19 (UDim2.fromOffset) since that explains it better than me
		slider.Position = UDim2.fromOffset(MouseLocation.X, slider.Position.Y.Offset) -- Make sure position is offset if you're using this
		mouse.Button1Down:Connect(function()
			isSliding = false
		end)
	until isSliding == false
end)
