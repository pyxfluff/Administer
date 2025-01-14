local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(Icon: string, SubIcon: string | nil, Position: UDim2, OnClick: () -> ()): ImageButton
	return New "ImageButton" {
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Fit,
		Position = Position,
		BackgroundColor3 = Color3.fromRGB(40, 40, 52),
		Name = `CrclBtn_{string.gsub(Icon, "rbxassetid://", "")}_{math.random(1, 250)}`,
		Image = "rbxassetid://0",
		Size = UDim2.new(0.15, 0, 0.15, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BackgroundTransparency = 0.5,

		New "UICorner" {
			CornerRadius = UDim.new(5, 0),
		},

		New "ImageLabel" {
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(15, 16, 21),
			Position = UDim2.new(0.55, 0, 0.55, 0),
			Name = "SubIcon",
			Image = SubIcon,
			Size = UDim2.new(0.31, 0, 0.31, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Visible = (SubIcon ~= nil),
			ZIndex = 2,
			BackgroundTransparency = (SubIcon ~= nil and 0 or 1),

			New "UICorner" {
				CornerRadius = UDim.new(5, 0),
			},

			New "UIStroke" {
				Thickness = 1,
				Color = Color3.fromRGB(15, 16, 21),
			},
		},

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},

		New "ImageLabel" {
			ImageColor3 = (SubIcon ~= nil and Color3.fromRGB(189, 189, 189) or Color3.new(1, 1, 1)),
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.fromScale(0.5, 0.5),
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = Icon,
			Size = UDim2.new(0.5, 0, 0.5, 0),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
		},

		New "UIAspectRatioConstraint" {},

		Event("Activated", OnClick),
	}
end
