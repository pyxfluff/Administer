-- DO NOT CHANGE THIS. Make modifications in the Settings menu.

return {
	Name = "Administer",
	
	VersData = {
		Major = 1,
		Minor = 0,
		Tweak = 0,
		Extra = "",
		String = "1.0"
	},
	
	Version = "1.0",
	
	Settings = {
		{
			["Name"] = "AdminCheck",
			["Value"] = 120,
			["MinValue"] = 60,
			["Description"] = "How often to check if admins are still admins, and take away the panel if they are not.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "AnimationSpeed",
			["Value"] = 1,
			["Description"] = "Controls the speed of client side animations. Higher is slower. Set to 0 to disable animations.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "AppLoadDelay",
			["Value"] = "None",
			["Description"] = "Enables a 3s delay before loading any admins. Use this solve apps not initializing. Value MUST be \"InStudio\", \"All\", or \"None\". Doesnt work rn",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "DisableAppServerFetch",
			["Value"] = false,
			["Description"] = "Disallows Administer from contacting any external app servers.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "DisableApps",
			["Value"] = false,
			["Description"] = "Turn this on to disallow applications from loading at runtime. You shouldn't enable this unless you need a clean install or need to remove it.",
			["RequiresRestart"] = true
		},
		{
			["Name"] = "DisableUnofficialAppWarning",
			["Value"] = false,
			["Description"] = "Hides the warning which says if a plugin is external. Useful for new people, otherwise just UI clutter.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "DisplayHours",
			["Value"] = false,
			["Description"] = "If enabled, hours will be displayed on all timestamps, may be ignored in some.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "HomepageGreeting",
			["Value"] = "Welcome to Administer!",
			["Description"] = "This is the text that displays after the \"Good morning, username!\" text on the homepage.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "NotificationCloseTimer",
			["Value"] = 15,
			["Description"] = "Default waiting time to close the notification at. Can be overridden by notifications.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "PanelKeybind",
			["Value"] = "Z",
			["Description"] = "The key used to open the panel on keyboard-enabled devices.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "RequireShift",
			["Value"] = true,
			["Description"] = "Require shift to be held down while keybind is pressed to open/close panel.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "SandboxMode",
			["Value"] = true,
			["Description"] = "Only respected in Studio. Gives all people who join the game rank 1 (superadmin). Useful for setting up. Once your ranks are set up, you should turn this off.",
			["RequiresRestart"] = true
		},
		{
			["Name"] = "SettingsCheckTime",
			["Value"] = 15,
			["Description"] = "How often to check for updated settings.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "ShortNumberDecimals",
			["Value"] = 2,
			["Description"] = "How many decimals to display next to short numbers. 2 -> 12.34k, 3 -> 12.345k, etc.",
			["RequiresRestart"] = false
		},
		{
			["Name"] = "TopbarPlus",
			["Value"] = false,
			["Description"] = "Enables a Topbar+ section that you can launch Administer and apps from.",
			["RequiresRestart"] = true
		},
		{
			["Name"] = "Verbose",
			["Value"] = true,
			["Description"] = "Prints out general log data, useful for technical users or debugging. If enabled, it'll appear in the Log too.",
			["RequiresRestart"] = false
		}
	},

	
	["BetaOptIns"] = {},
	
	["Webhooks"] = {},
	
}