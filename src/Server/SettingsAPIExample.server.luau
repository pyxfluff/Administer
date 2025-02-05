local SettingsAPI = require(script.Parent.Loader.Core.Settings)

local Settings = SettingsAPI.new({
	-- if you use an array here rather than keys, luau will sort it in the order of definition.
	-- dictionaries dont sort that intuitively
	["_SettingsMeta"] = {
		["Name"] = "Administer",
	},

	["General"] = {
		["DisplayName"] = "General",
		["Color"] = "#fff",
		["Description"] = "Configure general settings.",

		["AnimationSpeed"] = {
			["DisplayName"] = "Animation Speed",
			["Description"] = "Controls the speed of animations.",

			["SettingType"] = "float",
			["SettingDisplayType"] = "InputBox",

			["Value"] = {
				["Default"] = 1,
			},
		},
		["Language"] = {
			["Description"] = "Administer's UI language.",
			["SettingType"] = "Enum",

			["InputDisplayType"] = "Dropdown",
			["Value"] = {
				"English",
				"Spanish",
				"French",

				["Default"] = "English",
			},
		},
	},

	["Interface"] = {
		["_CategoryOpts"] = {
			["DisplayName"] = "Interface options",
			["Color"] = "#000",
			["Description"] = "Change the interface.",
		},

		["InterfaceScale"] = {
			["Description"] = "The scale of the interface.",
			["SettingType"] = "float",
			["InputDisplayType"] = "Slider",

			["Value"] = {
				["Default"] = 1,
				["Min"] = 0.25,
				["Max"] = 5,
				["Step"] = 1,
			},
		},
	},
})

--// Connect to a SettingChanged event
Settings.Changed({ "AnimationSpeed", "InterfaceScale" }, function(Setting)
	print(`{Setting.Name} has changed and is now {Setting.Value}!`)
end) --// -> { Disconnect: function }

local Connection = Settings.with({ "Language" }, function(Setting, Time)
	print(`{Setting.Value == "English" and "Hello" or "Hola!"} The current Unix time is {Time}.`)
end) --// -> function

Connection(os.time())

local LotsOfValues = Settings.Get({ "Language", "InterfaceScale" })
print(LotsOfValues) --// -> { Language: English, InterfaceScale: 1 }

print(Settings.Get("AnimationSpeed")) --// -> 1 -- how is this different to getRaw

local Category = Settings.GetCategory("Interface") --// -> { InterfaceScale: 1 }

-----------------------------------

local SomethingElse = SettingsAPI.GetRaw({ "Administer.Interface.InterfaceScale" }) --// -> 1
