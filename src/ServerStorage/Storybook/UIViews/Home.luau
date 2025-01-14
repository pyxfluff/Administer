local Components = script.Parent.Parent.UIComponents
local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

local Counter = require(Components.CountTemplate)
local ImageButton = require(Components.ImageButton)

return function(Counters: { typeof(Counter)? }, Widget1: CanvasGroup, Widget2: CanvasGroup, QuickActionsEdit: () -> ())
	local CounterFrames = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(252, 250, 255),
		Size = UDim2.new(0.95697, 0, 0.110194, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BackgroundTransparency = 1,
		Name = "Counts",
		Position = UDim2.new(0.0104651, 0, 0.867841, 0),

		New "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	}

	local ImageButton = ImageButton("rbxassetid://14608897773", nil, UDim2.new(0.952, 0, 0.905, 0), QuickActionsEdit)
	ImageButton.Size = UDim2.fromScale(0.031, 0.071)

	local Homepage = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BackgroundTransparency = 1,
		Name = "Home",

		New "UICorner" {},

		CounterFrames,

		New "ImageLabel" {
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(0.0104652, 0, 0.0773981, 0),
			Name = "PlayerImage",
			Image = "rbxassetid://84027648824846",
			Size = UDim2.new(0.0254783, 0, 0.0774305, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,

			New "UICorner" {
				CornerRadius = UDim.new(0, 0),
			},
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			RichText = true,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			Position = UDim2.new(0.0430961, 0, 0.0762195, 0),
			Name = "Welcome",
			TextSize = 18,
			Size = UDim2.new(0.534162, 0, 0.0786091, 0),
			TextColor3 = Color3.fromRGB(184, 184, 184),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = [[<stroke color="rgb(0,0,0)" transparency = "0.85" thickness=".4">Administer is loading...</stroke>]],
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 20,
			},

			New "UIStroke" {
				Thickness = 1.3,
			},
		},

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 0.341529, 0),
			ClipsDescendants = true,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Name = "Gradient2",
			Position = UDim2.new(0, 0, -4.08309e-08, 0),
			ZIndex = 0,

			New "ImageLabel" {
				ImageColor3 = Color3.fromRGB(44, 43, 53),
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(-0.152, 0, -1.21132, 0),
				Image = "http://www.roblox.com/asset/?id=18742592377",
				Size = UDim2.new(0.312533, 0, 2.77148, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},
		},

		Widget1,
		Widget2,

		ImageButton,
	}

	Widget1.Position = UDim2.fromScale(0.01, 0.154)
	Widget2.Position = UDim2.fromScale(0.01, 0.506)

	if #Counters ~= 0 then
		for _, Counter in Counters do
			Counter.Parent = CounterFrames
		end
	end

	return Homepage
end
