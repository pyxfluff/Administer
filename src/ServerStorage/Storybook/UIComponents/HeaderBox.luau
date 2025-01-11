local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

local ImageButton = require(script.Parent.ImageButton)
--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

return function(Header: string, Cards: {Frame}, ButtonClick: () -> ()): (Frame)
	local Button = ImageButton("rbxassetid://14608897773", nil, UDim2.fromScale(0.94, 0.21), ButtonClick)
	Button.Size = UDim2.fromScale(0.04, 0.5)
	
	local BodyFrame = New "ScrollingFrame" {
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 1, 0),
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(0.943259, 0, 0.847792, 0),
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarThickness = 4,
		ClipsDescendants = false,
		Name = "Content",
		Position = UDim2.new(0.0287112, 0, 0.126773, 0),

		New "UIGridLayout" {
			StartCorner = Enum.StartCorner.BottomLeft,
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellSize = UDim2.new(0.95, 0, 0.4, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		},
	}
	
	for _, Card in Cards do
		Card.Parent = BodyFrame
	end
	
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(11, 12, 17),
		Size = UDim2.new(0.483448, 0, 0.947527, 0),
		ClipsDescendants = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Name = Header,
		Position = UDim2.new(0.0128477, 0, 0.00711073, 0),

		New "UICorner" {
			CornerRadius = UDim.new(0, 24),
		},

		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(11, 12, 17),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextStrokeColor3 = Color3.fromRGB(35, 35, 35),
			Position = UDim2.new(0.028, 0, 0.011, 0),
			Name = "Header",
			TextSize = 14,
			Size = UDim2.new(0.943, 0, 0.084, 0),
			ZIndex = 5,
			TextColor3 = Color3.fromRGB(185, 185, 185),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Text = "",
			BackgroundTransparency = 0.5,

			New "UITextSizeConstraint" {
				MaxTextSize = 20,
			},

			New "TextLabel" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(11, 12, 17),
				FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextStrokeColor3 = Color3.fromRGB(35, 35, 35),
				Position = UDim2.new(0.0234545, 0, -0.0208645, 0),
				Name = "TLabel",
				TextSize = 14,
				Size = UDim2.new(0.976545, 0, 1, 0),
				TextColor3 = Color3.fromRGB(185, 185, 185),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Text = Header,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 20,
				},
			},

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.934344, 0, 0.192102, 0),
				Name = "Spinner",
				Image = "rbxassetid://11102397100",
				Size = UDim2.new(0.0460349, 0, 0.561648, 0),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
				Visible = false,
				ZIndex = 101,
				BackgroundTransparency = 1,

			},
			
			Button,

			New "UICorner" {
				CornerRadius = UDim.new(0, 16),
			},

			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
		},

		BodyFrame,

		New "Frame" {
			Active = true,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(11, 12, 17),
			Selectable = true,
			Size = UDim2.new(0.943259, 0, 0.861067, 0),
			ClipsDescendants = true,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			Visible = false,
			Name = "Background",
			Position = UDim2.new(0.0287112, 0, 0.111714, 0),
			ZIndex = 0,
			SelectionGroup = true,

			New "UICorner" {
				CornerRadius = UDim.new(0, 25),
			},

			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
		},
	}
end