--// Default Administer widgets

--// pyxfluff 2024

return {
	["_generator"] = "AdministerWidgetConfig-1.0",
	["Widgets"] = {
		{
			["Type"] = "SMALL_LABEL",
			["RenderFrequency"] = 999999,

			["DefaultValue"] = "Your administer version",
			["Name"] = "Administer Version",
			["Icon"] = "Welcome to Administer!",

			["OnRender"] = function(Player)
				return "1.0"
			end,
		},
		{
			["Type"] = "LARGE_BOX",
			["Name"] = "Welcome to Administer!",
			["Icon"] = "rbxassetid://18224047110",
			["OnRender"] = function(Player, UI) end,
			["BaseUIFrame"] = script.Parent.WelcomeMsg,
			["CanDiscover"] = false
		},
		{
			["Type"] = "LARGE_BOX",
			["Name"] = "Unselected",
			["Icon"] = "rbxassetid://17402667535",
			["OnRender"] = function(Player, UI) end,
			["BaseUIFrame"] = script.Parent.NotSelected,
			["CanDiscover"] = true,
		},
		{
			["Type"] = "LARGE_BOX",
			["Name"] = "Widget Removed",
			["Icon"] = "rbxassetid://18512489355",
			["OnRender"] = function(Player, UI) end,
			["BaseUIFrame"] = script.Parent.NotFound,
			["CanDiscover"] = false
		}
	},

	["Commands"] = {}
}

