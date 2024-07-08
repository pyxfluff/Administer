local t = tick()
--[[

# Administer #

Build 1.0 Internal Beta 7 - 2022-2024

https://github.com/darkpixlz/Administer

The following code is free to use, look at, and modify. 
Please refrain from modifying core functions as it can break everything. It's very fragile in general.
All modifications can be done via apps/Apps.

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

local AppsRemotes = Instance.new("Folder")
AppsRemotes.Name, AppsRemotes.Parent = "AdministerAppRemotes", Remotes

local NewPlayerClient = Instance.new("RemoteEvent")
NewPlayerClient.Parent = Remotes
NewPlayerClient.Name = "NewPlayerClient"

local CheckForUpdatesRemote = Instance.new("RemoteEvent")
CheckForUpdatesRemote.Parent, CheckForUpdatesRemote.Name = Remotes, "CheckForUpdates"

--// Test DS Connection
local Config = require(script.Config)
local _s, _e = pcall(function()
	DSS:GetDataStore("_administer")
end)

if not _s then
	error(`{Config["Name"]}: DataStoreService is not operational. Loading cannot continue. Please enable DataStores and try again.`)
end

-- // Constants
local AdminsDS = DSS:GetDataStore("Administer_Admins")
local HomeDS = DSS:GetDataStore("Administer_HomeStore")
local GroupIDs = AdminsDS:GetAsync('AdminGroupIDs') or {}
local AppDB = DSS:GetDataStore("AdministerAppData")
local CurrentVers = Config.Version 
local InGameAdmins = {"_AdminBypass"}
local ServerLifetime, PlrCount = 0, 0
local DidBootstrap = false
local AdminsBootstrapped, ShouldLog = {}, true
local AppServers = AppDB:GetAsync("AppServerList")

--// Types
local BaseHomeInfo = {
	["_version"] = "1",
	["Widget1"] = "administer\\none",
	["Widget2"] = "administer\\none",
	["TextWidgets"] = {
		"administer\\version-label"
	}
}

local WasPanelFound = script:FindFirstChild("AdministerMainPanel")
if not WasPanelFound then
	warn(`[{Config.Name} {CurrentVers}]: Admin panel failed to initialize, please reinstall! Aborting startup...`)
	return
end

-- // Private Initalizations
print(`Starting {Config.Name} version {Config.Version}...`)
require(script.AppAPI).ActivateUI(script.AdministerMainPanel)

local AdminsScript = require(script.Admins)
local AdminIDs, GroupIDs = AdminsScript.Admins, AdminsScript.Groups --// Legacy "admins". Support may be removed. 

local function BuildRemote(RemoteType: string, RemoteName: string, AuthRequired: boolean, Callback: Function)
	if not table.find({"RemoteFunction", "RemoteEvent"}, RemoteType) then
		return false, "Invalid remote type!"
	end

	local Rem = Instance.new(RemoteType)
	Rem.Name = RemoteName
	Rem.Parent = Remotes

	if RemoteType == "RemoteEvent" then
		Rem.OnServerEvent:Connect(function(Player, ...)
			if AuthRequired and not table.find(InGameAdmins, Player) then
				return {false, "Unauthorized"}
			end

			Callback(Player, ...)
		end)
	elseif RemoteType == "RemoteFunction" then
		Rem.OnServerInvoke = function(Player, ...)
			if AuthRequired and not table.find(InGameAdmins, Player) then
				return {false, "Unauthorized"}
			end

			return Callback(Player, ...)
		end
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

local function NotificationThrottled(Admin: Player, Title: string, Icon: string, Body: string, Heading: string, Duration: number?, Options: Table?, OpenTime: int?)
	local TweenService = game:GetService("TweenService")
	local Panel = Admin.PlayerGui.AdministerMainPanel

	OpenTime = OpenTime or 1.25

	local Placeholder  = Instance.new("Frame")
	Placeholder.Parent = Panel.Notifications
	Placeholder.BackgroundTransparency = 1
	Placeholder.Size = UDim2.new(1.036,0,0.142,0)

	local Notification: Frame = Panel.Notifications.Template:Clone() -- typehinting for dev
	Notification.Visible = true		
	Notification = Notification.NotificationContent
	Notification.Parent.Position = UDim2.new(0,0,1.3,0)
	Notification.Parent.Parent = Panel.NotificationsTweening
	Notification.Body.Text = Body
	Notification.Header.Title.Text = `<b>{Title}</b> • {Heading}`
	Notification.Header.Administer.Image = "rbxassetid://18224047110"
	Notification.Header.ImageL.Image = Icon  

	for i, Object in Options or {} do
		local NewButton = Notification.Buttons.DismissButton:Clone()
		NewButton.Parent = Notification.Buttons

		NewButton.Name = Object["Text"]
		NewButton.Title.Text = Object["Text"]
		NewButton.ImageL.Image = Object["Icon"]
		NewButton.MouseButton1Click:Connect(function()
			Object["OnClick"]()
		end)
	end

	if Icon == "" then
		--// This code was old(?) and did not support the new notifications so it's gone for now, might return later?
		--Notification.Header.Title.Size = UDim2.new(1,0,.965,0)
		--Notification.Header.Title.Position = UDim2.new(1.884,0,.095,0)
	end

	local NewSound  = Instance.new("Sound")
	NewSound.Parent = Notification
	NewSound.SoundId = "rbxassetid://9770089602"
	NewSound:Play()

	--local NotificationTween = TweenService:Create(Notification, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), {
	--	Position = UDim2.new(-0.02,0,0.904,0)
	--})

	local Tweens = {
		TweenService:Create(
			Notification.Parent,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(-.018,0,.858,0),
			}
		),
		TweenService:Create(
			Notification,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				GroupTransparency = 0
			}
		)
	}

	for i, v in pairs(Tweens) do
		v:Play()
	end

	Tweens[1].Completed:Wait()
	Placeholder:Destroy()
	Notification.Parent.Parent = Panel.Notifications

	local function Close()
		local NotifTween2 = TweenService:Create(
			Notification,
			TweenInfo.new(
				OpenTime * .7,
				Enum.EasingStyle.Quad
			),
			{
				Position = UDim2.new(1,0,0,0),
				GroupTransparency = 1
			}
		)

		local NotifTween3 = TweenService:Create(
			Notification,
			TweenInfo.new(
				OpenTime * .5,
				Enum.EasingStyle.Quad
			),
			{
				GroupTransparency = 1
			}
		)

		NotifTween2:Play()
		--NotifTween3:Play()
		NotifTween2.Completed:Wait()
		pcall(function()
			Notification.Parent:Destroy()
		end)
	end

	Notification.Buttons.DismissButton.MouseButton1Click:Connect(Close)

	task.wait(Duration)

	Close()
end

local function NewNotification(AdminName, BodyText, HeadingText, Icon, Duration, NotificationSound, Buttons)
	task.spawn(function()
		NotificationThrottled(AdminName, "Administer", Icon, BodyText, HeadingText, Duration, Buttons, 1)
	end)
end

local function FormatRelativeTime(Unix)
	local CurrentTime = os.time()
	local TimeDifference = CurrentTime - Unix

	if TimeDifference < 60 then
		return "Just now"
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

	local VersModule, Frame = require(18336751142), plr.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails
	local ReleaseDate = VersModule.ReleaseDate

	if VersModule.Version ~= CurrentVers then
		Frame.Version.Text = `Version {CurrentVers} \nA new version is available! {VersModule.Version} was released on {ReleaseDate}`
		Frame.Value.Value = tostring(math.random(1,100000000))
		NewNotification(plr, `{Config["Name"]} is out of date. Please restart the game servers to get to a new version.`, "Version check complete", "rbxassetid://9894144899", 15)
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
			["ModifiedPretty"] = os.date("%d/%m/%y at %I:%M %p"),
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

local function New(plr, AdminRank, IsSandboxMode)
	if not AdminRank then
		return {false, "You must provide a valid AdminRank!"}
	end

	local Rank = AdminsDS:GetAsync(`_Rank{AdminRank}`)

	table.insert(InGameAdmins, plr)
	local NewPanel = script.AdministerMainPanel:Clone()
	NewPanel.Parent = plr.PlayerGui

	NewPanel:SetAttribute("_AdminRank", Rank.RankName)
	NewPanel:SetAttribute("_SandboxModeEnabled", IsSandboxMode)
	NewPanel:SetAttribute("_HomeWidgets", HttpService:JSONEncode(HomeDS:GetAsync(plr.UserId) or BaseHomeInfo))
	NewPanel:SetAttribute("_InstalledApps", HttpService:JSONEncode(require(script.AppAPI).AllApps))

	local AllowedPages = {}
	for i, v in ipairs(Rank["AllowedPages"]) do

		AllowedPages[v["DisplayName"]] = {
			["Name"] = v["DisplayName"], 
			["ButtonName"] = v["Name"]
		}
	end
	--for i, v in ipairs(AllowedPages) do
	--	print(v)
	--end

	if Rank.PagesCode ~= "*" then
		for _, v in ipairs(NewPanel.Main:GetChildren()) do
			if not v:IsA("Frame") then continue end
			if table.find({'Animation', 'Apps', 'Blur', 'Header', 'Home', 'NotFound', "Welcome", 'HeaderBG'}, v.Name) then continue end
			
			local Success, Error = pcall(function()
				if AllowedPages[v.Name] == nil then
					local Name = v.Name

					NewPanel.Main.Apps.MainFrame[v:GetAttribute("LinkedButton")]:Destroy()
					v:Destroy()
					-- print(`Removed {AllowedPages[Name]["Name"]} from this person's panel because: Not Allowed by rank`)
				end
			end)
			
			if not Success then
				warn(`[{Config["Name"]} CRITICAL]: {v.Name} has a MISMATCHED NAME`)
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

	NewNotification(plr, 
		`{Config["Name"]} version {CurrentVers} loaded! {IsSandboxMode and "Sandbox mode enabled." or `You're a{string.split(string.lower(Rank.RankName), "a")[1] == "" and "n" or ""} {Rank.RankName}`}. Press {GetSetting("PrefixString")} to enter.`,
		"Welcome!",
		"rbxassetid://10012255725",
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

-- everything Apps besides bootstrapping

local function GetAppInfo_(Player, AppServer, AppID)
	if not table.find(InGameAdmins, Player) then
		return {["Error"] = "Something went wrong", ["Message"] = "Unauthorized"}
	else
		local Success, Content = pcall(function()
			return HttpService:JSONDecode(HttpService:GetAsync(`{AppServer}/app/{AppID}`))
		end)

		if not Success then
			return {["Error"] = "Something went wrong, try again later. This is probably due to the app server shutting down mid-session!", ["Message"] = Content}
		else
			--if AppServer ~= "https://administer.darkpixlz.com" then
			--for i, v in pairs(Content) do
			--	print(Content)
			--		print("a")
			--		print(tonumber(v))
			--		print(tostring(v))
			--	if tonumber(v) == nil and tostring(v) ~= nil then
			--		print("filtering")
			--			--v = game:GetService("TextService"):FilterAndTranslateStringAsync(v, game.Players:GetUserIdFromNameAsync(Content["AppDeveloper"]))
			--			v = game:GetService("TextService"):FilterStringAsync(v, 1)
			--			print(v)
			--		end
			--	end
			--end
			return Content
		end
	end
end

local function InstallApp(AppId)

end

local function InstallAdministerApp(Player, ServerName, AppID)
	-- Get App info
	local Success, Content = pcall(function()
		return GetAppInfo_(Player, ServerName, AppID)
	end)

	if Content["AppInstallID"] then
		if tostring(Content["AppInstallID"]) == "0" then
			return {false, "Bad app ID, this is an app server issue, do not report it to Administer!"}
		end

		local Module

		local Success, Error = pcall(function()
			Module = require(Content["AppInstallID"])
		end)

		if not Success then
			return {false, `Something went wrong with the module, report it to the developer: {Error}`}
		end

		task.spawn(function()
			--Module.Parent = script.Apps
			--print(HttpService:PostAsync(`{ServerName}/install/{Content["AdministerMetadata"]["AdministerID"]}`, {}))
			print(HttpService:RequestAsync(
				{
					["Method"] = "POST",
					["Url"] = `{ServerName}/install/{Content["AdministerMetadata"]["AdministerID"]}`
				}
				))
			Module.OnDownload()
		end)

		local AppList = AppDB:GetAsync("AppList") or {}
		table.insert(AppList, Content["AppInstallID"])

		AppDB:SetAsync("AppList", AppList)
		return {true, "Success!"}
	else
		return {false, "Something went wrong fetching info"}
	end
end

local function InstallServer(ServerURL)
	warn(`[{Config.Name}]: Installing App server...`)
	local Success, Result = pcall(function()
		return HttpService:JSONDecode(HttpService:GetAsync(ServerURL.."/.administer/server"))
	end)


	if Result["server"] == "AdministerAppServer" then
		-- Valid server
		Print("This sever is valid, proceeding...")

		table.insert(AppServers, ServerURL)
		AppDB:SetAsync("AppServerList", AppServers)

		warn("Successfully installed!")
		return "Success!"
	else
		warn(`{ServerURL} is not an Administer App server! Make sure it begins with https://, does not have a forwardslash after the url, and is a valid App server. If you would like to set up a new one, check out the docs.`)

		return "Invalid App server! Check Logs for more info."
	end
end

local function GetAppList(IsFirstBoot)
	local FullList = {}
	for i, Server in ipairs(AppServers) do
		local Success, Apps = pcall(function()
			return HttpService:JSONDecode(HttpService:GetAsync(Server..`/list`))
		end)

		if not Success then
			warn(`[{Config.Name}]: Failed to contact {Server} as a App server - is it online? If the issue persists, you should probably remove it.`)
			continue
		end

		for i, v in HttpService:JSONDecode(Apps) do
			v["AppServer"] = Server

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

local function InitAppRemotes()
	local InstallAppServer = Instance.new("RemoteFunction") InstallAppServer.Parent = Remotes InstallAppServer.Name = "InstallAppServer"
	local GetAppsList = Instance.new("RemoteFunction", Remotes) GetAppsList.Parent = Remotes GetAppsList.Name = "GetAppList"
	local InstallAppRemote = Instance.new("RemoteFunction", Remotes) InstallAppRemote.Parent = Remotes InstallAppRemote.Name = "InstallApp"
	local GetAppInfo = Instance.new("RemoteFunction") GetAppInfo.Parent = Remotes GetAppInfo.Name = "GetAppInfo"

	return InstallAppServer, GetAppsList, InstallAppRemote, GetAppInfo
end

local function InitializeApps()
	Print("Bootstrapping apps...")

	if GetSetting("DisableApps") then
		Print(`App Bootstrapping disabled due to configuration, please disable!`)
		return false
	end

	local Apps = AppDB:GetAsync("AppList")

	if Apps == nil then
		--Print(`Bootstrapping apps failed because the App list was nil! This is either a Roblox issue or you have no Apps installed!`)
		DidBootstrap = true
		return false
	end

	for _, v in ipairs(Apps) do
		local _t = tick()
		local App = require(v)

		task.spawn(function()
			local Success, Error = pcall(function()
				local AppName = App.Init()

				repeat --// Hacky? Sorta... also probably slows down init time
					task.wait()
					local _s, _e = pcall(function()
						require(script.AppAPI).AllApps[AppName]["BuildTime"] = string.sub(tostring(tick() - _t), 1, 5)
					end)
					-- if not _s then print("failed") end
				until _s
			end)

			if not Success then
				warn(`[{Config.Name}]: Failed to App.Init() on {v} ({Error})! Developers, if this is your app, please make sure your code follows the documentation.`)
			end
		end)
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
local UpdateHomePage = Instance.new("RemoteFunction", Remotes)
UpdateHomePage.Name = "UpdateHomePage"

if AppServers == nil then
	-- Install the official one
	AppServers = {}
	Print("Performing first-time setup on App servers...")
	InstallServer("https://administer.darkpixlz.com")
	InstallAdministerApp("_AdminBypass", "https://administer.darkpixlz.com", "1")

	GetAppList()
end

local InstallAppServer, GetAppsList, InstallAppRemote, GetAppInfo = InitAppRemotes()

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

	repeat task.wait(1) until DidBootstrap

	local IsAdmin, Reason, RankID, RankName = IsAdmin(plr)
	print("result:", IsAdmin, Reason, RankID, RankName)

	if IsAdmin then
		task.spawn(New, plr, RankID)
	elseif game:GetService("RunService"):IsStudio() and GetSetting("SandboxMode") then
		task.spawn(New, plr, RankID, true)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	return table.find(InGameAdmins, plr) and table.remove(InGameAdmins, table.find(InGameAdmins, plr))
end)

-- Catch any leftovers
task.spawn(function()
	repeat task.wait(1) until DidBootstrap
	ShouldLog = false

	for i, v in ipairs(Players:GetPlayers()) do
		if table.find(AdminsBootstrapped, v) then continue end

		local IsAdmin, Reason, RankID, RankName = IsAdmin(v)
		if IsAdmin then
			task.spawn(New, v, RankID)
		end
	end

	AdminsBootstrapped = {}
end)

-- // Remote Events \\ --

ClientPing.OnServerEvent:Connect(function() return "pong" end)

CheckForUpdatesRemote.OnServerEvent:Connect(function(plr)
	VersionCheck(plr)
	plr.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails.Value.Value = tostring(math.random(1,1000)) -- Eventually this will be a RemoteFunction, just not now...
end)

-- // Remote Functions \\ --
-- App Remotes
InstallAppServer.OnServerInvoke = function(Player, Text)
	--return not table.find(InGameAdmins, Player) and "Something went wrong" or InstallServer(Text)
	return "This feature is currently disabled."
end

GetAppsList.OnServerInvoke = function(Player)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or GetAppList()
end

InstallAppRemote.OnServerInvoke = function(Player, AppServer, AppID)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or (AppServer == "rbx" and InstallApp(AppID)) or InstallAdministerApp(Player, AppServer, AppID)
end

GetAppInfo.OnServerInvoke = function(Player, AppServer, AppID)
	return not table.find(InGameAdmins, Player) and "Something went wrong" or GetAppInfo_(Player, AppServer, AppID)
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
	end
	--// do some checks
	if Data == nil then 
		return {
			["UserFacingMessage"] = "Bad data sent by client.",
			["Result"] = "fail"
		} 
	end

	local HomeInfo

	if Data["EventType"] == "UPDATE" then
		--// check current data?
		HomeInfo = HomeDS:GetAsync(Player.UserId)

		if not HomeInfo then
			--// This shouldn't happen in practice but best to check?
			HomeInfo = BaseHomeInfo
		end

		HomeInfo[Data["WidgetID"]] = Data["NewIdentifier"]
	end

	local Success, Error = pcall(function()
		print(`Saving homescreen data for {Player.Name}.`)

		print(HomeInfo)

		HomeDS:SetAsync(Player.UserId, HomeInfo)
	end)
end

BuildRemote("RemoteEvent", "TestEvent", true, function(Player, Data)
	print(`got: {Data}`)
end)

BuildRemote("RemoteFunction", "GetAllApps", true, function(PLayer)
	local List = require(script.AppAPI).AllApps
	
	return List
end)

BuildRemote("RemoteFunction", "ManageApp", true, function(Player, Payload)
	if not table.find({}, Payload["Type"]) then
		
	end
end)

print(`Administer successfully compiled in {tick() - t}s`)
