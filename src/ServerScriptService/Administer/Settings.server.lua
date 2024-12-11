--/ Administer

--// PyxFluff 2022-2024

local DefaultSettings = require(script.Parent:WaitForChild("Config"))["Settings"]
local Settings = {}
local DSS = game:GetService("DataStoreService")

local DS = DSS:GetDataStore("Administer_Settings")
local AdminsDS= DSS:GetDataStore("Administer_Admins")

local SettingsRemoteFolder = Instance.new("Folder", game.ReplicatedStorage:WaitForChild("AdministerRemotes"))
SettingsRemoteFolder.Name = "SettingsRemotes"
local RequestSettings = Instance.new("RemoteFunction", SettingsRemoteFolder)
RequestSettings.Name = "RequestSettings"
local ChangeSetting = Instance.new("RemoteFunction", SettingsRemoteFolder)
ChangeSetting.Name = "ChangeSetting"

local AdminsScript, AdminIDs, GroupIDs

xpcall(function()
	--// Legacy "admins". Support may be removed.
	AdminsScript = require(script.Parent.Admins)
	
	AdminIDs, GroupIDs = AdminsScript.Admins, AdminsScript.Groups
end, function()
	print("[Administer]: Restarting the settings process from non-fatal error")
end)


local function IsAdmin(Player: Player)
	if Settings["SandboxMode"]["Value"] == true and game:GetService("RunService"):IsStudio() or game.GameId == 3331848462 then
		return {
			["IsAdmin"] = true, 
			["Reason"] = "Sandbox mode enabled as per settings",
			["RankID"] = 1,
			["RankName"] = "Admin"
		}
	end

	local RanksIndex = AdminsDS:GetAsync("CurrentRanks")

	if table.find(AdminIDs, Player.UserId) ~= nil then
		return {
			["IsAdmin"] = true, 
			["Reason"] = "Found in overrides",
			["RankID"] = 1,
			["RankName"] = "Admin"
		}
	else
		for i, v in GroupIDs do
			if Player:IsInGroup(v) then
				return {
					["IsAdmin"] = true, 
					["Reason"] = "Found in overrides",
					["RankID"] = 1,
					["RankName"] = "Admin"
				}
			end
		end
	end

	local _, Result = xpcall(function()
		if RanksIndex.AdminIDs[tostring(Player.UserId)] ~= nil then
			return {
				["IsAdmin"] = true,
				["Reason"] = "User is in the ranks index", 
				["RankID"] = RanksIndex.AdminIDs[tostring(Player.UserId)].AdminRankID,
				["RankName"] = RanksIndex.AdminIDs[tostring(Player.UserId)].AdminRankName
			}
		else
			return {
				["IsAdmin"] = false
			}
		end
	end, function(er)
		--// Safe to ignore an error
		-- Print(er, "probably safe to ignore but idk!")

		return {
			["IsAdmin"] = false
		}
	end)

	if Result["IsAdmin"] then
		return Result
	end

	--if RanksData["IsAdmin"] then
	--	return true, "Data based on settings configured by an admin.", RanksData["RankId"], RanksData["RankName"]
	--end

	for ID, Group in RanksIndex.GroupAdminIDs do
		ID = string.split(ID, "_")[1]
		if not Player:IsInGroup(ID) then continue end

		if Group["RequireRank"] then
			if Player:GetRankInGroup(ID) ~= tonumber(Group["RankNumber"]) then continue end

			return {
				["IsAdmin"] = true,
				["Reason"] = "Data based on group rank",
				["RankID"] = Group["AdminRankID"],
				["RankName"] = Group["AdminRankName"]
			}
		else
			return {
				["IsAdmin"] = true,
				["Reason"] = "User is in group",
				["RankID"] = Group["AdminRankID"],
				["RankName"] = Group["AdminRankName"]
			}
		end
	end

	return {
		["IsAdmin"] = false,
		["Reason"] = "User was not in the admin index",
		["RankID"] = 0,
		["RankName"] = "NonAdmin"
	}
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
			
			--// Migration
			--// Hopefully removal TODO.. settings v2
			
			if not Settings["ChatCommand"] then
				Settings["ChatCommand"] = {
					["Name"] = "ChatCommand",
					["Value"] = true,
					["Description"] = "Enables an /adm command to open Administer.",
					["RequiresRestart"] = false
				}
			end
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
	local R = IsAdmin(p)
	
	if not R["IsAdmin"] then
		return {false}
	else
		Load() --// Always fetch up-to-date date
		return Settings
	end
end

local function ResetSettings()
	DS:RemoveAsync("Settings")
end

Load() 

local function Save(Property, Value, NoReturn)
	local Setting
	NoReturn = NoReturn or false
	-- Find setting
	for i, v in Settings do
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

	local R = IsAdmin(Player)

	if not R["IsAdmin"] then
		return {false}
	else
		return Save(Setting, Value, false)
	end
end