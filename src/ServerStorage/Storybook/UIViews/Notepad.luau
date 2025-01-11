local Components = script.Parent.Parent.UIComponents
local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function()
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Name = "Notepad",

		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(11, 12, 17),
			Size = UDim2.new(0.634491, 0, 0.429927, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.3,
			Name = "InputFrame",
			Position = UDim2.new(0.182595, 0, 0.187312, 0),

			New "UICorner" {
				CornerRadius = UDim.new(0, 19),
			},
			
			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
			
			New "TextBox" {
				TextWrapped = true,
				BorderSizePixel = 0,
				Position = UDim2.new(0.00803868, 0, 0.0414939, 0),
				BackgroundTransparency = 1,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				PlaceholderText = "Start typing a new note..",
				TextSize = 14,
				Size = UDim2.new(0.983923, 0, 0.912863, 0),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = "",

				New "UITextSizeConstraint" {
					MaxTextSize = 15,
				},
			},
		},
		
		New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(14, 15, 22),
			Size = UDim2.new(0.91947, 0, 0.132514, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
			Name = "Header",
			Position = UDim2.new(0.00789533, 0, 0.0917442, 0),

			New "TextLabel" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Position = UDim2.new(0.0128756, 0, 0.0649947, 0),
				Name = "Head",
				TextSize = 22,
				Size = UDim2.new(0.508289, 0, 0.432518, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = "Notepad",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 30,
				},
			},
			
			New "UICorner" {
				CornerRadius = UDim.new(0, 18),
			},
		},
	}
end