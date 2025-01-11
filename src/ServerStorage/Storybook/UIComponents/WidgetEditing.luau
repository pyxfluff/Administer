local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(LoadNextWidget: () -> (), LoadPrevWidget: () -> ()): (ScrollingFrame)
 	return New "ScrollingFrame" {
		ScrollingDirection = Enum.ScrollingDirection.X,
		ZIndex = 2,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarThickness = 0,
		Name = "Editing",

		New "UICorner" {
			CornerRadius = UDim.new(0, 18),
		},
		New "TextButton" {
			TextWrapped = true,
			BorderSizePixel = 0,
			Position = UDim2.new(0.0153056, 0, 0.361301, 0),
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Name = "Last",
			TextSize = 14,
			Size = UDim2.new(0.0491236, 0, 0.269541, 0),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = " ",
			BackgroundTransparency = 1,

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = 0,
				Position = UDim2.new(0, 0, 0.234042, 0),
				Image = "rbxassetid://17685578876",
				Size = UDim2.new(1, 0, 0.52126, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},

			Event("Activated", LoadPrevWidget)
		},
		New "TextButton" {
			TextWrapped = true,
			BorderSizePixel = 0,
			Position = UDim2.new(0.935557, 0, 0.361301, 0),
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Name = "Next",
			TextSize = 14,
			Size = UDim2.new(0.0491236, 0, 0.269541, 0),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = " ",
			BackgroundTransparency = 1,

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = 0,
				Position = UDim2.new(0, 0, 0.234043, 0),
				Image = "http://www.roblox.com/asset/?id=18418735632",
				Size = UDim2.new(1, 0, 0.52126, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},

			Event("Activated", LoadNextWidget)
		},
		
		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			RichText = true,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextTransparency = 0,
			Position = UDim2.new(0.0395743, 0, 0.647158, 0),
			Name = "WidgetName",
			TextSize = 18,
			Size = UDim2.new(0.920692, 0, 0.162992, 0),
			TextColor3 = Color3.fromRGB(227, 227, 227),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = "Unselected",
			BackgroundTransparency = 1,

			New "UITextSizeConstraint" {
				MaxTextSize = 25,
			},

		},
		
		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			RichText = true,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextTransparency = 0,
			Position = UDim2.new(0.0395743, 0, 0.81015, 0),
			Name = "AppName",
			TextSize = 18,
			Size = UDim2.new(0.920692, 0, 0.130689, 0),
			TextColor3 = Color3.fromRGB(227, 227, 227),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = "None",
			BackgroundTransparency = 1,

			New "UITextSizeConstraint" {
				MaxTextSize = 15,
			},

		},
		
		New "CanvasGroup" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(11, 12, 17),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Name = "Preview",
			BorderColor3 = Color3.fromRGB(0, 0, 0),

			New "UICorner" {
				Name = "DefaultCorner_",
				CornerRadius = UDim.new(0, 0),
			},
			
			New "TextButton" {
				Visible = true,
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Name = "Select",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},

		},
		
		New "ImageLabel" {
			ImageColor3 = Color3.fromRGB(149, 149, 149),
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0,
			Name = "Background",
			Image = "rbxassetid://17685527460",
			Size = UDim2.new(1, 0, 1, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,

			New "UICorner" {
				CornerRadius = UDim.new(0, 18),
			},

		},

	}

end