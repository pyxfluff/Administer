-- DO NOT CHANGE THIS. Make modifications in the Settings menu.

return {
	Name = "Administer",
	
	VersData = {
		Major = 1,
		Minor = 1,
		Tweak = 0,
		Extra = "",
		String = "1.1.0"
	},
	
	Version = "1.1.0",
	
	Settings = {
		["AdminCheck"] = {
			["Name"] = "AdminCheck",
			["Value"] = 120,
			["MinValue"] = 60,
			["Description"] = "How often to check if admins are still admins, and take away the panel if they are not.",
			["RequiresRestart"] = false
		},
		["AnimationSpeed"] = {
			["Name"] = "AnimationSpeed",
			["Value"] = 1,
			["Description"] = "Controls the speed of client side animations. Higher is slower. Set to 0 to disable animations.",
			["RequiresRestart"] = false
		},
		["AppLoadDelay"] = {
			["Name"] = "AppLoadDelay",
			["Value"] = "None",
			["Description"] = "Enables a 3s delay before loading any admins. Use this solve apps not initializing. Value MUST be \"InStudio\", \"All\", or \"None\".",
			["RequiresRestart"] = false
		},
		["DisableAppServerFetch"] = {
			["Name"] = "DisableAppServerFetch",
			["Value"] = false,
			["Description"] = "Disallows Administer from contacting any external app servers.",
			["RequiresRestart"] = false
		},
		["DisableApps"] = {
			["Name"] = "DisableApps",
			["Value"] = false,
			["Description"] = "Turn this on to disallow applications from loading at runtime. You shouldn't enable this unless you need a clean install or need to remove it.",
			["RequiresRestart"] = true
		},
		["DisableUnofficialAppWarning"] = {
			["Name"] = "DisableUnofficialAppWarning",
			["Value"] = false,
			["Description"] = "Hides the warning which says if a plugin is external. Useful for new people, otherwise just UI clutter.",
			["RequiresRestart"] = false
		},
		["DisplayHours"] = {
			["Name"] = "DisplayHours",
			["Value"] = false,
			["Description"] = "If enabled, hours will be displayed on all timestamps, may be ignored in some.",
			["RequiresRestart"] = false
		},
		["EditableImageRenderingDelay"] = {
			["Name"] = "EditableImageRenderingDelay",
			["Value"] = false,
			["Description"] = "Enables a task.wait() call in EditableImage rendering calls. Can help reduce significant lag if present. WARNING: Makes client loading SIGNIFICANTLY slower. (disabled globally)",
			["RequiresRestart"] = false
		},
		["EnableEditableImages"] = {
			["Name"] = "EnableEditableImages",
			["Value"] = true,
			["Description"] = "Enables EditableImage features such as app card backgrounds, app card reflectios, and other blurring effects. Does not disable \"image glow\". Currently nonfunctional outside of Studio due to Roblox limitations.",
			["RequiresRestart"] = false
		},
		["HomepageGreeting"] = {
			["Name"] = "HomepageGreeting",
			["Value"] = "Welcome to Administer!",
			["Description"] = "This is the text that displays after the \"Good morning, username!\" text on the homepage.",
			["RequiresRestart"] = false
		},
		["NotificationCloseTimer"] = {
			["Name"] = "NotificationCloseTimer",
			["Value"] = 15,
			["Description"] = "Default waiting time to close the notification at. Can be overridden by notifications.",
			["RequiresRestart"] = false
		},
		["PanelKeybind"] = {
			["Name"] = "PanelKeybind",
			["Value"] = "Z",
			["Description"] = "The key used to open the panel on keyboard-enabled devices.",
			["RequiresRestart"] = false
		},
		["RequireShift"] = {
			["Name"] = "RequireShift",
			["Value"] = true,
			["Description"] = "Require shift to be held down while keybind is pressed to open/close panel.",
			["RequiresRestart"] = false
		},
		["SandboxMode"] = {
			["Name"] = "SandboxMode",
			["Value"] = true,
			["Description"] = "(studio-only) Gives all people who join the game rank 1 (superadmin). Useful for setting up. Once your ranks are set up, you should turn this off. (also known as sudo)",
			["RequiresRestart"] = true
		},
		["SettingsCheckTime"] = {
			["Name"] = "SettingsCheckTime",
			["Value"] = 30,
			["Description"] = "How often to check for updated settings.",
			["RequiresRestart"] = false
		},
		["ShortNumberDecimals"] = {
			["Name"] = "ShortNumberDecimals",
			["Value"] = 2,
			["Description"] = "How many decimals to display next to short numbers. 2 -> 12.34k, 3 -> 12.345k, etc.",
			["RequiresRestart"] = false
		},
		["TopbarPlus"] = {
			["Name"] = "TopbarPlus",
			["Value"] = false,
			["Description"] = "Enables a Topbar+ section that you can launch Administer and apps from.",
			["RequiresRestart"] = true
		},
		["Verbose"] = {
			["Name"] = "Verbose",
			["Value"] = true,
			["Description"] = "Prints out general log data, useful for technical users or debugging. If enabled, it'll appear in the Log too.",
			["RequiresRestart"] = false
		},
		["EnableClickEffects"] = {
			["Name"] = "EnableClickEffects",
			["Value"] = true,
			["Description"] = "Enable effects on buttons. Increases memory usage slightly, also makes noise.",
			["RequiresRestart"] = true
		}
	},

	
	BetaOptIns = {},
	
	Webhooks = {},
	
}