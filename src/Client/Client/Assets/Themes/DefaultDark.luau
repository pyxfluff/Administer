-- pyxfluff 2024

return {
	Meta = {
		Name = "Default",
		Author = "pyxfluff",
		Description = "Administer's classic look.",

		AdministerVersionsSupported = { "*" },
		IsDark = true,

		IconPack = {
			Name = "fli-round",
			DownloadFrom = {
				ServerURL = "https://administer.notpyx.me",
				AssetID = 4,
			},
		},
	},

	PrimaryBG = {
		--// Used for the main panel BG, command bar, notifications, ...
		Color = Color3.fromRGB(8, 8, 11),
		UseAcrylic = true,
		Transparency = 0.2,
	},

	--// Card backgrounds, popups, etc.
	Primary = {
		Color = Color3.fromRGB(11, 12, 17),
		Transparency = 0.3,
	},

	Secondary = {
		Color = Color3.fromRGB(8, 8, 13),
		Transparency = 0,
	},

	Tertiary = {
		Color = Color3.fromRGB(40, 40, 52),
		Transparency = 0,
	}, --// Outlines mostly

	Quaternary = {
		Color = Color3.fromRGB(4, 4, 6),
		Transparency = 0, --// I don't know what to do here, SideData on widgets uses a gradient value so ?
	},

	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(210, 210, 210),

	Accent = {
		Accent1 = Color3.fromHex("2548C2"),
		Accent2 = Color3.fromRGB(64, 96, 161),
		Accent3 = Color3.fromRGB(34, 37, 60),
	},

	Buttons = {
		--// Normal Button types
		Primary = {
			Background = Color3.fromRGB(40, 40, 52),
			Transparency = 0.5,
			Text = Color3.fromRGB(255, 255, 255),
		},

		--// HeavyButton type
		Secondary = {
			Background = Color3.fromRGB(8, 8, 13),
			Transparency = 0,
			Text = Color3.fromRGB(255, 255, 255),
		},

		--// White HeavyButtons
		Tertiary = {
			Background = Color3.fromRGB(255, 255, 255),
			Transparency = 0,
			Text = Color3.fromRGB(0, 0, 0),
		},
	},

	Header = { --// Both COlor and Transparency take Sequences
		Color = Color3.fromRGB(),

		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.62, 0.306),
			NumberSequenceKeypoint.new(1, 1),
		}),
	},

	Good = Color3.fromRGB(56, 218, 111),
	Bad = Color3.fromRGB(255, 72, 72),
}
