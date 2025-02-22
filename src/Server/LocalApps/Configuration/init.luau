--// pyxfluff 2025
--// Example app for the 2.0 AppAPI

local Types = require(script.Parent.Parent.Core.Types)

return function(InvokeAPI: Types.InvocationAPI)
	local RichConfig = InvokeAPI.RichConfig()

	RichConfig.AppMeta.Name = "Test App"
	RichConfig.AppMeta.Description = "This is a test app for the 2.0 API"
	RichConfig.AppMeta.Icon = require(script.Parent.Parent.Core.Icons).exclamation
	RichConfig.AppMeta.Copyright = "2025 pyxfluff"
	RichConfig.AppMeta.Version = "1.0.0"

	RichConfig.Dependencies.AppAPI = "2.0"
	RichConfig.Dependencies.Administer = "2.0.0"
	RichConfig.Dependencies.SettingsAPI = "1.0"
	RichConfig.Dependencies.AdministerModules = {
		{
			Type = "SERVER",
			Name = "AdminRunner",
		},
		{
			Type = "CLIENT",
			Name = "RenderUI",
		},
	} :: any

	RichConfig.UIConstructor = require(script.Conf.UI)
	RichConfig.OnExecute = require(script.Conf.Run)

	return InvokeAPI.Construct(RichConfig)
end
