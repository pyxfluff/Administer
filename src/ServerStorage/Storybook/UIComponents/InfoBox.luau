local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(GradientColor: Color3): CanvasGroup
	return New "CanvasGroup" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(0.515256, 0, 0.21114, 0),
		BackgroundTransparency = 0.25,
		Name = "AdminDetails",
		Position = UDim2.new(0.467453, 0, 0.0193269, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://11702779240", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			Position = UDim2.new(0.205984, -4, 0.566779, 0),
			Name = "Version",
			TextSize = 99,
			Size = UDim2.new(0.773182, 0, 0.305818, 0),
			TextColor3 = Color3.fromRGB(149, 149, 149),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = "Administrator since June 1st, 2024",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 15,
			},
		},

		New "UICorner" {
			CornerRadius = UDim.new(0, 15),
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Position = UDim2.new(0.00925975, 0, 0.127514, 0),
			Name = "Logo",
			Image = `rbxthumb://type=AvatarHeadShot&id={game:GetService("Players").LocalPlayer.UserId}&w=150&h=150`,
			Size = UDim2.new(0.188867, 0, 0.745083, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
			SliceScale = 2,

			New "UICorner" {
				CornerRadius = UDim.new(2, 0),
			},
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
			Position = UDim2.new(0.205984, -4, 0.124962, 0),
			Name = "TextLogo",
			Size = UDim2.new(0.773182, 0, 0.441818, 0),
			TextColor3 = Color3.fromRGB(232, 232, 232),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = `Hi, {game:GetService("Players").LocalPlayer.DisplayName}!`,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UICorner" {
				CornerRadius = UDim.new(0, 12),
			},

			New "UITextSizeConstraint" {
				MaxTextSize = 27,
			},
		},

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Position = UDim2.new(-0.0671326, 0, -0.202466, 0),
			Name = "LogoBG",
			Image = `rbxthumb://type=AvatarHeadShot&id={game:GetService("Players").LocalPlayer.UserId}&w=150&h=150`,
			Size = UDim2.new(0.361083, 0, 1.31046, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			ZIndex = 0,
			BackgroundTransparency = 1,
			SliceScale = 2,

			New "UIGradient" {
				Transparency = NumberSequence.new {
					NumberSequenceKeypoint.new(0, 0.21875),
					NumberSequenceKeypoint.new(0.429639, 0.675),
					NumberSequenceKeypoint.new(0.800747, 0.81875),
					NumberSequenceKeypoint.new(1, 1),
				},
				Rotation = 90,
			},
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1.00433, 0, 0.489753, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "TopGrad",
			Position = UDim2.new(-0.00432702, 0, 1.55172e-07, 0),
			ZIndex = 0,

			New "UIGradient" {
				Transparency = NumberSequence.new {
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.154421, 0.99375),
					NumberSequenceKeypoint.new(0.58655, 0.81875),
					NumberSequenceKeypoint.new(1, 0),
				},
				Color = ColorSequence.new {
					ColorSequenceKeypoint.new(0, GradientColor),
					ColorSequenceKeypoint.new(1, GradientColor),
				},
				Rotation = -90,
			},
		},

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},
	}
end
