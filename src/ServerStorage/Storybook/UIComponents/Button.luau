local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function(Icon: string, SubIcon: string | nil, Tooltip: string, Position: UDim2, OnClick: () -> ()): ImageButton
	return New "ImageButton" {
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Fit,
		Position = Position,
		BackgroundColor3 = Color3.fromRGB(40, 40, 52),
		Name = `Btn_{string.gsub(Icon, "rbxassetid://", "")}_{math.random(1, 250)}`,
		Image = "rbxassetid://0",
		Size = UDim2.new(0.07, 0, 0.68, 0),
		BackgroundTransparency = 0.5,

		New "UICorner" {
			CornerRadius = UDim.new(5, 0),
		},

		New "ImageLabel" {
			ImageColor3 = Color3.fromRGB(171, 171, 171),
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(15, 16, 21),
			Position = UDim2.new(0.20, 0, 0.55, 0),
			Name = "SubIcon",
			Image = SubIcon,
			Size = UDim2.new(0.13, 0, 0.46, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Visible = (SubIcon ~= nil),
			ZIndex = 2,
			BackgroundTransparency = (SubIcon ~= nil and 0 or 1),

			New "UICorner" {
				CornerRadius = UDim.new(5, 0),
			},

			New "UIStroke" {
				Thickness = 2,
				Color = Color3.fromRGB(15, 16, 21),
			},
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(0.10, 0, 0.30, 0),
			Name = "MainIcon",
			Image = Icon,
			Size = UDim2.new(0.22, 0, 0.34, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			RichText = true,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextStrokeColor3 = Color3.fromRGB(35, 35, 35),
			Position = UDim2.new(0.44, 0, 0, 0),
			Name = "IconLabel",
			TextSize = 24,
			Size = UDim2.new(0.55, 0, 1, 0),
			ZIndex = 5,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = Tooltip,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 15,
			},
		},

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},

		Event("Activated", OnClick),
	}
end
