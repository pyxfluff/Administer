local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(Icon: string, Title: string, Count: string, ToggleFunction: (() -> ()) | nil): (Frame)
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(0.166667, 0, 0.983066, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		Name = `Count_{string.gsub(Icon, "rbxassetid://", "")}_{math.random(1,250)}`,
		Position = UDim2.new(0.166667, 0, 0, 0),

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.new(0.186847, 0, 1.32186e-06, 0),
			Name = "Title",
			TextSize = 13,
			Size = UDim2.new(0.688295, 0, 0.282558, 0),
			TextColor3 = Color3.fromRGB(171.062, 171.062, 171.062),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = Title,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 16,
			},
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.new(0.0273878, 0, 0.462599, 0),
			Name = "Count",
			TextSize = 20,
			Size = UDim2.new(0.812349, 0, 0.462351, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = Count,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 22,
			},
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			Position = UDim2.new(-1.44366e-07, 0, 0.0219958, 0),
			Name = "Icon",
			Image = Icon,
			Size = UDim2.new(0.151519, 0, 0.263637, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
		},

		New "TextButton" {
			Visible = (ToggleFunction ~= nil and true or false),
			TextWrapped = true,
			BorderSizePixel = 0,
			Position = UDim2.new(0.827585, 0, -0.0336391, 0),
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Name = "Toggle",
			TextSize = 14,
			Size = UDim2.new(0.162933, 0, 0.397994, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "+",
			BackgroundTransparency = 1,

			Event("Activated", (ToggleFunction ~= nil and ToggleFunction or function() end))
		},

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},

		New "UICorner" {
			CornerRadius = UDim.new(0.3, 0),
		},

		New "UIPadding" {
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
		},
	}


end