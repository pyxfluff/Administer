-- pyxfluff 2024

return {
	Meta = {
		Name = "Default",
		Author = "pyxfluff",
		Description = "Administer's classic look.",

		AdministerVersionsSupported = "min:2.0.0;max:25.0.1",
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
		UseAcrylic = false,
		Transparency = 0,
	},

	--// Card backgrounds, popups, etc.
	Primary = {
		Color = Color3.fromRGB(11, 12, 17),
		Transparency = 0.3,
	},

	--// Cards inside of those
	Secondary = {
		Color = Color3.fromRGB(8, 8, 13),
		Transparency = 0,
	},

	--// Outlines mostly
	Tertiary = {
		Color = Color3.fromRGB(40, 40, 52),
		Transparency = 0,
	},
	
	--// Extra gradients on darker cards
	Quaternary = {
		Color = Color3.fromRGB(4, 4, 6),
		Transparency = 0, --// I don't know what to do here, SideData on widgets uses a gradient value so ?
	},

	Headers = Color3.fromRGB(255, 255, 255),
	NormalText = Color3.fromRGB(210, 210, 210),
	SubText = Color3.fromRGB(173, 173, 173),

	Accent = {
		Accent1 = Color3.fromHex("2548C2"), --// Main accent highlight color
		Accent2 = Color3.fromRGB(255, 131, 23), --// "Hot"
		Accent3 = Color3.fromRGB(34, 37, 60), --// Typically for gradients with the normal accent color
	},

	Buttons = {
		--// Normal Buttons
		Primary = {
			Background = Color3.fromRGB(40, 40, 52),
			Transparency = 0.5,
			Text = Color3.fromRGB(255, 255, 255),
		},
	},

	Header = { --// Both COlor and Transparency take Sequences
		Color = Color3.fromRGB(25, 28, 39),

		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.62, 0.306),
			NumberSequenceKeypoint.new(1, 1),
		}),
	},

	Good = Color3.fromRGB(56, 218, 111),
	Bad = Color3.fromRGB(255, 72, 72),
	
	OnRun = function()
		
	end,
}
