local UI = require(script.Parent.Parent.Modules.UI.init)
local New = UI.New
local Event = UI.Event

--local ThemeColors = require(game.ServerScriptService.Loader.Core.Variables).ThemeColors.DefaultDark

local function CreatePills(Info: {{Icon: string, Title: string}})
	local Pills = {}
	
	for _, Pill: {Icon: string, Title: string} in Info do
		local Pill = New "Frame" {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(11, 12, 17),
			Size = UDim2.new(0.32, 0, 0.4, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.2,
			Position = UDim2.new(0.0307801, 0, 0.561521, 0),

			New "ImageLabel" {
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.0550893, 0, 0.136364, 0),
				Image = Pill.Icon,
				Size = UDim2.new(0.225771, 0, 0.727273, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
			},

			New "TextLabel" {
				TextWrapped = true,
				BorderSizePixel = 0,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Position = UDim2.new(0.327, 0, 0, 0),
				Name = "AppName",
				TextSize = 14,
				Size = UDim2.new(0.618142, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = Pill.Title,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,

				New "UITextSizeConstraint" {
					MaxTextSize = 15,
				},

			},

			New "UICorner" {
				CornerRadius = UDim.new(0, 30),
			},

			New "UIStroke" {
				Color = Color3.fromRGB(40, 40, 52),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
		}
		
		table.insert(Pills, Pill)
	end
	
	return Pills
end

return function(PillInfo: {{Icon: string, Title: string}}): (Frame)
	local Pages = New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0.966503, 0, 0.421095, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Name = "Pages",
		Position = UDim2.new(0.0175643, 0, 0.528433, 0),

		New "UIGridLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellSize = UDim2.new(0.32, 0, 0.4, 0),
		},
	}
	
	for _, Pill in CreatePills(PillInfo) do
		Pill.Parent = Pages
	end
	
	return New "Frame" {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 12),
		Size = UDim2.new(0.941464, 0, 0.4, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.35,
		Name = `Rank`,
		Position = UDim2.new(0.836578, 0, -0.0268222, 0),

		New "UICorner" {
			CornerRadius = UDim.new(0, 30),
		},
		
		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.new(0.0400141, 0, 0.0641739, 0),
			Name = "RankName",
			TextSize = 14,
			Size = UDim2.new(0.933125, 0, 0.23263, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "Wowie remember to fix me Pyx.",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 25,
			},
		},
		
		New "TextLabel" {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Position = UDim2.new(0.0400141, 0, 0.296804, 0),
			Name = "Info",
			TextSize = 14,
			Size = UDim2.new(0.933125, 0, 0.176478, 0),
			TextColor3 = Color3.fromRGB(71, 71, 71),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "Pyx, fix me",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,

			New "UITextSizeConstraint" {
				MaxTextSize = 15,
			},
		},
		
		New "ImageButton" {
			ImageColor3 = Color3.fromRGB(71, 71, 71),
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Fit,
			Position = UDim2.new(0.915005, 0, 0.104638, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Name = "Configure",
			Image = "rbxassetid://9368570772",
			Size = UDim2.new(0.0620401, 0, 0.14368, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
		},
		
		New "UIStroke" {
			Color = Color3.fromRGB(40, 40, 52),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},
		
		Pages
	}
end