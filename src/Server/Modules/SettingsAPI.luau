-- SettingsAPI V2
-- Part of Administer
-- metatablecat 2024

local SettingsAPI = {}

export type EnumPair = {
	Key: string,
	Value: number,
}

type Connection = { Disconnect: (Connection) -> () }

type Setting = {
	Name: string,
	DisplayName: string,
	Description: string,
	SortOrder: number,
	EditorType: string, -- not type enforcing this so i dont have to keep changing this
	Save: (Setting) -> (),
	Group: SettingsGroup,
} & ({
	Type: "boolean",
	DefaultValue: boolean,
	Value: boolean,
} | {
	Type: "string",
	DefaultValue: string,
	Value: string,

	Constraints: {
		TrimInput: boolean,
		LuaPattern: string,
	},
} | {
	Type: "enum",
	DefaultValue: EnumPair,
	Value: EnumPair,

	Constraints: {
		Values: { EnumPair },
	},
} | {
	Type: "int" | "float",
	DefaultValue: number,
	Value: number,
	Constraints: {
		Min: number,
		Max: number,
		Step: number,
		DecimalPoints: number, -- 0-14, always 0 for ints
	},
})

type ValidOutTypes = boolean | string | EnumPair | number

export type SettingsGroup = {
	Name: string,
	DisplayName: string,
	Description: string,
	Color: Color3,
	SortOrder: number,

	Settings: { [string]: Setting },
	Changed: (SettingsGroup, key: string | { string }, fn: (Setting) -> ()) -> Connection,
	With: (SettingsGroup, key: string | { string }, fn: (Setting, number) -> ()) -> (number?) -> (),
	Get: (SettingsGroup, key: string | { string }) -> Setting | { [string]: Setting },

	Save: (SettingsGroup, key: string, value: ValidOutTypes) -> (),
	BulkSaveRaw: (SettingsGroup, values: { [string]: ValidOutTypes }) -> (), -- idea is to prevent multiple set calls and write directly
	BulkSave: (SettingsGroup, value: { Setting }) -> (),
}

-- todo: use generics when the typing engine isn't as anoying about recursive generics
export type Settings = {
	Name: string,
	Groups: { [string]: SettingsGroup },
	GetCategory: (string) -> { [string]: Setting },
	-- DataStore: DataStore -- maybe in the future :3
}

--[[
	Name: string,
	Groups: {[string]: SettingGroupDef}
]]

-- TODO: move this to a seperate module, putting it here for now
local function tassert<T>(v: T, name: string, expType: string, optional: true?): T
	if optional and not v then return v end

	local t = typeof(v)
	if t ~= expType then error(`property {name} expects {expType}, got {t}`) end
	return v
end

local function keyToSettings(self: SettingsGroup, keys: string | { string }): { [string]: Setting }
	if type(keys) == "string" then keys = { string } end
	local capturedSettings: { [string]: Setting } = {}

	for _, key in keys :: { string } do
		local setting = self.Settings[key]
		if not setting then error(`setting {key} is not a member of {self.Name}`) end
		capturedSettings[setting.Name] = setting
	end

	return capturedSettings
end

local function settingGroup(settingConfig)
	local group = {}
	group.Name = tassert(settingConfig.Name, "Name", "string")
	group.DisplayName = tassert(settingConfig.DisplayName, "DisplayName", "string", true) or group.Name
	group.Description = tassert(settingConfig.Description, "Description", "string", true) or ""
	group.Color = tassert(settingConfig.Color, "Color", "Color3", true) or Color3.new(1, 1, 1) -- TODO: maybe a different color here?
	group.SortOrder = tassert(settingConfig.Sortorder, "SortOrder", "number", true) or 0
	group.Settings = {}

	function group.Changed(self: SettingsGroup, key: string | { string }, fn: (Setting) -> ()): Connection
		error("NotImplementedException") -- we need a signaller before implementing this this
	end

	function group.With(self: SettingsGroup, keys: string | { string }, fn: (Setting, number) -> ()): (number?) -> ()
		-- key assertion, also captures each key we need to work with
		local capturedSettings = keyToSettings(self, keys)

		return function(delta: number?)
			delta = delta or os.time()
			for _, setting in capturedSettings do
				-- todo: should this run concurrently?
				fn(setting, delta :: number)
			end
		end
	end

	function group.Get(self: SettingsGroup, keys: string | { string })
		local isString = type(keys) == "string"
		local capturedSettings = keyToSettings(self, keys)
		return if isString then capturedSettings[keys] else capturedSettings
	end

	function group.Save(self: SettingsGroup, key: string, value: ValidOutTypes)
		writeValueRaw(self, key, value)
		-- signal dispatcher here :)
	end
end

local function parseSettings(out: { [string]: SettingsGroup }, settingGroups)
	for k, group in settingGroups do
		out[k] = settingGroup(group)
	end
end

function SettingsAPI.new(description: { [string]: any }): Settings
	local settingGroup = {} :: Settings
	settingGroup.Name = tassert(description.Name, "Name", "string")
	settingGroup.Groups = {}

	function settingGroup.GetCategory(self: Settings, categoryName: string): { [string]: Setting }
		local group = self.Groups[categoryName]
		if not group then error(`group {categoryName} is not a settings group of {self.Name}`) end

		return group.Settings
	end

	parseSettings(settingGroup.Groups, tassert(settingGroup.Groups, "Groups", "table"))
	return settingGroup
end
