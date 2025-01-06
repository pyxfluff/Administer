local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

local Button = require(script.Parent.Button)
local ImageButton = require(script.Parent.ImageButton)

return function(HeaderLabel: UI.State, AppLogo: UI.State, AppsClick: () -> (), ExitClick: () -> ())
	local CloseButton = ImageButton("rbxassetid://15105963940", nil, UDim2.new(0.965, 3, 0.14, 0), ExitClick)
	CloseButton.Size = UDim2.fromScale(0.03, 0.5)
	
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(1, 0, 0.077398, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		Name = "Header",
		Position = UDim2.new(5.72878e-08, 0, -2.74263e-08, 0),
		ZIndex = 9999,

		New "UIGradient" {
			Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.620174, 0.30625), NumberSequenceKeypoint.new(1, 1) },
			Rotation = 90,
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0.39, 0, 1, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
			Name = "Mark",
			Position = UDim2.new(0.33, 0, 0, 0),

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(16, 17, 20),
				Position = UDim2.new(-0.78, 1, 0.59, 0),
				Name = "Logo",
				Image = "rbxassetid://18224047110",
				Size = UDim2.new(0.0553076, 0, 0.39, 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				ZIndex = 7,
				SliceScale = 2,

				New "UIAspectRatioConstraint" {},
				
				New "UIStroke" {
					Color = Color3.fromRGB(80, 86, 143),
					Thickness = 1.5,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				},
				
				New "UICorner" {
					CornerRadius = UDim.new(0, 4),
				},
			},
			
			New "TextLabel" {
				TextWrapped = true,
				BorderSizePixel = 0,
				RichText = true,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextStrokeColor3 = Color3.fromRGB(35, 35, 35),
				Position = UDim2.new(-0.73, 0, 0, 0),
				Name = "HeaderLabel",
				TextSize = 24,
				Size = UDim2.new(1.69308, 0, 1, 0),
				ZIndex = 5,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = HeaderLabel,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 23,
				},
			},

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				Position = UDim2.new(-0.81, 0, 0.23, 0),
				Name = "AppLogo",
				Image = AppLogo,
				Size = UDim2.new(0.0579, 0, 0.524, 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				ZIndex = 6,
				BackgroundTransparency = 1,
				SliceScale = 2,

				New "UIAspectRatioConstraint" {},
			},
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0.26, 0, 0.8, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Name = "Alerts",
			Position = UDim2.new(0.55, 0, 0.11, 0),

			New "UIGridLayout" {
				StartCorner = Enum.StartCorner.BottomLeft,
				SortOrder = Enum.SortOrder.LayoutOrder,
				CellSize = UDim2.new(0.07, 0, 1, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
			},

			New "ImageButton" {
				ZIndex = 10,
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				Position = UDim2.new(0.930003, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(40, 40, 52),
				Visible = false,
				Name = "MobileToggle",
				Image = "rbxassetid://18151072839",
				Size = UDim2.new(0.07, 0, 1, 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				BackgroundTransparency = 1,

				New "UICorner" {},
			},
		},

		Button("rbxassetid://14865439768", nil, "APPS", UDim2.new(0.839, 3, 0.14, 0), AppsClick),
		CloseButton,

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0, 171, 0, 44),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Visible = false,
			Position = UDim2.new(0.824091, 0, -0.0230486, 0),
			ZIndex = 0,
		},
	}

end