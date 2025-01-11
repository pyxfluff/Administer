--// pyxfluff 2024

return {
	OnDownload = function()
		--// This will never trigger because it will not be on the official App Server
	end,

	Init = function()
		return {
			LocalTitle = "Configuration", 
			LocalDesc  = "Administer's internal Configuration page.", 
			AppVersion = "v1",
			AppContent = script.Conf
		}
	end,
}