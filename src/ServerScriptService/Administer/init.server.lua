--// # Administer #

--// Build 1.0 - 2022-2024
--// PyxFluff 2022-2024

--// https://github.com/pyxfluff/Administer

--// The following code is free to use, look at, and modify. 
--// Please refrain from modifying core functions as it can break everything.
--// All modifications can be done via apps.

--// WARNING: Use of Administer's codebase for AI training is STRICTLY PROHIBITED and you will face consequences if you do it.
--// Do NOT use this script or any in this model to train your AI or else.

------

local InitClock = {
	RealInit = tick(),
	TempInit = tick()
}

-- // Services
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local GroupService = game:GetService("GroupService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

InitClock["Services"] = tick() - InitClock["TempInit"]
InitClock["TempInit"] = tick()

-- // Initialize Folders
local Remotes = Instance.new("Folder")
Remotes.Name, Remotes.Parent = "AdministerRemotes", ReplicatedStorage

local AppsRemotes = Instance.new("Folder")
AppsRemotes.Name, AppsRemotes.Parent = "AdministerAppRemotes", Remotes

local NewPlayerClient = Instance.new("RemoteEvent")
NewPlayerClient.Parent = Remotes
NewPlayerClient.Name = "NewPlayerClient"

-- // Datastores
local Config = require(script.Config)
if not pcall(function() DataStoreService:GetDataStore("_administer") end) then
	error(`{Config["Name"]}: DataStoreService is not operational. Loading cannot continue. Please enable DataStores and try again.`)
end

local AdminsDS = DataStoreService:GetDataStore("Administer_Admins")
local HomeDS = DataStoreService:GetDataStore("Administer_HomeStore")
local AppDB = DataStoreService:GetDataStore("Administer_AppData")
local AppServers = AppDB:GetAsync("AppServerList")

InitClock["DataStoreService"] = tick() - InitClock["TempInit"]
InitClock["TempInit"] = tick()

--// Some other checks
if not HttpService.HttpEnabled then
	error(`{Config["Name"]}: HttpService is disabled. Please enable it before you use Administer.`)
end

--// Constants
local CurrentVers = Config.Version 
local InGameAdmins = {"_AdminBypass"}
local DidBootstrap = false
local AdminsBootstrapped = {}
local ShouldLog = true
local WasPanelFound = script:FindFirstChild("AdministerMainPanel")
local CurrentBranch = nil
local AdminsScript, AdminIDs, GroupIDs

xpcall(function()
	--// Legacy "admins". Support may be removed.
	AdminsScript =  require(script.Admins)
	
	AdminIDs, GroupIDs = AdminsScript.Admins, AdminsScript.Groups
end, function(e)
	warn([[
	[Administer]: Failed to laod your legacy admins, likely due to a syntax error. No legacy admins will load.
	
	Please ensure you have no loose brackets and no missing commas. If you need help, join our server or use an online linter.
	]])
	
	print("[Administer]: Restarting the boot process from non-fatal error ", e)
end)

local Branches = {
	["Interal"] = {
		["ImageID"] = "rbxassetid://18841275783",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer Internal",
		["IsActive"] = false
	},
	
	["QA"] = {
		["ImageID"] = "rbxassetid://76508533583525",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer QA",
		["IsActive"] = false
	},

	["Canary"] = {
		["ImageID"] = "rbxassetid://18841275783",
		["UpdateLog"] = 18841988915,
		["Name"] = "Administer Canary",
		["IsActive"] = false
	},

	["Beta"] = {
		["ImageID"] = "rbxassetid://18770010888",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer Beta",
		["IsActive"] = false
	},

	["Live"] = {
		["ImageID"] = "rbxassetid://18224047110",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer",
		["IsActive"] = true
	},
}
local BaseHomeInfo = {
	["_version"] = "1",
	["Widget1"] = "administer\\Welcome to Administer!",
	["Widget2"] = "administer\\Unselected",
	["TextWidgets"] = {
		"administer\\version-label"
	}
}

for Branch, Object in Branches do
	if Object["IsActive"] then
		CurrentBranch = Object
		CurrentBranch["BranchName"] = Branch
	end
	
	if Branch == "Internal" then
		table.insert(AdminIDs, 133017837)
	end
end

if not CurrentBranch then
	warn(`[{Config.Name}]: Please do not disable branches. Falling back to Live.`)
	CurrentBranch = Branches["Live"]
	CurrentBranch["BranchName"] = "Live"
end

if script.Parent ~= game.ServerScriptService then
	warn(`[{Config.Name}]: Please parent Administer to ServerScriptService.`)
	script.Parent = game.ServerScriptService
end

InitClock["Constants"] = tick() - InitClock["TempInit"]
InitClock["TempInit"] = tick()

if not WasPanelFound then
	warn(`[{Config.Name}]: Admin panel failed to initialize, please reinstall or parent the panel UI back to this script! Aborting startup...`)
	return
end

require(script.AppAPI).ActivateUI(script.AdministerMainPanel)

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

local function GetSetting(
	Setting: string
): string <Setting | NotFound> | boolean | nil
	local SettingModule = require(script.Config).Settings

	for i, v in SettingModule do
		local Success, Result = pcall(function() 
			if v["Name"] == Setting then
				return v["Value"]
			else
				return "CONT" --// send continue signal
			end
		end) 

		if not Success then
			return "Corrupted setting (No \"Name\" or Value) ... " .. Result	
		elseif Result == "CONT" then
			continue
		else
			return Result
		end
	end

	return "Not found"
end

local function Print(msg)
	if GetSetting("Verbose") then
		print(`[{Config["Name"]}]: {msg}`)
	end
end

local function Average(Table)
	local number = 0
	for _, value in pairs(Table) do
		number += value
	end
	return number / #Table
end

local function NotificationThrottled(Admin: Player, Title: string, Icon: string, Body: string, Heading: string, Duration: number?, Options: Table?, OpenTime: int?)
	local Panel = Admin.PlayerGui.AdministerMainPanel

	OpenTime = OpenTime or 1.25

	local Placeholder  = Instance.new("Frame")
	Placeholder.Parent = Panel.Notifications
	Placeholder.BackgroundTransparency = 1
	Placeholder.Size = UDim2.new(1.036,0,0.142,0)

	local Notification: Frame = Panel.Notifications.Template:Clone()
	Notification.Visible = true		
	Notification = Notification.NotificationContent
	Notification.Parent.Position = UDim2.new(0,0,1.3,0)
	Notification.Parent.Parent = Panel.NotificationsTweening
	Notification.Body.Text = Body
	Notification.Header.Title.Text = `<b>{Title}</b> • {Heading}`
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

	local NewSound  = Instance.new("Sound")
	NewSound.Parent = Notification
	NewSound.SoundId = "rbxassetid://9770089602"
	NewSound:Play()

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
	task.delay(Duration, Close)
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
		return "Just Now"
	elseif TimeDifference < 3600 then
		local Minutes = math.floor(TimeDifference / 60)
		return `{Minutes} {Minutes == 1 and "minute" or "minutes"} ago`
	elseif TimeDifference < 86400 then
		local Hours = math.floor(TimeDifference / 3600)
		return `{Hours} {Hours == 1 and "hour" or "hours"} ago`
	elseif TimeDifference < 604800 then
		local Days = math.floor(TimeDifference / 86400)
		return `{Days} {Days == 1 and "day" or "days"} ago`
	elseif TimeDifference < 31536000 then
		local Weeks = math.floor(TimeDifference / 604800)
		return `{Weeks} {Weeks == 1 and "week" or "weeks"} ago`
	else
		local Years = math.floor(TimeDifference / 31536000)
		return `{Years} {Years == 1 and "years" or "years"} ago`
	end
end

local function VersionCheck(plr: Player)
	local VersModule, Frame = require(CurrentBranch["UpdateLog"]), plr.PlayerGui.AdministerMainPanel.Main.Configuration.InfoPage.VersionDetails
	
	for i, Label in Frame.ScrollingFrame:GetChildren() do
		if Label:IsA("TextLabel") and Label.Name ~= "TextLabel" then
			Label:Destroy()
		end
	end

	local function NewUpdateLogText(Text)
		local Template = Frame.ScrollingFrame.TextLabel:Clone()

		Template.Visible = true
		Template.Text = Text
		Template.Name = Text
		Template.Parent = Frame.ScrollingFrame
	end

	if VersModule.Version.Major ~= Config.VersData.Major or VersModule.Version.Minor ~= Config.VersData.Minor or VersModule.Version.Tweak ~= Config.VersData.Tweak then
		Frame.Version.Text = `Version {CurrentVers}` --// don't include the date bc we don't store that here
		NewNotification(plr, `{Config["Name"]} is out of date. Please restart the game servers to get to a new version.`, "Version check complete", 
			"rbxassetid://9894144899", 15, nil, {
				{
					["Text"] = "Reboot servers with Soft Shutdown+",
					["Icon"] = "",
					["Callback"] = function()
						--// TODO
						return
					end,
				}})
		NewUpdateLogText(`A new version is available! {VersModule.Version.String} was released on {VersModule.ReleaseDate}. Showing the logs from that update.`)
	else
		Frame.Version.Text = `Version {VersModule.Version.String} ({VersModule.ReleaseDate})`
	end

	for i, Note in VersModule.ReleaseNotes do
		NewUpdateLogText(Note)
	end
end

local function GetGameOwner(IncludeType)
	local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)

	if GameInfo.Creator.CreatorType == "User" then
		return GameInfo.Creator.Id, IncludeType and "User" or nil
	else
		return GroupService:GetGroupInfoAsync(GameInfo.Creator.CreatorTargetId).Owner.Id, IncludeType and "Group" or nil
	end
end

local function NewAdminRank(Name, Protected, Members, PagesCode, AllowedPages, Why, ActingUser, RankID, IsEdit)
	local Success, Error = pcall(function()
		local ShouldStep = false
		local OldRankData = nil
		local Info = AdminsDS:GetAsync("CurrentRanks") or {
			Count = 0,
			Names = {},
			GroupAdminIDs = {}
		}
		
		if not RankID then
			RankID = Info.Count
			ShouldStep = true
		end
		
		if IsEdit then
			OldRankData = AdminsDS:GetAsync(`_Rank{RankID}`)
		end

		AdminsDS:SetAsync(`_Rank{RankID}`, {
			["RankID"] = RankID,
			["RankName"] = Name,
			["Protected"] = Protected,
			["Members"] = Members,
			["PagesCode"] = PagesCode,
			["AllowedPages"] = AllowedPages,
			["ModifiedPretty"] = os.date("%d/%m/%y at %I:%M %p"),
			["ModifiedUnix"] = os.time(),
			["Reason"] = Why,
			["Modifications"] = {
				{
					["Reason"] = "Created this rank.",
					["ActingAdmin"] = ActingUser,
					["Actions"] = {"created this rank"}
				}
			},
			["CreatorID"] = ActingUser
		})
		
		if ShouldStep then
			Info.Count = Info.Count + 1
			Info.Names = Info.Names or {}
			table.insert(Info.Names, Name)
		end
		
		if OldRankData ~= nil then
			for i, v in OldRankData.Members do
				for i, Member in Members do
					if Member == v then 
						Print("NOT removing because they're still here!")
						continue
					end
				end
				
				if v.ID == "" then
					warn("ID wasn't an ok value, skipping")
					continue
				end
				
				if v.MemberType == "User" then
					AdminsDS:RemoveAsync(v.ID)
				else
					AdminsDS:RemoveAsync(`{v.ID}_Group`)
				end
			end
		end

		for i, v in Members do
			if v.MemberType == "User" then
				AdminsDS:SetAsync(v.ID, {
					IsAdmin = true,
					RankName = Name,
					RankId = Info.Count - 1
				})
			else
				AdminsDS:SetAsync(`{v.ID}_Group`, {
					IsAdmin = true,
					RankName = Name,
					RankId = Info.Count - 1,
					GroupRank = v.GroupRank
				})

				Info.GroupAdminIDs[v.ID] = {
					GroupID = v.ID,
					RequireRank = v.GroupRank ~= 0,
					RankNumber = v.GroupRank,
					AdminRankID = Info.Count - 1,
					AdminRankName = Name
				}
			end
		end

		AdminsDS:SetAsync("CurrentRanks", {
			Count = Info.Count,
			Names = Info.Names,
			GroupAdminIDs = Info.GroupAdminIDs
		})
	end)

	if Success then
		xpcall(
			function()
				MessagingService:PublishAsync("Administer", {["Message"] = "ForceAdminCheck"})
			end,
			function(e)
				return {false, `We made the rank fine, but failed to publish the event to tell other servers to check. Please try freeing up some MessagingService slots. {e}`}
			end
		)
		return {true, `Successfully made 1 rank!`}
	else
		return {false, `Something went wrong: {Error}`}
	end
end

local function EditRank(ActingUser, RankID, Actions)
	local Rank = AdminsDS:GetAsync(`_Rank{RankID}`)
	local CRs = AdminsDS:GetAsync("CurrentRanks")
	
	if Rank["Protected"] then
		--// checkmate client
		return {false, "Protected ranks cannot be edited by anybody but the system."}
	end
	
	if Actions[1]["Type"] == "DELETE" then
		for i, v in Rank["Members"] do
			if v.MemberType == "User" then
				AdminsDS:RemoveAsync(v.ID)
			else
				AdminsDS:RemoveAsync(`{v.ID}_Group`)
				CRs.GroupAdminIDs[v.ID] = nil
			end
		end
		
		Rank["RankName"] = "(deleted)"
		Rank["Protected"] = true
		
		AdminsDS:SetAsync(`_Rank{RankID}`, Rank)
		AdminsDS:SetAsync("CurrentRanks", CRs)
		
		return {true, "Done"}
	end

	for i, Action in Actions do
		if Action["Type"] == "REMOVE_GROUP" then
			for i, Member in Rank["Members"] do
				if Member["MemberType"] == "Group" and Member["ID"] == Action["UserID"] then
					Rank["Members"][i] = nil
					CRs["GroupAdminIDs"][Action["UserID"]] = nil
					AdminsDS:RemoveAsync(`{Action["UserID"]}_Group`)
				end
			end
		elseif Action["Type"] == "REMOVE_USER" then
			for i, Member in Rank["Members"] do
				if Member["MemberType"] == "User" and Member["ID"] == Action["UserID"] then
					Rank["Members"][i] = nil
					AdminsDS:RemoveAsync(Action["UserID"])
				end
			end
		elseif Action["Type"] == "ADD_GROUP" then
			table.insert(Rank["Members"], {
				["ID"] = Action["UserID"],
				["GroupRank"] = Action["ReqGroupID"],
				["MemberType"] = "Group"
			})

			CRs.GroupAdminIDs[Action["UserID"]] = {
				GroupID = Action["UserID"],
				RequireRank = Action["ReqGroupID"] ~= 0,
				RankNumber = Action["ReqGroupID"],
				AdminRankID = RankID,
				AdminRankName = Rank["RankName"]
			}

		elseif Action["Type"] == "ADD_USER" then
			table.insert(Rank["Members"], {
				["ID"] = Action["UserID"],
				["MemberType"] = "User"
			})

			AdminsDS:SetAsync(Action["UserID"], {
				IsAdmin = true,
				RankName = Rank["RankName"],
				RankId = RankID
			})
		elseif Action["Type"] == "RENAME"      then
			Rank["RankName"] = Action["NewName"]
		elseif Action["Type"] == "ADD_APP"     then
			table.insert(Rank["AllowedPages"], {
				["Name"] = Action["AppName"],
				["DisplayName"] = Action["AppDisplayName"],
				["Icon"] = Action["AppIcon"]
			})
		elseif Action["Type"] == "REMOVE_APP"  then
			for i, App in Rank["AllowedPages"] do
				if App["Name"] == Action["AppName"] then
					Rank["AllowedPages"][i] = nil
				end
			end
		end
	end
	
	AdminsDS:SetAsync(`_Rank{RankID}`, Rank)
	AdminsDS:SetAsync("CurrentRanks", CRs)

	return {true, "Done"}
end

local function New(plr, AdminRank, IsSandboxMode)
	if not AdminRank then
		return {false, "You must provide a valid AdminRank!"}
	end

	local Rank = AdminsDS:GetAsync(`_Rank{AdminRank}`)

	table.insert(InGameAdmins, plr)
	local NewPanel = script.AdministerMainPanel:Clone()
	
	xpcall(function()
		NewPanel:SetAttribute("_AdminRank", Rank.RankName)
		NewPanel:SetAttribute("_SandboxModeEnabled", IsSandboxMode)
		NewPanel:SetAttribute("_HomeWidgets", HttpService:JSONEncode(HomeDS:GetAsync(plr.UserId) or BaseHomeInfo))
		NewPanel:SetAttribute("_InstalledApps", HttpService:JSONEncode(require(script.AppAPI).AllApps))
		NewPanel:SetAttribute("_CurrentBranch", HttpService:JSONEncode(CurrentBranch))
	end, function() --// patch this weird startup crash on firsttime boot
		Print("First-time boot, we're not ready for AdminRank yet!")
		NewPanel:SetAttribute("_AdminRank", "Administrator")
		NewPanel:SetAttribute("_SandboxModeEnabled", IsSandboxMode)
		NewPanel:SetAttribute("_HomeWidgets", HttpService:JSONEncode(HomeDS:GetAsync(plr.UserId) or BaseHomeInfo))
		NewPanel:SetAttribute("_InstalledApps", HttpService:JSONEncode(require(script.AppAPI).AllApps))
		NewPanel:SetAttribute("_CurrentBranch", HttpService:JSONEncode(CurrentBranch))
	end)

	local AllowedPages = {}
	for i, v in Rank["AllowedPages"] do
		AllowedPages[v["DisplayName"]] = {
			["Name"] = v["DisplayName"], 
			["ButtonName"] = v["Name"]
		}
	end
	--for i, v in ipairs(AllowedPages) do
	--	print(v)
	--end

	if Rank.PagesCode ~= "*" then
		for _, v in NewPanel.Main:GetChildren() do
			if not v:IsA("Frame") then continue end
			if table.find({'Animation', 'Apps', 'Blur', 'Header', 'Home', 'NotFound', "Welcome", 'HeaderBG'}, v.Name) then continue end

			local Success, Error = pcall(function()
				if AllowedPages[v.Name] == nil then
					local Name = v.Name

					NewPanel.Main.Apps.MainFrame[v:GetAttribute("LinkedButton")]:Destroy()
					v:Destroy()
					Print(`Removed {AllowedPages[Name]["Name"]} from this person's panel because: Not Allowed by rank`)
				end
			end)

			if not Success then
				warn(`[{Config["Name"]}]: {v.Name} has a seemingly mismatched name!`)
			end
		end
	end

	NewPanel.Parent = plr.PlayerGui
	VersionCheck(plr)
	NewNotification(plr, 
		`{Config["Name"]} version {CurrentVers} loaded! {
		IsSandboxMode and "Sandbox mode enabled." or 
			`You're a{string.split(string.lower(Rank.RankName), "a")[1] == "" and "n" or ""} {Rank.RankName}`}. Press {
		`{GetSetting("RequireShift") and "Shift + " or ""}{GetSetting("PanelKeybind")}`
		} to enter.`,
		"Welcome!",
		"rbxassetid://10012255725",
		10
	)
end

local function GetAllRanks()
	local Count = AdminsDS:GetAsync("CurrentRanks")
	local Ranks = {}
	local Polls = 0
	
	--// Load in parallel
	for i = 1, tonumber(Count["Count"]) do
		task.spawn(function()
			Ranks[i] = AdminsDS:GetAsync("_Rank"..i)
		end)
	end
	
	repeat 
		Polls += 1
		task.wait(.05) 
		--print(#Ranks / Count["Count"], Ranks, Count, Polls) 
	until #Ranks == Count["Count"] or Polls == 10
	
	if Polls == 10 then
		Print(`Only managed to load {#Ranks / Count["Count"]}% of ranks, possibly corrept rank exists!`)
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

local function GetMediaForGame(PlaceId)
	local Default = "" --// add soon
	local UniverseIdInfo, Attempts = 0,0
	repeat
		local Success, Error = pcall(function()
			Attempts += 1
			UniverseIdInfo = HttpService:JSONDecode(HttpService:GetAsync(`https://rblx.notpyx.me/apis/universes/v1/places/{PlaceId}/universe`))["universeId"] or 0
		end)
	until Success or Attempts > 3

	if UniverseIdInfo == 0 then return Default end

	local MediaData = HttpService:JSONDecode(HttpService:GetAsync(`https://rblx.notpyx.me/games/v2/games/{UniverseIdInfo}/media`))["data"]
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
				return Default --// exhausted all of our images, none good
			end
		else
			return "rbxassetid://"..MediaData[Tries]["imageId"]
		end
	end
end

local function GetAppInfo_(Player, AppServer, AppID)
	if not table.find(InGameAdmins, Player) then
		return {["Error"] = "Something went wrong", ["Message"] = "Unauthorized"}
	else
		local Success, Content = pcall(function()
			local resp = HttpService:RequestAsync({
				Url = `{AppServer}/app/{AppID}`,
				Method = "GET"
			})

			return HttpService:JSONDecode(HttpService:GetAsync(`{AppServer}/app/{AppID}`))
		end)

		if not Success then
			warn(Content, AppID)
			return {
				["Error"] = "Something went wrong, try again later. This is probably due to the app server shutting down mid-session!", 
				["Message"] = Content
			}
		else
			return Content
		end
	end
end

local function InstallApp(AppID, Source, Name)
	Print(`Installing {AppID} from {Source}!`)
	--// Install directly based on a Roblox ID. 
	--// Will verify it's valid eventually, currently hopefully the loader will do validation. I'm tired.
	local AppList = AppDB:GetAsync("AppList") or {}

	for i, App in AppList do
		if App["ID"] == AppID then
			Print("Not installing that app because it already exists!")
			return {false, "You can only install an app once!"}
		end
	end

	table.insert(AppList, {
		["ID"] = AppID,
		["InstallDate"] = os.time(),
		["InstallSource"] = Source or "Manual ID install",
		["Name"] = Name ~= nil and Name or "Unknown" --// surely wont cause any issues
	})

	AppDB:SetAsync("AppList", AppList)
	return {true, "Successfully installed an app with no issues"}
end

local function InstallAdministerApp(Player, ServerName, AppID)
	-- Get app info
	local Success, Content = pcall(function()
		return GetAppInfo_(Player, ServerName, AppID)
	end)

	if not Success then
		return {false, "Failed reaching out to the App Server. Perhaps it's offline?"}
	end

	if Content["Error"] then
		return {false, Content["Error"]}
	end

	if Content["AppInstallID"] then
		if tostring(Content["AppInstallID"]) == "0" then
			return {false, "Bad app ID! This app server is returning bad data."}
		end

		local Module
		local Success, Error = pcall(function()
			Module = require(Content["AppInstallID"])
		end)

		if not Success then
			return {false, `Something went wrong with the module: {Error}`}
		end

		local Result = InstallApp(Content["AppInstallID"], ServerName, Content["AppName"])

		if not Result[1] then
			Print("Result exited early, not telling the server...")
			return {false, Result[2]}
		else
			task.spawn(function()
				Print(HttpService:RequestAsync(
					{
						["Method"] = "POST",
						["Url"] = `{ServerName}/install/{Content["AdministerMetadata"]["AdministerID"]}`
					}
					))
				Module.OnDownload()
			end)
			
			return {true, "Success!"}
		end
	else
		return {false, "No AppInstallID present! Bad app server."}
	end
end

local function InstallServer(ServerURL: string)
	Print(`[{Config.Name}]: Installing App server...`)
	local Success, Result = pcall(function()
		return HttpService:JSONDecode(HttpService:GetAsync(ServerURL.."/.administer/server"))
	end)


	if Result["server"] == "AdministerAppServer" then
		Print("This sever is valid, proceeding...")

		table.insert(AppServers, ServerURL)
		AppDB:SetAsync("AppServerList", AppServers)

		Print("Successfully installed!")
		return "Success!"
	else
		warn(`{ServerURL} is not an Administer app server! Make sure it begins with https://, does not have a forwardslash after the url, and is a valid App server. If you would like to set up a new one, check out the docs.`)

		return "Invalid app server! Check logs for more info."
	end
end

local function GetAppList()
	local FullList = {}
	local Raw
	
	if GetSetting("DisableAppServerFetch") == true then
		print("Not getting list due to your settings!")
		return {}
	end


	for i, Server in AppServers do
		local Success, Apps = pcall(function()
			Raw = HttpService:RequestAsync({
				Url = `{Server}/list`,
				Method = "GET"
			})
			
			return HttpService:JSONDecode(Raw.Body)
		end)

		if not Success then
			warn(`[{Config.Name}]: Failed to contact app server {Server} - is it online? If the issue persists, you should probably remove it.`)
			-- continue 
			return {false, Raw.StatusCode} 
		end

		for i, v in Apps do
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

local function InitializeApps()
	Print("Bootstrapping apps...")

	if GetSetting("DisableApps") then
		Print(`App Bootstrapping disabled due to configuration, please disable!`)
		return false
	end

	local DelaySetting = GetSetting("AppLoadDelay")

	if DelaySetting == "InStudio" and game:GetService("RunService") then
		task.wait(3)
	elseif DelaySetting == "All" then
		task.wait(3)
	end

	local Apps = AppDB:GetAsync("AppList")

	if Apps == nil then
		--Print(`Bootstrapping apps failed because the App list was nil! This is either a Roblox issue or you have no Apps installed!`)
		DidBootstrap = true
		return false
	end

	local AppsCount, i, TotalAttempts, Start = #Apps, 0, 0, tick()

	for _, AppObj in Apps do
		local _t = tick()
		task.spawn(function()
			local Success, Error = pcall(function()
				local App

				xpcall(function()
					App = require(AppObj["ID"])
				end, function(e)
					warn(`[{Config.Name}]: Failed to require {AppObj["Name"]} ({e})! Please ensure it is public.`)
					error("Failed")
				end)

				local AppName, PrivateDescription, Version = App.Init()
				local _a = 0

				repeat --// this waits until the app is initialized and put into AllApps by the RuntimeAPI
					task.wait()
					local _s, _e = xpcall(function() --// init metadata
						require(script.AppAPI).AllApps[AppName]["BuildTime"] = string.sub(tostring(tick() - _t), 1, 5)
						require(script.AppAPI).AllApps[AppName]["PrivateAppDesc"] = PrivateDescription
						require(script.AppAPI).AllApps[AppName]["InstalledSince"] = AppObj["InstallDate"]
						require(script.AppAPI).AllApps[AppName]["InstallSource"] = AppObj["InstallSource"]
						require(script.AppAPI).AllApps[AppName]["Version"] = Version or "v0"
						require(script.AppAPI).AllApps[AppName]["AppID"] = AppObj["ID"]
					end, function(er)
						Print(`Failed to load {AppName}, retrying soon! {er}`)
						task.wait(.05)
					end)
					_a += 1
				until _s or _a >= 50

				if _a == 50 then
					warn(`[{Config.Name}]: Failed to init metadata for {AppObj["Name"]} after 50 tries (limit reached)!`)
				end
			end)

			if not Success then
				i += 1
				warn(`[{Config.Name}]: Failed to App.Init() on {AppObj["Name"]} ({Error})! If this is your app, please verify your main module's init call according to the docs.`)
			else
				i += 1
			end


		end)
	end

	repeat 
		task.wait(.1) 
		TotalAttempts += 1
	until i == AppsCount or TotalAttempts == 10

	if TotalAttempts == 10 then
		warn(`[{Config.Name}]: Failed to initialize some apps after the polling limit! Try looking for faulty apps ({i/AppsCount}% of {AppsCount} cloud apps loaded in {TotalAttempts} tries/{tick() - Start}s).`)
	end

	DidBootstrap = true

	InitClock["AppsBootstrap"] = tick() - InitClock["TempInit"]
	InitClock["TempInit"] = tick()

	return true
end

local function IsAdmin(Player: Player)
	if GetSetting("SandboxMode") and game:GetService("RunService"):IsStudio() then
		return true, "Sandbox mode enabled as per settings", 1, "Admin"
	end

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

	if RanksData["IsAdmin"] then
		return true, "Data based on settings configured by an admin.", RanksData["RankId"], RanksData["RankName"]
	end

	local RanksIndex = AdminsDS:GetAsync("CurrentRanks")

	for ID, Group in RanksIndex.GroupAdminIDs do
		if not Player:IsInGroup(ID) then continue end

		if Group["RequireRank"] then
			return Player:GetRankInGroup(ID) == Group["RankNumber"], "Data based on group rank", Group["AdminRankID"], Group["AdminRankName"]
		else
			return true, "User is in group", Group["AdminRankID"], Group["AdminRankName"]
		end
	end

	return false, "Player was not in override or any rank", 0, "NonAdmin"
end

local function SocketMessage(Msg)
	local Data = Msg["Data"]

	if Data["Message"] == "ForceAdminCheck" then
		for i, Player in Players:GetPlayers() do
			local IsAdmin, Reason, RankID, RankName = IsAdmin(Player)

			if IsAdmin and not table.find(InGameAdmins, Player) then
				task.spawn(New, Player, RankID, false)
			elseif not IsAdmin and table.find(InGameAdmins, Player) then
				InGameAdmins[Players] = nil
				Player.PlayerGui:FindFirstChild("AdministerMainPanel"):Destroy()
			end
		end
	end
end

InitClock["FunctionDefinition"] = tick() - InitClock["TempInit"]
InitClock["TempInit"] = tick()

--// TODO: migrate these to standard BuildRemote

local GetAllMembers = Instance.new("RemoteFunction")
GetAllMembers.Parent, GetAllMembers.Name = Remotes, "GetAllMembers"

--// Homescreen
local UpdateHomePage = Instance.new("RemoteFunction", Remotes)
UpdateHomePage.Name = "UpdateHomePage"

if AppServers == nil then
	AppServers = {}
	Print("Performing first-time app setup..")
	InstallServer("https://administer.notpyx.me")
	InstallAdministerApp("_AdminBypass", "https://administer.notpyx.me", "1")

	GetAppList()
end

task.spawn(InitializeApps)

if not AdminsDS:GetAsync("_Rank1") then
	Print(`Running first time rank setup!`)

	local Owner, Type = GetGameOwner(true)

	if Type == "Group" then
		Print("Adding a GROUP rank!")
		Print(
			NewAdminRank("Admin", true, {
				{
					['MemberType'] = "Group",
					['ID'] = game.CreatorId,
					['GroupRank'] = "255"
				}
			},
			"*",
			{},
			"Added by System for first-time setup",
			1
			)
		)

	else
		Print("Adding a PLAYER rank!")
		Print(
			NewAdminRank("Admin", true, {
				{
					['MemberType'] = "User",
					['ID'] = Owner
				}
			},
			"*",
			{},
			"Created by System for first-time setup",
			1
			)
		)
	end
	InitClock["AdminSetup"] = tick() - InitClock["TempInit"]
	InitClock["TempInit"] = tick()
end

Players.PlayerAdded:Connect(function(plr)
	if ShouldLog then
		table.insert(AdminsBootstrapped, plr)
	end

	repeat task.wait(.1) until DidBootstrap

	local IsAdmin, Reason, RankID, RankName = IsAdmin(plr)
	Print("New join:", IsAdmin, Reason, RankID, RankName)

	if IsAdmin then
		task.spawn(New, plr, RankID, false)
	elseif game:GetService("RunService"):IsStudio() and GetSetting("SandboxMode") then
		task.spawn(New, plr, RankID, true)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	return table.find(InGameAdmins, plr) and table.remove(InGameAdmins, table.find(InGameAdmins, plr))
end)

InitClock["RegisterStartupEvents"] = tick() - InitClock["TempInit"]
InitClock["TempInit"] = tick()

xpcall(
	function()
		MessagingService:SubscribeAsync("Administer", SocketMessage)
	end,
	
	function()
		warn("MessagingService seems to be busy, some cross-server features unfunctional!")
	end
)

-- Catch any leftovers
task.spawn(function()
	repeat task.wait(.1) until DidBootstrap
	ShouldLog = false

	for i, v in Players:GetPlayers() do
		if table.find(AdminsBootstrapped, v) then continue end

		local IsAdmin, Reason, RankID, RankName = IsAdmin(v)
		if IsAdmin then
			task.spawn(New, v, RankID)
		end
	end

	AdminsBootstrapped = {}
end)

InitClock["BootstrapAdmins"] = tick() - InitClock["TempInit"]

-- // Client communication
BuildRemote("RemoteFunction", "Ping", false, function() 
	return true
end)

BuildRemote("RemoteFunction", "CheckForUpdates", true, function(Player)
	VersionCheck(Player)
end)

BuildRemote("RemoteFunction", "InstallAppServer", true, function(Player, URL)
	return InstallServer(URL)
end)

BuildRemote("RemoteFunction", "GetAppList", true, function(Player)
	return GetAppList()
end)

BuildRemote("RemoteFunction", "InstallApp", true, function(Player, AppServer, AppID)
	return (AppServer == "rbx" and InstallApp(AppID)) or InstallAdministerApp(Player, AppServer, AppID)
end)

BuildRemote("RemoteFunction", "GetAppInfo", true, function(Player, AppServer, AppID)
	return GetAppInfo_(Player, AppServer, AppID)
end)

-- ManageAdmin
BuildRemote("RemoteFunction", "NewRank", true, function(Player, Package)
	local IsAdmin, d, f, g, h = IsAdmin(Player) -- For now, the ranks info doesn't matter. It will soon to prevent exploits from low ranks.
	if not IsAdmin then
		warn(`[{Config.Name}]: Got unauthorized request on ManageAdminRemote from {Player.Name} ({Player.UserId})`)
		return {
			Success = false,
			Header = "Something went wrong",
			Message = "You're not authorized to complete this request."
		}
	end
	
	if Package.EditMode then
		
	end

	local Result = NewAdminRank(Package["Name"], Package["Protected"], Package["Members"], Package["PagesCode"], Package["AllowedPages"], `Added by {Player.Name}`, Player.UserId, Package.EditingRankID, Package.IsEditing)

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
			Message = `We couldn't process that request right now, try again later.\n\n{Result[2] or "No error was returned for some reason... try checking the log!"}`
		}
	end
end)

BuildRemote("RemoteFunction", "GetRanks", true, function(Player, Type)
	if Type == "LegacyAdmins" then
		local Admins = {}
		
		for i, Admin in require(script.Admins).Admins do
			table.insert(Admins, {
				["ID"] = Admin,
				["MemberType"] = "User"
			})
		end
		
		for i, Admin in require(script.Admins).Groups do
			table.insert(Admins, {
				["ID"] = Admin,
				["MemberType"] = "Group"
			})
		end
		
		return Admins
	end
	
	return GetAllRanks()
end)

BuildRemote("RemoteFunction", "FilterString", false, function(Player, String)
	return GetFilteredString(Player, String)
end)

BuildRemote("RemoteFunction", "GetPasses", false, function(Player)
	local Attempts, _Content = 0, ""

	repeat
		local Success, Error = pcall(function()
			Attempts += 1
			_Content = HttpService:GetAsync(`https://rblx.notpyx.me/games/v1/games/1778091660/game-passes?sortOrder=Asc&limit=50`, true)
		end)
	until Success or Attempts > 5

	return HttpService:JSONDecode(_Content)["data"] or {
		{
			["price"] = "Failed to load.",
			["id"] = 0
		},
		{
			["price"] = "The proxy may be offline or experiencing issues.",
			["id"] = 0
		},
	}
end)

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
		Print(`Saving homescreen data for {Player.Name}.`)

		HomeDS:SetAsync(Player.UserId, HomeInfo)
	end)
end

BuildRemote("RemoteFunction", "GetAllApps", true, function(Player, Source)
	if Source == nil or Source == "Bootstrapped" then
		return require(script.AppAPI).AllApps
	elseif Source == "DataStore" then
		return AppDB:GetAsync("AppList")
	elseif Source == "Combined" then
		local AppList = AppDB:GetAsync("AppList")
		local Final = {}

		for i, Object in AppList do
			Object["ObjSource"] = "DSS"
			table.insert(Final, Object)
		end

		for i, Object in require(script.AppAPI).AllApps do
			Object["ObjSource"] = "AppAPI"
			table.insert(Final, Object)
		end

		return Final
	end
end)

BuildRemote("RemoteFunction", "ManageApp", true, function(Player, Payload)
	if not table.find({"disable", "remove"}, Payload["Action"]) then
		return {false, "Invalid action."}
	end

	local Apps = AppDB:GetAsync("AppList")
	local RemovedDB = AppDB:GetAsync("Hidden")

	if Payload["Action"] == "remove" then
		warn(`[{Config["Name"]}]: Removing app {Payload["AppID"]} (requested by {Player.Name})`)

		for i, App in Apps do
			if App["ID"] == Payload["AppID"] then
				Print("found and gone!", App)
				Apps[i] = nil
			end
		end

		AppDB:SetAsync("AppList", Apps)
	end
end)

BuildRemote(
	"RemoteFunction", 
	"GetProminentColorFromUserID", 
	true, 
	function(Player, UserID)
	--// Wrap in a pcall incase an API call fails somewhere in the middle
		local s, Content = pcall(function()
			local Tries = 0
			local Raw

			--// try a bunch of times bc this proxy server sucks and i need a new one
			repeat
				Tries += 1
				local success, data = pcall(function()
					return HttpService:GetAsync(`https://rblx.notpyx.me/thumbnails/v1/users/avatar-headshot?userIds={UserID}&size=420x420&format=Png&isCircular=false`)
				end)
				Raw = data
			until success or Tries == 2

			if Tries == 2 then
				--// give up
				return  {33,53,122}
			end

			local Decoded = HttpService:JSONDecode(Raw)
			local UserURL = Decoded["data"][1]["imageUrl"]

			return HttpService:JSONDecode(HttpService:GetAsync("https://administer.notpyx.me/misc-api/prominent-color?image_url="..UserURL))
		end)
		
		Print(s)
		Print(Content)

		return s and Content or {33,53,122}
	end
)

BuildRemote("RemoteFunction", "SearchAppsByMarketplaceServer", true, function(Player, Server, Query)
	return HttpService:JSONDecode(HttpService:GetAsync(`{Server}/rich-search/{Query}`))
end)

--// Spawn admin check refresh thread
task.spawn(function()
	while task.wait(tonumber(GetSetting("AdminCheck"))) do
		for i, Admin: Player | String in InGameAdmins do
			if Admin == "_AdminBypass" then continue end
			local IsAdmin, _, _, _ = IsAdmin(Admin)

			if not IsAdmin then
				if not Admin.PlayerGui:FindFirstChild("AdministerMainPanel") then
					print("... ?")
				else
					Admin.PlayerGui.AdministerMainPanel:Destroy()
				end
			end
		end
	end
end)

pcall(function()
	HttpService:PostAsync("https://administer.notpyx.me/report-version", HttpService:JSONEncode({
		["version"] = Config.Version,
		["branch"] = CurrentBranch["BranchName"]
	}))
end)

InitClock["ConstructRemotes"] = tick() - InitClock["TempInit"]
print([[

▄▀█ █▀▄ █▀▄▀█ █ █▄ █ █ █▀ ▀█▀ █▀▀ █▀█
█▀█ █▄▀ █ ▀ █ █ █ ▀█ █ ▄█  █  ██▄ █▀▄

]])

repeat task.wait() until DidBootstrap

print(`✓ Successfully initialized {Config["Name"]} {Config["Version"]} in {tick() - InitClock["RealInit"]}s`)

local Clean = {}

for k, v in InitClock do
	if table.find({"RealInit", "TempInit"}, k) then continue end

	Clean[k] = string.sub(tostring(v), 1, 9)
end

Clean["FullExecute"] = tick() - InitClock["RealInit"]

Print(HttpService:JSONEncode(Clean))

--// cleanup

InitClock = nil
Clean = nil