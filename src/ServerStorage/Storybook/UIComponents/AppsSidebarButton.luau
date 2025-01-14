local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event
local Spring = UI.Spring
local State = UI.State
local Cleanup = UI.Cleanup

return function(Icon: string, Title: string, OnClick: () -> ()): { Frame: Frame, Destroy: () -> () }
	local TransparencyGoal = State(1)
	local TransparencySpring = Spring(TransparencyGoal, 0.85, 2)

	local SidebarButton: Frame = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(29, 29, 38),
		Size = UDim2.new(0.910647, 0, 0.259155, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = TransparencySpring,
		Name = `AppBtn_{string.gsub(Icon, "rbxassetid://", "")}_{math.random(1, 250)}`,
		Position = UDim2.new(0.0516522, 0, 0, 0),

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			FontFace = Font.new("rbxassetid://11702779240", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.new(0.184845, 0, 0.29219, 0),
			Name = "Title",
			TextSize = 18,
			Size = UDim2.new(0.815155, 0, 0.460355, 0),
			ZIndex = 1e+09,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = Title,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 15,
			},
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			Position = UDim2.new(0.0363719, -5, 0.496762, 0),
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Image = Icon,
			Size = UDim2.new(0.121, 0, 0.439, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			ZIndex = 1e+09,
			BackgroundTransparency = 1,

			New "UIAspectRatioConstraint" {
				DominantAxis = Enum.DominantAxis.Height,
			},
		},

		New "UICorner" {},

		New "TextButton" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextTransparency = 1,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Regular,
				Enum.FontStyle.Normal
			),
			Name = "SelectionButton",
			TextSize = 14,
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,

			Event("Activated", OnClick),
		},

		Event("MouseEnter", function(...: any)
			TransparencyGoal:Set(0.75)
		end),

		Event("MouseLeave", function(...: any)
			TransparencyGoal:Set(1)
		end),
	}

	return {
		Frame = SidebarButton,
		Destroy = function()
			Cleanup({ TransparencyGoal, TransparencySpring, SidebarButton })
		end,
	}
end
