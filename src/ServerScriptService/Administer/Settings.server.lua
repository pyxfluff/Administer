--// Administer
--// darkpixlz 2022-2024

local DefaultSettings = require(script.Parent:WaitForChild("Config"))["Settings"]
local Settings = {}
local DSS = game:GetService("DataStoreService")
local DS = DSS:GetDataStore("Administer-SettingsStore") -- TODO fix Merge()

local SettingsRemoteFolder = Instance.new("Folder", game.ReplicatedStorage:WaitForChild("AdministerRemotes"))
SettingsRemoteFolder.Name = "SettingsRemotes"
local RequestSettings = Instance.new("RemoteFunction", SettingsRemoteFolder)
RequestSettings.Name = "RequestSettings"
local ChangeSetting = Instance.new("RemoteFunction", SettingsRemoteFolder)
ChangeSetting.Name = "ChangeSetting"

local AdminsScript = script.Parent.Admins
local AdminIDs, GroupIDs = require(AdminsScript).Admins, require(AdminsScript).Groups

local function IsAdmin(plr)
	--if table.find(AdminIDs, plr.UserId) then
	--	return true
	--else
	--	for i, v in pairs(GroupIDs) do
	--		if plr:IsInGroup(v) then
	--			return true
	--		end
	--	end
	--end
	--return false
	return true
end

local function Load()
	local Data = DS:GetAsync("Settings")
	
	if Data then
		local Success, Mod = pcall(function()
			return game:GetService("HttpService"):JSONDecode(Data)
		end)

		if not Success then
			warn("Failed to fetch settings state - is DataStoreService operational?")
		else
			-- Settings = Merge(Mod)
			Settings = Mod
		end
	else
		local Success, Error = pcall(function()
			DS:SetAsync("Settings", game:GetService("HttpService"):JSONEncode(DefaultSettings))
		end)

		if not Success then
			warn("Failed to run first-time setup on Settings - is DataStoreService enabled?")
		else
			print("Data was not found, went to backup")
			-- Settings = Merge(DefaultSettings)
			Settings = DefaultSettings
		end
	end
end

RequestSettings.OnServerInvoke = function(p)
	if not IsAdmin(p) then
		return {false, "Your account is not authorized to complete this request."}
	else
		Load() --// Always fetch up-to-date date
		return Settings
	end
end

Load() 

local function Save(Property, Value, NoReturn)
	local Setting
	NoReturn = NoReturn or false
	-- Find setting
	for i, v in pairs(Settings) do
		if v["Name"] == Property then
			Setting = v
			--break
		end
		--return {false, "Setting was not found. This is a bug, report it!"}
	end
	
	Setting["Value"] = Value
	
	local Success, Error = pcall(function()
	local ToWrite = game:GetService("HttpService"):JSONEncode(Settings)
		DS:SetAsync("Settings", ToWrite)
	end)
	
	if not NoReturn then
		return {Success, (Error and `Something went wrong: {Error}` or Setting["RequiresRestart"] and "Success! Please restart this server to apply.") or "Success!"}
	end
end

local function Merge(Settings)
	local ShouldOverwrite = false

	for key, value in pairs(DefaultSettings) do
		if not Settings[key] then
			print("Didn't find", key, "in module!")
			Settings[key] = value
			ShouldOverwrite = true
		end
	end

	-- Reverse it to check for removed settings
	for key, value in pairs(Settings) do
		if not DefaultSettings[key] then
			print("Didn't find", key, "in Default, removing!")
			Settings[key] = nil
			ShouldOverwrite = true
		end
	end

	if ShouldOverwrite then
		local ToWrite = game:GetService("HttpService"):JSONEncode(Settings)
		DS:SetAsync("Settings", ToWrite)
	end

	return Settings
end

ChangeSetting.OnServerInvoke = function(Player, Setting, Value)
	if Settings == {} then 
		Load() 
	end

	if not IsAdmin(Player) then
		return {false, "Your account is not authorized to complete this request."}
	else
		return Save(Setting, Value)
	end
end