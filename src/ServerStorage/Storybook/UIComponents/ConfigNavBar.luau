local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function()
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(0.37741, 0, 1.26713, 0),
		BorderColor3 = Color3.fromRGB(11, 12, 17),
		BackgroundTransparency = 0.5,
		Name = "MainNav",
		Position = UDim2.new(0.305759, 0, -0.578474, 0),

		New "UICorner" {
			CornerRadius = UDim.new(2, 0),
		},

		New "UIStroke" {
			Color = Color3.fromRGB(23, 23, 30),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},

		New "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.02, 0),
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.437808, 0, 0.695652, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "AInfoPage",
			Position = UDim2.new(0.0226137, 0, 0.152174, 0),

			New "UICorner" {
				CornerRadius = UDim.new(2, 0),
			},

			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0.21875, 0),
				Image = "rbxassetid://14534515862",
				Size = UDim2.new(0.197317, 0, 0.5625, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
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
				Position = UDim2.new(0.197317, 0, 0, 0),
				Name = "HeaderLabel",
				TextSize = 24,
				Size = UDim2.new(0.796683, 0, 1, 0),
				ZIndex = 5,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = "Information",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 15,
				},
			},
		},
		New "TextButton" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Regular,
				Enum.FontStyle.Normal
			),
			Name = "Click",
			TextSize = 14,
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = " ",
			BackgroundTransparency = 1,
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0, 0, 0.695652, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Visible = false,
			Name = "AASpacer",
			Position = UDim2.new(0, 0, 0.152174, 0),
		},
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.197614, 0, 0.695652, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "BSettings",
			Position = UDim2.new(0.646179, 0, 0.152174, 0),

			New "UICorner" {
				CornerRadius = UDim.new(10, 0),
			},
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://9368570772",
				Size = UDim2.new(0.6, 0, 0.6, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
			New "TextButton" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Name = "Click",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},
			New "UIAspectRatioConstraint" {},
		},
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.198, 0, 0.696, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "CApps",
			Position = UDim2.new(0.865646, 0, 0.293087, 0),

			New "UICorner" {
				CornerRadius = UDim.new(10, 0),
			},
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://16810601795",
				Size = UDim2.new(0.6, 0, 0.6, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
			New "TextButton" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Name = "Click",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},
			New "UIAspectRatioConstraint" {},
		},
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.198, 0, 0.696, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "DAdmins",
			Position = UDim2.new(1.00506, 0, 0.293087, 0),

			New "UICorner" {
				CornerRadius = UDim.new(10, 0),
			},
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://13727401865",
				Size = UDim2.new(0.6, 0, 0.6, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
			New "TextButton" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Name = "Click",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},
			New "UIAspectRatioConstraint" {},
		},
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.198, 0, 0.696, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "EErrorLog",
			Position = UDim2.new(1.14446, 0, 0.293087, 0),

			New "UICorner" {
				CornerRadius = UDim.new(10, 0),
			},
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://14146471671",
				Size = UDim2.new(0.6, 0, 0.6, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
			New "TextButton" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Name = "Click",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},
			New "UIAspectRatioConstraint" {},
		},
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(40, 40, 52),
			Size = UDim2.new(0.198, 0, 0.696, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "FMarketplace",
			Position = UDim2.new(1.28387, 0, 0.293087, 0),

			New "UICorner" {
				CornerRadius = UDim.new(10, 0),
			},
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://14534503353",
				Size = UDim2.new(0.6, 0, 0.6, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
			New "TextButton" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Name = "Click",
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = " ",
				BackgroundTransparency = 1,
			},
			New "UIAspectRatioConstraint" {},
			New "TextBox" {
				TextWrapped = true,
				ZIndex = 5,
				BorderSizePixel = 0,
				RichText = true,
				PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
				TextStrokeColor3 = Color3.fromRGB(35, 35, 35),
				Position = UDim2.new(0.197317, 0, 0, 0),
				BackgroundTransparency = 1,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Active = false,
				Visible = false,
				PlaceholderText = "Marketplace",
				TextSize = 24,
				Size = UDim2.new(0.796683, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = "",
				Selectable = false,
				Name = "Input",
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 15,
				},
			},
		},
	}
end
