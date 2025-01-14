local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function(PlaceholderText: string, Position: UDim2, Size: UDim2, OnClick: () -> ()): ImageButton
	return New "TextBox" {
		TextWrapped = true,
		ZIndex = 5,
		BorderSizePixel = 0,
		Position = Position,
		TextScaled = true,
		BackgroundColor3 = Color3.fromRGB(8, 8, 13),
		FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		PlaceholderText = PlaceholderText,
		TextSize = 14,
		Size = Size,
		TextColor3 = Color3.fromRGB(222, 222, 222),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		Name = `TxtInput_{PlaceholderText}_{math.random(1, 250)}`,
		ClearTextOnFocus = false,

		New "UITextSizeConstraint" {
			MaxTextSize = 15,
		},

		New "UICorner" {
			CornerRadius = UDim.new(0, 14),
		},

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},
	}
end
