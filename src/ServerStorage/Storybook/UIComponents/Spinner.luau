local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event
local State = UI.State
local Spring = UI.Spring
local Cleanup = UI.Cleanup

return function(): { Spinner: CanvasGroup, Destroy: () -> () }
	local RotationGoal = State(0)
	local RotationSpring = Spring(RotationGoal, 1, 1)

	local Rotations = 0
	local Spinning = true
	local Resetting = false

	local InnerSpin = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.9, 0, 0.9, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Name = "InnerSpin",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = RotationSpring,

		New "UIAspectRatioConstraint" {},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1.5, 0, 1.36193, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.138068, 0),
		},

		New "UICorner" {
			CornerRadius = UDim.new(50, 0),
		},
	}

	local Spinner = New "CanvasGroup" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.393915, 0, 0.227003, 0),
		Name = "Spinner",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),

		New "UIAspectRatioConstraint" {},

		New "UICorner" {
			CornerRadius = UDim.new(50, 0),
		},

		InnerSpin,
	}

	task.defer(function()
		while Spinning do
			task.wait()

			local Rotation = InnerSpin.Rotation

			--if Rotation > 359 and not Resetting then
			--	Resetting = true
			--	RotationGoal:Set(0)
			--	UI.Update(InnerSpin)({Rotation = 0})
			--elseif Rotation <= 359 and Rotation >= 1 and Resetting then
			--	UI.Update(InnerSpin)({Rotation = 0})
			--elseif Rotation < 1 and Resetting then
			--	Resetting = false
			--	UI.Update(InnerSpin)({Rotation = 0})
			--	RotationGoal:Set(360)
			--end
			if Rotation > 719 and not Resetting then
				Resetting = true
				RotationGoal:Set(0)
				task.wait(0.5)
			elseif Rotation < 1 and Resetting then
				Resetting = false
				RotationGoal:Set(720)
			end
		end
	end)

	RotationGoal:Set(720)

	return {
		Spinner = Spinner,
		Destroy = function()
			Spinning = false
			Cleanup({ RotationGoal, RotationSpring, Spinner })
		end,
	}
end
