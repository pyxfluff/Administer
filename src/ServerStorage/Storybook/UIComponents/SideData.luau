local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function(Icon: string, BannerText: string): Frame
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0.0808606, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Name = "SideData",
		Position = UDim2.new(0, 0, 8.09827e-08, 0),
		ZIndex = 0,

		New "UICorner" {
			CornerRadius = UDim.new(0, 23),
		},

		New "UIGradient" {
			Transparency = NumberSequence.new {
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.316708, 0.85),
				NumberSequenceKeypoint.new(0.433915, 1),
				NumberSequenceKeypoint.new(1, 1),
			},
			Color = ColorSequence.new {
				ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 8, 9)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 8, 9)),
			},
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(0.1, 4, 0.0817, -5),
			Name = "BannerIcon",
			Image = Icon,
			Size = UDim2.new(0.3, 0, 0.11, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,

			New "UIAspectRatioConstraint" {
				AspectRatio = 1,
			},
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.new(-0.4, 0, 0, 0),
			Name = "Banner",
			TextSize = 50,
			Size = UDim2.new(1.35, 0, 1, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = BannerText,
			Rotation = -90,
			BackgroundTransparency = 1,

			New "UITextSizeConstraint" {
				MaxTextSize = 17,
			},
		},
	}
end
