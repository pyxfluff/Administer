local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

local ImageButton = require(script.Parent.ImageButton)
local Button = require(script.Parent.Button)

return function(AppIcon: string, RealIcon: string, AppTitle: string, NotificationTitle: string, NotificationBody: string, NotificationButtons: {typeof(Button) | typeof(ImageButton)}, CloseButtonCallback: () -> ()): (Frame)
	local Condensed = #NotificationButtons == 0
	
	local Buttons = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0.9, 0, 0.4, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Name = "Buttons",
		Position = UDim2.new(0.0524411, 0, 0.570512, 0),

		New "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true,
			Padding = UDim.new(0, 10),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},
	}
	
	local Notification = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = Condensed and UDim2.new(1, 0, 0.1, 0) or UDim2.new(1, 0, 0.17, 0),
		ClipsDescendants = true,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BackgroundTransparency = 1,
		Name = `Notif_{AppTitle}-{math.random(1, 250)}`,
		Position = UDim2.new(-0.0178982, 0, 0.82937, 0),

		New "CanvasGroup" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Name = "NotificationContent",
			BorderColor3 = Color3.fromRGB(0, 0, 0),

			New "Frame" {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(8, 8, 11),
				Size = UDim2.new(1, 0, 1, 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				BackgroundTransparency = 0.2,
				Name = "Background",
				Position = UDim2.new(0.0061328, 0, 0.00577768, 0),
				ZIndex = 0,

				New "UICorner" {
					CornerRadius = UDim.new(0, 17),
				},
			},

			Buttons,

			New "Frame" {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(32, 35, 40),
				Size = UDim2.new(1, 0, (Condensed and .45 or 0.26), 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				BackgroundTransparency = 1,
				Name = "Header",
				Position = UDim2.new(-1.88, 0, 0, 0),
				ZIndex = 2,

				New "TextLabel" {
					TextWrapped = true,
					BorderSizePixel = 0,
					RichText = true,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					Position = UDim2.new(2.03707, 0, 0.021984, 0),
					Name = "AppTitle",
					TextSize = 14,
					Size = UDim2.new(0.796141, 0, 0.385631, 0),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					Text = AppTitle,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,

					New "UITextSizeConstraint" {
						MaxTextSize = 15,
					},
				},

				New "ImageLabel" {
					BorderSizePixel = 0,
					ScaleType = Enum.ScaleType.Fit,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = UDim2.new(1.9029, 0, 0.149811, 0),
					Name = "RealIcon",
					Image = RealIcon,
					Size = UDim2.new(0.0991689, 0, 0.483465, 0),
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					BackgroundTransparency = 1,
				},

				New "ImageLabel" {
					BorderSizePixel = 0,
					ScaleType = Enum.ScaleType.Fit,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = UDim2.new(1.95067, 0, 0.353968, 0),
					Name = "AppIcon",
					Image = AppIcon,
					Size = UDim2.new(0.0656263, 0, 0.32409, 0),
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					BackgroundTransparency = 1,
				},

				New "TextLabel" {
					TextWrapped = true,
					BorderSizePixel = 0,
					RichText = true,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
					Position = UDim2.new(2.03707, 0, 0.385464, 0),
					Name = "Title",
					TextSize = 14,
					Size = UDim2.new(0.796141, 0, 0.385631, 0),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					Text = NotificationTitle,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,

					New "UITextSizeConstraint" {
						MaxTextSize = 13,
					},

				},

				ImageButton("rbxassetid://15105963940", nil, UDim2.fromScale(0.277, 0.13), CloseButtonCallback),
			},

			New "TextLabel" {
				TextWrapped = true,
				BorderSizePixel = 0,
				RichText = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Position = UDim2.new(.025, 0, (Condensed and .33 or .2), 0),
				Name = "Body",
				TextSize = 14,
				Size = UDim2.new(0.962413, 0, 0.367883, 0),
				ZIndex = 2,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = NotificationBody,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 16,
				},

			},

			New "UICorner" {
				CornerRadius = UDim.new(0, 17),
			},
		}
	}
	
	if #NotificationButtons ~= 0 then
		for _, Button in NotificationButtons do
			Button.Parent = Buttons
		end
	end
	
	return Notification
end