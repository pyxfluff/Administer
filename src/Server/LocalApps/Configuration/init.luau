--// pyxfluff 2025
--// Example app for the 2.0 AppAPI

local Types = require(script.Parent.Parent.Core.Types)

return function(InvokeAPI: Types.InvocationAPI, _shutup)
	local RichConfig = InvokeAPI.RichConfig()

	RichConfig.AppMeta.Name = "Test App"
	RichConfig.AppMeta.Description = "This is a test app for the 2.0 API"
	RichConfig.AppMeta.Icon = require(script.Parent.Parent.Core.Icons).exclamation
	RichConfig.AppMeta.Copyright = "2025 pyxfluff"
	RichConfig.AppMeta.Version = "1.0.0"

	RichConfig.Dependencies.AppPlatform = "min:2.0.0;max:5.0.0"
	RichConfig.Dependencies.Administer = "min:2.0.0;max:2.1.0"
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
	RichConfig.Bootstrap = require(script.Conf.Run)

	print("sending construct signal")

	return InvokeAPI.Construct(RichConfig, _shutup)
end
