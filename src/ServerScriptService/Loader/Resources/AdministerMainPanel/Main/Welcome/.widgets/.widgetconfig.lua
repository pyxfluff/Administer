return {
	["_generator"] = "AdministerWidgetConfig-1.0",
	["Widgets"] = {
		{
			["Type"] = "SMALL_LABEL",
			["RenderFrequency"] = 1, --// MUST be higher than .5
			
			["DefaultValue"] = "0", --// This value will be used in the previewer before it is selected
			["Name"] = "Test Widget",
			["Icon"] = "rbxassetid://0",
			
			["OnRender"] = function(Player)
				-- MUST return a string or number to not throw an error
				print("Rendering...")
				
				return math.random(1,10000)
			end,
		},
		{
			["Type"] = "LARGE_BOX",
			["Name"] = "Test Large Box",
			["Icon"] = "rbxassetid://0",
			["OnRender"] = function(Player, UI)
				-- Can do anything, returning will not do anything...
			end,
			["BaseUIFrame"] = script.Parent.ExampleWidget
		},
		{
			["Type"] = "LARGE_BOX",
			["Name"] = "Test Large Box: The Second",
			["Icon"] = "rbxassetid://17013216608",
			["OnRender"] = function(Player, UI)
				-- Can do anything, returning will not do anything...
			end,
			["BaseUIFrame"] = script.Parent.ExampleWidget2
		}
	}
}


