local Components = script.Parent.Parent.UIComponents
local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

return function(Header: Frame, Body: UI.State)
	return New "CanvasGroup" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 11),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.843, 0, 0.708, 0),
		BackgroundTransparency = 0.2,
		Name = "Main",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		
		Header,
		Body,
		
		New "UICorner" {
			CornerRadius = UDim.new(0, 20)
		}
	}
end