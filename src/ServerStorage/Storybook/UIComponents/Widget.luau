local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

local SideData = require(script.Parent.SideData)
local ImageButton = require(script.Parent.ImageButton)
local WidgetEditing = require(script.Parent.WidgetEditing)

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(LoadNextWidget: () -> (), LoadPrevWidget: () -> (), EditButtonClick: () -> (), WidgetSidebarText: string): (CanvasGroup)
	return New "CanvasGroup" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(0.97887, 0, 0.336023, 0),
		BackgroundTransparency = 0.3,
		Name = "Widget1",
		Position = UDim2.new(0.0102108, 0, 0.154176, 0),

		SideData("rbxassetid://16467780710", WidgetSidebarText),

		ImageButton("rbxassetid://16467780710", nil, UDim2.fromScale(0.009, 0.791), EditButtonClick),

		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},
		New "UICorner" {
			CornerRadius = UDim.new(0, 23),
		},
		
		-- TODO (FloofyPlasma): Some way to dynaimcally hide/show
		--WidgetEditing(LoadNextWidget, LoadPrevWidget),

		New "Frame" {
			Active = true,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 35, 40),
			Selectable = true,
			Size = UDim2.new(0.957496, 0, 1, 0),
			ClipsDescendants = true,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BackgroundTransparency = 1,
			Name = "Content",
			Position = UDim2.new(0.0425047, 0, -1.61965e-07, 0),
			ZIndex = 0,
			SelectionGroup = true,
		},
	}
end