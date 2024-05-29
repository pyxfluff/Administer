local t = tick()
--[[

# Administer #

Build 1.0 Beta 5 - 2022-2024

https://github.com/darkpixlz/Administer

The following code is free to use, look at, and modify. 
Please refrain from modifying core functions as it can break everything. It's very fragile in general.
All modifications can be done via apps/plugins.

]]

------
-- // Services
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")
local GroupService = game:GetService("GroupService")


-- // Initialize Folders
local Remotes = Instance.new("Folder")
Remotes.Name, Remotes.Parent = "AdministerRemotes", ReplicatedStorage

local PluginsRemotes = Instance.new("Folder")
PluginsRemotes.Name, PluginsRemotes.Parent = "AdministerPluginRemotes", Remotes

local NewPlayerClient = Instance.new("RemoteEvent")
NewPlayerClient.Parent = Remotes
NewPlayerClient.Name = "NewPlayerClient"

local CheckForUpdatesRemote = Instance.new("RemoteEvent")
CheckForUpdatesRemote.Parent, CheckForUpdatesRemote.Name = Remotes, "CheckForUpdates"



-- // Constants
local AdminsDS = DSS:GetDataStore("Administer_Admins")
local GroupIDs = AdminsDS:GetAsync('AdminGroupIDs') or {}
local PluginDB = DSS:GetDataStore("AdministerPluginData")
local Config = require(script.Config)
local CurrentVers = Config.Version 
local InGameAdmins = {}
local ServerLifetime, PlrCount = 0, 0
local DidBootstrap = false
local AdminsBootstrapped, ShouldLog = {}, true
local PluginServers = PluginDB:GetAsync("PluginServerList")

local WasPanelFound = script:FindFirstChild("AdministerMainPanel")
if not WasPanelFound then
	warn(`[{Config.Name} {CurrentVers}]: Admin panel failed to initialize, please reinstall! Aborting startup...`)
	return
end

-- // Private Initalizations
print(`Starting {Config.Name} Version {Config.Version}...`)
require(script.PluginsAPI).ActivateUI(script.AdministerMainPanel)

local AdminsScript = require(script.Admins)
local AdminIDs, GroupIDs = AdminsScript.Admins, AdminsScript.Groups --// Legacy "admins". Support may be removed. 


local function BuildRemote(RemoteType: string, RemoteName: string, AuthRequired: boolean, Callback: _Function)
	if not table.find(RemoteType, {"RemoteFunction", "RemoteEvent"}) then
		return false, "Invalid remote type!"
	end

	local Rem = Instance.new(RemoteType)
	Rem.Name = RemoteName
	Rem.Parent = Remotes

	if RemoteType == "RemoteFunction" then
		Rem.OnServerEvent:Connect(function()
			--if AuthRequired and not  then

		end)
	end
end

local function GetSetting(Setting): boolean | string
	local SettingModule = Config.Settings

	for i, v in pairs(SettingModule) do
		if v["Name"] == Setting then
			return v["Value"]
		end
	end
	return "Not found"
end

local function Print(msg)
	if GetSetting("PrintMessages") then
		print(`[{Config["Name"]}]: {msg}`)
	end
end

-- local Decimals = GetSetting("ShortNumberDecimals")

local function Average(Table)
	local number = 0
	for _, value in pairs(Table) do
		number += value
	end
	return number / #Table
end

local function CreateFrame(parent: Frame, size: UDim2, backgroundTransparency: number): Frame
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Visible = true
	frame.Size = size
	if (backgroundTransparency) then
		frame.BackgroundTransparency = backgroundTransparency
	end

	return frame
end

local function NotificationThrottled(Player, Body: string, Heading: string, Icon: string, Duration: number)
	--// TODO replace

	Duration = Duration or GetSetting("NotificationCloseTimer")
	local playerGui = Player.PlayerGui
	local notificationFrame = playerGui.AdministerMainPanel.Notifications
	local tweeningNotificationFrame = playerGui.AdministerMainPanel.NotificationsTweening

	local Placeholder = CreateFrame(notificationFrame, UDim2.new(0.996, 0, 0.096, 0), 1)
	local notif = notificationFrame.Template:Clone()
	notif.Position = UDim2.new(0.4, 0, 0.904, 0)
	notif.Visible = true
	notif.Size = UDim2.new(0.996, 0, 0.096, 0)
	notif.Parent = tweeningNotificationFrame

	notif.Body.Text = Body
	notif.Header.Title.Text = Heading
	notif.Header.ImageL.Image = Icon

	if Icon == nil or Icon == "" then
		notif.Header.Title.Size = UDim2.new(1, 0, .965, 0)
		notif.Header.Title.Position = UDim2.new(1.884, 0, .095, 0)
	end

	local NewSound  = Instance.new("Sound")
	NewSound.Parent = notif
	NewSound.SoundId = "rbxassetid://9770089602"
	NewSound:Play()

	local NotifTween = TS:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0), {
		Position = UDim2.new(-0.02, 0, 0.904, 0)
	})

	NotifTween:Play()
	NotifTween.Completed:Wait()
	NotifTween:Destroy()
	Placeholder:Destroy()

	notif.Parent = notificationFrame

	task.wait(Duration)

	local Placeholder2  = CreateFrame(notificationFrame, UDim2.new(0.996, 0, 0.096, 0), 1)
	notif.Parent = tweeningNotificationFrame

	local NotifTween2 = TS:Create(
		notif,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In,
			0,
			false,
			0
		),
		{
			Position = UDim2.new(1.8, 0, 0.904, 0)
		}
	)

	NotifTween2:Play()
	NotifTween2.Completed:Wait()
	notif:Destroy()
	Placeholder2:Destroy()
end

local function NewNotification(AdminName, BodyText, HeadingText, Icon, Duration, NotificationSound)
	task.spawn(NotificationThrottled, AdminName, BodyText, HeadingText, Icon, Duration, NotificationSound)
end

local function FormatRelativeTime(Unix)
	local CurrentTime = os.time()
	local TimeDifference = CurrentTime - Unix

	if TimeDifference < 60 then
		return "Just Now"
	elseif TimeDifference < 3600 then
		local Minutes = math.floor(TimeDifference / 60)
		return `{Minutes} {Minutes == 1 and "Minute" or "Minutes"} ago`
	elseif TimeDifference < 86400 then
		local Hours = math.floor(TimeDifference / 3600)
		return `{Hours} {Hours == 1 and "Hour" or "Hours"} ago`
	elseif TimeDifference < 604800 then
		local Days = math.floor(TimeDifference / 86400)
		return `{Days} {Days == 1 and "Day" or "Days"} ago`
	elseif TimeDifference < 31536000 then
		local Weeks = math.floor(TimeDifference / 604800)
		return `{Weeks} {Weeks == 1 and "Week" or "Weeks"} ago`
	else
		local Years = math.floor(TimeDifference / 31536000)
		return `{Years} {Years == 1 and "Years" or "Years"} ago`
	end
end

local function VersionCheck(plr)
	task.wait(1)
	if not table.find(InGameAdmins, plr) then
		warn("ERROR: Unexpected call of CheckForUpdates")
		plr:Kick("\n [Administer]: \n Unexpected Error:\n \n Exploits or non admin tried to fire CheckForUpdates.")
	end

	local VersModule, Frame = require(8788148542), plr.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails
	local ReleaseDate = VersModule.ReleaseDate

	if VersModule.Version ~= CurrentVers then
		Frame.Version.Text = `Version {CurrentVers}. \nA new version is available! {VersModule.Version} was released on {ReleaseDate}`
		Frame.Value.Value = tostring(math.random(1,100000000))
		NewNotification(plr, `{Config["Name"]} is out of date. Please restart the game servers to get to a new version.`, "Version check complete", "rbxassetid://9894144899", 10)
	else
		Frame.Version.Text = `Version {CurrentVers} ({ReleaseDate})`
	end
end

local function GetGameOwner()
	local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)

	if GameInfo.Creator.CreatorType == "User" then
		return GameInfo.Creator.Id
	else
		return GroupService:GetGroupInfoAsync(GameInfo.Creator.CreatorTargetId).Owner.Id
	end
end

local function NewAdminRank(Name, Protected, Members, PagesCode, AllowedPages, Why)
	local Success, Error = pcall(function()
		local Info = AdminsDS:GetAsync("CurrentRanks") or {
			Count = 0,
			Names = {}
		}

		AdminsDS:SetAsync(`_Rank{Info.Count}`, {
			["RankID"] = Info.Count,
			["RankName"] = Name,
			["Protected"] = Protected,
			["Members"] = Members,
			["PagesCode"] = PagesCode,
			["AllowedPages"] = AllowedPages,
			["ModifiedPretty"] = os.date("%I:%M %p at %d/%m/%y"),
			["ModifiedUnix"] = os.time(),
			["Reason"] = Why
		})

		Info.Count = Info.Count + 1
		Info.Names = Info.Names or {}
		table.insert(Info.Names, Name)

		AdminsDS:SetAsync("CurrentRanks", {
			Count = Info.Count,
			Names = Info.Names
		})

		for i, v in ipairs(Members) do
			if v.MemberType == "User" then
				AdminsDS:SetAsync(v.ID, {
					IsAdmin = true,
					RankName = Name,
					RankId = Info.Count - 1
				})
			end
		end

	end)
	if Success then
		return {true, `Successfully made 1 rank!`}
	else
		return {false, `Something went wrong: {Error}`}
	end
end

local function New(plr, AdminRank)
	if not AdminRank then
		return {false, "You must provide a valid AdminRank!"}
	end

	local Rank = AdminsDS:GetAsync(`_Rank{AdminRank}`)

	table.insert(InGameAdmins, plr)
	local NewPanel = script.AdministerMainPanel:Clone()
	NewPanel.Parent = plr.PlayerGui

	local AllowedPages = {}
	for i, v in ipairs(Rank["AllowedPages"]) do
		table.insert(AllowedPages, v["Name"])
	end
	--for i, v in ipairs(AllowedPages) do
	--	print(v)
	--end

	if Rank.PagesCode ~= "*" then
		for _, v in ipairs(NewPanel.Main:GetChildren()) do
			if not v:IsA("Frame") then continue end
			if table.find({'Animation', 'Apps', 'Blur', 'Dock', 'Header', 'Home', 'NotFound'}, v.Name) then continue end

			if not table.find(AllowedPages, v.Name) then
				v:Destroy()
				print(`Removed {v.Name} from this person's panel because: Not Allowed by rank`)
			end
		end
	end


	VersionCheck(plr)
	--if game:GetService("RunService"):IsStudio() then
	--NewPanel.Main.Header.ErrorFrame.Visible = true
	--NewNotification(plr,"Administer is not recommended for use in Studio. Proceed with caution.","Warning","rbxassetid://9894144899",5, true)
	--else
	--NewNotification(plr,`Please wait, loading {Config.Name}`,`{Config.Name} v{CurrentVers}`,"rbxassetid://9894144899", 5, true)
	--1end
	local Success, Error = pcall(function()
		ContentProvider:PreloadAsync(NewPanel:GetDescendants())
	end)

	if not Success then
		NewNotification(plr, `Could not load something the main panel, likely a Roblox issue.`,"Error","rbxassetid://10012255725",10)
	end

	NewNotification(plr, `{
		Config["Name"]} version {CurrentVers} loaded! Press {GetSetting("PrefixString")} to enter.`,
		"Welcome!","rbxassetid://10012255725",
		10
	)
end

local function GetAllRanks()
	local Count = AdminsDS:GetAsync("CurrentRanks")
	local Ranks = {}

	for i = 1, tonumber(Count["Count"]) do
		Ranks[i] = AdminsDS:GetAsync("_Rank"..i)
	end

	return Ranks
end


local function GetTimeWithSeconds(Seconds)
	local Minutes = math.floor(Seconds / 60)
	Seconds = Seconds % 60

	if GetSetting("DisplayHours") then
		local Hours = math.floor(Minutes / 60)
		Minutes = Minutes % 60
		return string.format("%02i:%02i:%02i", Hours, Minutes, Seconds)
	else
		return string.format("%02i:%02i.%02i", Minutes, math.floor(Seconds), math.floor((Seconds % 1) * 100))
	end
end

local function GetShortNumer(Number)
	local Decimals = 2
	
	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (Decimals or 3)) / 10 ^ (Decimals or 3)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

local function GetGameMedia(PlaceId)
	-- This function will get the first non-video image from the place, for use in the loading screen.
	-- Proxy will sometimes return a 500 for reasons unknown to me, check up to 5 times before returning an error.
	local Default = ""
	local UniverseIdInfo, Attempts = 0,0

	repeat
		local Success, Error = pcall(function()
			Attempts += 1
			UniverseIdInfo = HttpService:JSONDecode(HttpService:GetAsync(`https://rblxproxy.darkpixlz.com/apis/universes/v1/places/{PlaceId}/universe`))["universeId"] or 0
		end)
	until Success or Attempts > 5


	if UniverseIdInfo == 0 then return Default end

	local MediaData = HttpService:JSONDecode(HttpService:GetAsync(`https://rblxproxy.darkpixlz.com/games/v2/games/{UniverseIdInfo}/media`))["data"]
	if MediaData == {} then
		return Default
	end

	local Tries = 1
	local Selected = false

	while not Selected do
		local Next = MediaData[Tries]

		if Next["videoHash"] ~= nil then
			if Tries ~= #MediaData then
				Tries += 1 
				continue
			else
				return Default
			end
		else
			return "rbxassetid://"..MediaData[Tries]["imageId"]
		end
	end
end

-- everything plugins besides bootstrapping

local function GetPluginInfo_(Player, PluginServer, PluginID)
	if not table.find(InGameAdmins, Player) then
		return {["Error"] = "Something went wrong", ["Message"] = "Unauthorized"}
	else
		local Success, Content = pcall(function()
			return HttpService:JSONDecode(HttpService:GetAsync(`{PluginServer}/app/{PluginID}`))
		end)

		if not Success then
			return {["Error"] = "Something went wrong, try again later. This is probably due to the plugin server shutting down mid-session!", ["Message"] = Content}
		else
			--if PluginServer ~= "https://administer.darkpixlz.com" then
			--for i, v in pairs(Content) do
			--	print(Content)
			--		print("a")
			--		print(tonumber(v))
			--		print(tostring(v))
			--	if tonumber(v) == nil and tostring(v) ~= nil then
			--		print("filtering")
			--			--v = game:GetService("TextService"):FilterAndTranslateStringAsync(v, game.Players:GetUserIdFromNameAsync(Content["PluginDeveloper"]))
			--			v = game:GetService("TextService"):FilterStringAsync(v, 1)
			--			print(v)
			--		end
			--	end
			--end
			return Content
		end
	end
end

local function InstallPlugin(PluginId)

end

local function InstallAdministerPlugin(Player, ServerName, PluginID)
	-- Get plugin info
	local Success, Content = pcall(function()
		return GetPluginInfo_(Player, ServerName, PluginID)
	end)

	if Content["PluginInstallID"] then
		local Module

		local Success, Error = pcall(function()
			Module = require(Content["PluginInstallID"])
		end)

		if not Success then
			return {false, `Something went wrong with the module, report it to the developer: {Error}`}
		end

		task.spawn(function()
			--Module.Parent = script.Plugins
			Module.OnDownload()
		end)

		local PluginList = PluginDB:GetAsync("PluginList") or {}
		table.insert(PluginList, Content["PluginInstallID"])

		PluginDB:SetAsync("PluginList", PluginList)
		return {true, "Success!"}
	else
		return {false, "Something went wrong fetching info"}
	end
end

local function InstallServer(ServerURL)
	warn(`[{Config.Name}]: Installing plugin server...`)
	local Success, Result = pcall(function()
		return game:GetService("HttpService"):GetAsync(ServerURL.."/.administer/verify")
	end)


	if Result == "AdministerPluginServer" then
		-- Valid server
		Print("This sever is valid, proceeding...")

		table.insert(PluginServers, ServerURL)
		PluginDB:SetAsync("PluginServerList", PluginServers)

		warn("Successfully installed!")
		return "Success!"
	else
		warn(`{ServerURL} is not an Administer plugin server! Make sure it begins with https://, does not have a forwardslash after the url, and is a valid plugin server. If you would like to set up a new one, check out the docs.`)

		return "Invalid plugin server! Check Logs for more info."
	end
end

local function GetPluginList()
	local FullList = {}
	for i, Server in ipairs(PluginServers) do
		local Success, Plugins = pcall(function()
			return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync(Server.."/list"))
		end)

		if not Success then
			warn(`[{Config.Name}]: Failed to contact {Server} as a plugin server - is it online? If the issue persists, you should probably remove it.`)
			continue
		end

		for i, v in ipairs(Plugins) do
			v["PluginServer"] = Server

			table.insert(FullList, v)
		end
	end

	return FullList
end

local function GetFilteredString(Player: Player, String: string)
	local Success, Text = pcall(function()
		return TextService:FilterStringAsync(String, Player.UserId)
	end)

	if Success then
		local Success2, Text2 = pcall(function()
			return Text:GetNonChatStringForBroadcastAsync()
		end)
		if Success2 then
			return {true, Text2}
		else
			return {false, `Failed to filter: {Text2}`}
		end
	else
		return {false, `Failed to filter: {Text}`}
	end
end

local function InitPluginRemotes()
	local InstallPluginServer = Instance.new("RemoteFunction") InstallPluginServer.Parent = Remotes InstallPluginServer.Name = "InstallPluginServer"
	local GetPluginsList = Instance.new("RemoteFunction", Remotes) GetPluginsList.Parent = Remotes GetPluginsList.Name = "GetPluginList"
	local InstallPluginRemote = Instance.new("RemoteFunction", Remotes) InstallPluginRemote.Parent = Remotes InstallPluginRemote.Name = "InstallPlugin"
	local GetPluginInfo = Instance.new("RemoteFunction") GetPluginInfo.Parent = Remotes GetPluginInfo.Name = "GetPluginInfo"

	return InstallPluginServer, GetPluginsList, InstallPluginRemote, GetPluginInfo
end

local function InitializeApps()
	Print("Bootstrapping apps...")

	if GetSetting("DisableApps") then
		Print(`App Bootstrapping disabled due to configuration, please disable!`)
		return
	end

	local Plugins = PluginDB:GetAsync("PluginList")

	if Plugins == nil then
		Print(`Bootstrapping apps failed because the Plugin list was nil! This is either a Roblox issue or you have no plugins installed!`)
		DidBootstrap = true
		return false
	end

	for _, v in ipairs(Plugins) do
		local Plugin = require(v)

		local Success, Error = pcall(function()
			Plugin.Move()
		end)

		if not Success then
			--warn(`[{Config.Name}]: Failed to run Plugin.Move() on {v}! Developers, if this is your plugin, please make sure your code follows the documentation.`)
			continue
		end
		--Print(`Bootstrapped {v}! Move called, should be running.`)

	end
	DidBootstrap = true
	return true
end

local function IsAdmin(Player: Player)
	-- Manual overrides first
	local RanksData = AdminsDS:GetAsync(Player.UserId) or {}

	if table.find(AdminIDs, Player.UserId) ~= nil then
		return true, "Found in AdminIDs override", 1, "Admin"
	else
		for i, v in pairs(GroupIDs) do
			if Player:IsInGroup(v) then
				return true, "Found in AdminIDs override", 1, "Admin"
			end
		end
	end

	if RanksData ~= {} then
		return RanksData["IsAdmin"], "Data based on settings configured by an admin.", RanksData["RankId"], RanksData["RankName"]
	else
		return false, "Data was not found and player is not in override", 0, "NonAdmin"
	end
end

---------------------

local ManageAdminRemote = Instance.new("RemoteFunction")
ManageAdminRemote.Parent, ManageAdminRemote.Name = Remotes, "NewRank"

local GetAdminListRemote = Instance.new("RemoteFunction")
GetAdminListRemote.Parent, GetAdminListRemote.Name = Remotes, "GetAdminList"

local GetRanks = Instance.new("RemoteFunction")
GetRanks.Parent, GetRanks.Name = Remotes, "GetRanks"

local GetFilter = Instance.new("RemoteFunction")
GetFilter.Parent, GetFilter.Name = Remotes, "FilterString"

local GetPasses = Instance.new("RemoteFunction")
GetPasses.Parent, GetPasses.Name = Remotes, "GetPasses"


local GetAllMembers = Instance.new("RemoteFunction")
GetAllMembers.Parent, GetAllMembers.Name = Remotes, "GetAllMembers"

local ClientPing = Instance.new("RemoteEvent")
ClientPing.Parent, ClientPing.Name = Remotes, "Ping"

--// Homescreen
local HomeDS = DSS:GetDataStore("Administer_HomeScreenStore")
local UpdateHomePage = Instance.new("RemoteFunction", Remotes)
UpdateHomePage.Name = "UpdateHomePage"

if PluginServers == nil then
	-- Install the official one
	PluginServers = {}
	Print("Performing first-time setup on plugin servers...")
	InstallServer("https://administer.darkpixlz.com")

	GetPluginList()
end

local InstallPluginServer, GetPluginsList, InstallPluginRemote, GetPluginInfo = InitPluginRemotes()

-- // Event Handling \\ --
-- Initialize
task.spawn(InitializeApps)

if not AdminsDS:GetAsync("_Rank1") then
	warn(`[{Config["Name"]}]: Running first time rank setup!`)

	print(
		NewAdminRank("Admin", true, {
			{
				['MemberType'] = "User",
				['ID'] = GetGameOwner()
			}
			},
			"*",
			{},
			"Added by System for first-time setup"
		)
	)
end

Players.PlayerAdded:Connect(function(plr)
	if ShouldLog then
		table.insert(AdminsBootstrapped, plr)
	end

	local IsAdmin, Reason, RankID, RankName = IsAdmin(plr)
	print("result:", IsAdmin, Reason, RankID, RankName)
	
	if IsAdmin then
		task.spawn(New, plr, RankID)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	return table.find(InGameAdmins, plr) and table.remove(InGameAdmins, table.find(InGameAdmins, plr))
end)

-- Catch any leftovers
task.spawn(function()
	repeat task.wait(1) until DidBootstrap
	task.wait(1)
	ShouldLog = false

	for i, v in ipairs(Players:GetPlayers()) do
		if table.find(AdminsBootstrapped, v) then continue end

		local IsAdmin, Reason, RankID, RankName = IsAdmin(v)
		print("result:", IsAdmin, Reason, RankID, RankName)

		if IsAdmin then
			task.spawn(New, v, RankID)
		end
	end

	AdminsBootstrapped = {}
end)

-- // Remote Events \\ --
ClientPing.OnServerEvent:Connect(function() return "pong" end)
-- CheckForUpdates
CheckForUpdatesRemote.OnServerEvent:Connect(function(plr)
	VersionCheck(plr)
	plr.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails.Value.Value = tostring(math.random(1,100000000)) -- Eventually this will be a RemoteFunction, just not now...
end)

-- // Remote Functions \\ --
-- Plugin Remotes
InstallPluginServer.OnServerInvoke = function(Player, Text)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or InstallServer(Text)
end

GetPluginsList.OnServerInvoke = function(Player)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or GetPluginList()
end

InstallPluginRemote.OnServerInvoke = function(Player, PluginServer, PluginID)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or (PluginServer == "rbx" and InstallPlugin(PluginID)) or InstallAdministerPlugin(Player, PluginServer, PluginID)
end

GetPluginInfo.OnServerInvoke = function(Player, PluginServer, PluginID)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or GetPluginInfo_(Player, PluginServer, PluginID)
end

-- ManageAdmin
ManageAdminRemote.OnServerInvoke = function(Player, Package)
	local IsAdmin, d, f, g, h = IsAdmin(Player) -- For now, the ranks info doesn't matter. It will soon, (probably later in 1.0 development) to prevent exploits from low ranks.
	if not IsAdmin then
		warn(`[{Config.Name}]: Got unauthorized request on ManageAdminRemote from {Player.Name} ({Player.UserId})`)
		return {
			Success = false,
			Header = "Something went wrong",
			Message = "You're not authorized to complete this request, try again later."
		}
	end

	local Result = NewAdminRank(Package["Name"], Package["Protected"], Package["Members"], Package["PagesCode"], Package["AllowedPages"], `Created by {Player.Name}`)

	if Result[1] then
		return {
			Success = true,
			Header = "/",
			Message = "/"
		}
	else
		return {
			Success = false,
			Header = "Something went wrong",
			Message = `We couldn't process that request right now, try again later.\n\n{Result[2] or "No error was given!"}`
		}
	end
end

-- GetRanks
GetRanks.OnServerInvoke = function(Player)
	if not table.find(InGameAdmins, Player) then
		return {
			["Success"] = false,
			["ErrorMessage"] = "Unauthorized"
		}
	else
		return GetAllRanks()
	end
end

-- GetFilter
GetFilter.OnServerInvoke = function(Player, String)
	return GetFilteredString(Player, String)
end

-- GetPasses
GetPasses.OnServerInvoke = function(Player)
	local Attempts, _Content = 0, ""

	repeat
		local Success, Error = pcall(function()
			Attempts += 1
			_Content = game:GetService("HttpService"):GetAsync(`https://rblxproxy.darkpixlz.com/games/v1/games/3331848462/game-passes?sortOrder=Asc&limit=50`, true)
		end)
	until Success or Attempts > 5

	return _Content or HttpService:JSONEncode({
		["data"] = {
			{
				["price"] = "Failed to load passes.",
				["id"] = 0
			}
		}
	})
end

-- GetAllMembers
GetAllMembers.OnServerInvoke = function(Player)
	local Players = {}
	return not table.find(InGameAdmins, Player) and "Something went wrong"
end

-- Home Page
UpdateHomePage.OnServerInvoke = function(Player, Data)
	if not table.find(InGameAdmins, Player) then
		return {
			["UserFacingMessage"] = "Something went wrong.",
			["Result"] = "fail"
		}
	else
		--// do some checks
		if Data == nil then return {} end

		if #Data["Boxes"] ~= 2 then
			return {
				["UserFacingMessage"] = "Bad data was sent, report this or try again.",
				["Result"] = "fail"
			}
		elseif #Data["SmallLabels"] > 6 then
			return {
				["UserFacingMessage"] = "Too many items in your small text feed! Try again later.",
				["Result"] = "fail"
			}
		end

		local Success, Error = pcall(function()
			print(`Saving homescreen data for {Player.Name}.`)

			HomeDS:SetAsync(Player.UserId, Data, {})
		end)
	end
end

print(`Administer successfully compiled in {tick() - t}s`)