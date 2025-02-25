--// Administer
--// pyxfluff 2024 - 2025

local L = script.Parent.Locales:GetChildren()
L["Default"] = "en" --// Default locale here

return {
	Name = "Administer Rewrite",

	VersData = {
		Major = 2,
		Minor = 0,
		Tweak = 0,
		Extra = "Internal Testing",
		String = "2.0.0-dev",
		NoExtraData = "2.0.0",
		APIRevision = "2.0.0",
	},

	Admins = {
		--// Hardcoded admins go here.
		--// If you have no idea what a dictionary is then please just
		--// use GUI-based rank configuration, you are going to make a syntax error.
		Groups = {
			--// Change the ID in the table key here. Copy this entry to make more.
			[0] = {
				RankNumber = 255, --// Roblox group rank ID
				AdminRankID = 1, --// Administer rank ID
			},
		},
		Players = {
			[0] = {
				AdminRankID = 1,
			},
		},
	},

	--// Don't change these unless you have to, they will probably be overwritten
	--// or ignored by the system. They are just default values.
	Settings = {
		["Admins"] = {
			["CheckTime"] = {
				["Type"] = "NumberRange",
				["NR-Range"] = "15-1000",
				["NR-Bar"] = false,

				["DisplayName"] = "Admin check time",
				["Description"] = "How often to check if admins are still admins, and take away the panel if they are not.",
				["RequiresRestart"] = false,

				["Value"] = 120,
			},

			["AllowProtectedEdits"] = {
				["Type"] = "Boolean",

				["DisplayName"] = "Edit Protected Ranks",
				["Description"] = "Allows editing protected ranks (superadmin). Also allows the creation of them. Not recommended as you could potentially break your installation.",
				["RequiresRestart"] = false,

				["Value"] = false,
			},
		},

		["Interface"] = {
			--// These options will be per-user. Change default here.
			["Language"] = {
				["Description"] = "Administer's interface language. Defaults to either Administer's default or your Roblox language.",
				["SettingType"] = "Enum",

				["InputDisplayType"] = "Dropdown",
				["Value"] = L,
			},

			["AnimationSpeed"] = {
				["Type"] = "NumberRange",
				["NR-Range"] = "0-3",
				["NR-Bar"] = true,
				["NR-BarStep"] = ".1",

				["DisplayName"] = "Animation Speed",
				["Description"] = "Controls the speed of client side animations. Higher is slower. Set to 0 to disable animations.",
				["RequiresRestart"] = false,

				["Value"] = 1,
			},

			["DisableUnofficialAppWarning"] = {
				["Type"] = "Boolean",
				["DisplayName"] = "Disable unofficial app warning",
				["Description"] = "Hides the warning which says if an app/theme is external. Useful for new people, otherwise just UI clutter.",
				["RequiresRestart"] = false,

				["Value"] = false,
			},

			["EnableEditableImages"] = {
				["Type"] = "Boolean",
				["DisplayName"] = "Enable EditableImages",
				["Description"] = 'Enables EditableImage features such as app card backgrounds, app card reflectios, and other blurring effects. Does not disable "image glow". Currently nonfunctional outside of Studio due to Roblox limitations.',
				["RequiresRestart"] = false,

				["Value"] = true,
			},

			["HomepageGreeting"] = {
				["Type"] = "String",
				["DisplayName"] = "Homepage Greeting",
				["Description"] = 'This is the text that displays after the "Good morning, username!" text on the homepage.',
				["RequiresRestart"] = false,

				["Value"] = "Welcome to Administer!",
			},

			["PanelKeybind"] = {
				["Type"] = "KeyCode",
				["KC-Permitted"] = "A-Z_F1-12_1-0_Sup_Shift_Alt_Ctrl",

				["DisplayName"] = "Panel Keybind",
				["Description"] = "The key used to open the panel on keyboard-enabled devices.",
				["RequiresRestart"] = false,

				["Value"] = "Shift-Z",
			},

			["EnableClickEffects"] = {
				["Type"] = "Boolean",
				["DisplayName"] = "Enable button effects",
				["Description"] = "Increases memory usage slightly, also makes noise.",
				["RequiresRestart"] = true,

				["Value"] = true,
			},
		},

		["Apps"] = {
			["_Category"] = {
				["DisplayName"] = "Apps",
				["Color"] = "#fff",
				["Description"] = "",
			},

			["LoadDelay"] = {
				["Type"] = "Dropdown",
				["DD-Values"] = {
					"None",
					"InStudio",
					"All",
				},

				["Description"] = "Enables a 3s delay before loading any admins. Use this solve apps not initializing.",
				["RequiresRestart"] = false,

				["Value"] = "None",
			},

			["FetchAppServers"] = {
				["Type"] = "Boolean",
				["Description"] = "Disallows Administer from contacting any external app servers.",
				["RequiresRestart"] = false,

				["Value"] = false,
			},

			["LoadApps"] = {
				["Type"] = "Boolean",
				["Description"] = "Controls the ability for the server to load external apps. You shouldn't enable this unless you need a clean install or need to remove it.",
				["RequiresRestart"] = true,

				["Value"] = true,
			},
		},

		["Accessibility"] = {
			["ChatCommand"] = {
				["Type"] = "Boolean",
				["Description"] = "Enables an /adm command to open Administer.",
				["RequiresRestart"] = false,

				["Value"] = true,
			},

			["DisplayHours"] = {
				["Type"] = "Boolean",
				["Description"] = "If enabled, hours will be displayed on all timestamps, may be ignored in some.",
				["RequiresRestart"] = false,

				["Value"] = false,
			},

			["ShortNumberDecimals"] = {
				["Type"] = "NumberRange",
				["NR-Bar"] = true,
				["NR-Range"] = "1-5",

				["Description"] = "How many decimals to display next to short numbers. 2 -> 12.34k, 3 -> 12.345k, etc.",
				["RequiresRestart"] = false,

				["Value"] = 2,
			},

			["TopbarPlus"] = {
				["Type"] = "Boolean",
				["Description"] = "Enables a Topbar+ section that you can launch Administer and apps from.",
				["RequiresRestart"] = true,

				["Value"] = false,
			},

			["MobileOpenGesture"] = {
				["Type"] = "Dropdown",
				["DD-Values"] = {
					"disabled",
					"small",
					"regular",
					"medium",
					"large",
					"extralarge",
				},

				["Description"] = "Controls how big the mobile open gesture is from the right side. If the value is disabled you will need either the chat command or Topbar+ setting enabled.",
				["RequiresRestart"] = false,

				["Value"] = "regular",
			},
		},

		["Miscellaneous"] = {
			["EditableImageRenderingDelay"] = {
				["Type"] = "Boolean",
				["Description"] = "Enables a task.wait() call in EditableImage rendering calls. Can help reduce significant lag if present. WARNING: Makes client loading SIGNIFICANTLY slower.",
				["RequiresRestart"] = false,

				["Value"] = false,
			},

			["NotificationCloseTimer"] = {
				["Type"] = "Number",
				["Description"] = "Default waiting time to close the notification at. Can be overridden by notifications.",
				["RequiresRestart"] = false,

				["Value"] = 15,
			},

			["SandboxMode"] = {
				["Type"] = "Boolean",
				["DisplayName"] = "sudo",
				["Description"] = "(studio-only) Gives all people who join the game rank 1 (superadmin). Useful for setting up. Once your ranks are set up, you should turn this off. (also known as sudo)",
				["RequiresRestart"] = true,

				["Value"] = true,
			},

			["Verbose"] = {
				["Type"] = "Boolean",
				["Value"] = true,
				["Description"] = "Prints out general log data, useful for technical users or debugging. If enabled, it'll appear in the Log too.",
				["RequiresRestart"] = false,
			},
		},
	},

	BetaOptIns = {},

	Webhooks = {},
}
