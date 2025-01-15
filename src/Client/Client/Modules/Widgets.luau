--// Administer (2.0.0)

--// Administer Team (2024-2025)

local Widgets = {}

local Modules = script.Parent
local Libraries = script.Parent.Parent.Libraries

local Var = require(Modules.Variables)
local Utilities = require(Modules.Utilities)


function Widgets.GetAvailableWidgets(): { Small: { {} }, Large: { {} } }
	local Widgets: { Small: { {} }, Large: { {} } } = { Small = {}, Large = {} }

	for _, Widget in Var.MainFrame:GetChildren() do
		local WidgetFolder: Folder? = Widget:FindFirstChild(".widgets")
		if not WidgetFolder or not WidgetFolder:IsA("Folder") then continue end

		--// TODO (FloofyPlasma): Make this not a pcall...
		xpcall(function()
			local Module: Instance? = WidgetFolder:FindFirstChild(".widgetconfig")
			local Config

			if Module and Module:IsA("ModuleScript") then Config = require(Module) :: any end

			if not Config then
				Utilities.Logging.Error(`{Widget.Name}: Invalid Administer Widget folder (missing .widgetconfig, please read the docs!)`)
			end

			local SplitGenerator = string.split(Config["_generator"], "-")
			if SplitGenerator[1] ~= "AdministerWidgetConfig" then
				Utilities.Logging.Error(
					`{Widget.Name}: Not a valid Administer widget configuration file (bad .widgetconfig, please read the docs!)`
				)
			end
			if SplitGenerator[2] ~= Var.WidgetConfigIdealVersion then
				Utilities.Logging.Warn(
					`{Widget.Name}: Out of date Widget Config version (current {SplitGenerator[1]} latest: {Var.WidgetConfigIdealVersion}!`
				)
			end

			for _, Widget in Config["Widgets"] do
				if Widget["Type"] == "SMALL_LABEL" then
					table.insert(Widgets["Small"], Widget)
				elseif Widget["Type"] == "LARGE_BOX" then
					table.insert(Widgets["Large"], Widget)
				else
					Utilities.Logging.Error(`{Widget.Name}: Bad widget type (not in predefined list)`)
				end
				Widget["Identifier"] = `{Widget.Name}\\{Widget["Name"]}`
				Widget["AppName"] = Widget.Name
			end
		end, function() end)
	end

	return Widgets
end


return Widgets
