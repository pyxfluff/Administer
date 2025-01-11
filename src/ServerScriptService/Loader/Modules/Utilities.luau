--// pyxfluff 2024
--// Do NOT stricttype this file

--// Initialization
local Utils = {
	Time = {}
}

--// Dependencies
--// Do not add anything here you don't need, it will cause circular imports.
local Var = require(script.Parent.Parent.Core.Variables)
local Locales = script.Parent.Parent.Core.Locales

Utils.GetSetting = function(Setting)
	return ""
end

Utils.Logging = {
	Print = function(...)
		print(...)
	end,

	Warn = function(...)
		warn(debug.traceback(...))
	end,

	Error = function(...)
		error(debug.traceback(...))
	end,
	
	Debug = function(...)
		--// TODO
		print(debug.traceback(...))
	end,
}

Utils.IsAdmin = function(self, Player: Player): {IsAdmin: boolean?, Reason: string?, RankID: number?, RankName: string?}
	if self.GetSetting("SandboxMode") and game:GetService("RunService"):IsStudio() or game.GameId == 3331848462 then
		return {
			["IsAdmin"] =  true, 
			["Reason"] = "Sandbox mode enabled as per settings", 
			["RankID"] = 1, 
			["RankName"] = "Admin"
		}
	end

	local RanksIndex = game:GetService("DataStoreService"):GetDataStore("Administer_Admins"):GetAsync("CurrentRanks")

	if table.find({}, Player.UserId) ~= nil then
		return {
			["IsAdmin"] =  true, 
			["Reason"] = "Found in AdminIDs override", 
			["RankID"] = 1, 
			["RankName"] = "Admin"
		}
	else
		for i, v in {} do
			if Player:IsInGroup(v) then
				return {
					["IsAdmin"] =  true, 
					["Reason"] = "Found in AdminIDs override", 
					["RankID"] = 1, 
					["RankName"] = "Admin"
				}
			end
		end
	end

	local _, Result = xpcall(function(): {IsAdmin: boolean?, Reason: string?, RankID: number?, RankName: string?}
		if RanksIndex.AdminIDs[tostring(Player.UserId)] ~= nil then
			return {
				["IsAdmin"] = true,
				["Reason"] = "User is in the ranks index", 
				["RankID"] = RanksIndex.AdminIDs[tostring(Player.UserId)].AdminRankID,
				["RankName"] = RanksIndex.AdminIDs[tostring(Player.UserId)].AdminRankName
			}
		else
			return {}
		end
	end, function(er)
		--// Safe to ignore an error
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

Utils.NewNotification = function(Admin, Body, Title, Icon, Duration, NotificationSound, Options: {}?)
	--// Spawns a new admin notification. Yields, use with task.spawn to avoid.
	local Panel = Admin.PlayerGui.AdministerMainPanel
	local OpenTime = 1.25

	local Placeholder  = Instance.new("Frame")
	Placeholder.Parent = Panel.Notifications
	Placeholder.BackgroundTransparency = 1
	Placeholder.Size = UDim2.new(1.036,0,0.142,0)

	local Notification = Panel.Notifications.Template:Clone()
	Notification.Visible = true		
	Notification = Notification.NotificationContent
	Notification.Parent.Position = UDim2.new(0,0,1.3,0)
	Notification.Parent.Parent = Panel.NotificationsTweening
	Notification.Body.Text = Body
	Notification.Header.Title.Text = `<b>Administer</b> • {Title}`
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
		Var.Services.TweenService:Create(
			Notification.Parent,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(-.018,0,.858,0),
			}
		),
		Var.Services.TweenService:Create(
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
	local NotifTween2 = Var.Services.TweenService:Create(
		Notification,
		TweenInfo.new(
			OpenTime * .7,
			Enum.EasingStyle.Quad
		),
		{
			Position = UDim2.new(1,0,0,0),
			GroupTransparency = 1
		})

		NotifTween2:Play()
		NotifTween2.Completed:Wait()
		pcall(function()
			Notification.Parent:Destroy()
		end)
	end

	Notification.Buttons.DismissButton.MouseButton1Click:Connect(Close)
	task.delay(Duration, Close)
end

function Utils.NewRemote(RemoteType: string, RemoteName: string, AuthRequired: boolean, Callback): ()
	if not table.find({"RemoteFunction", "RemoteEvent"}, RemoteType) then
		return false, "Invalid remote type!"
	end

	local Rem = Instance.new(RemoteType)
	Rem.Name = RemoteName
	Rem.Parent = Var.RemotesPath

	if RemoteType == "RemoteEvent" then
		Rem.OnServerEvent:Connect(function(Player, ...)
			if AuthRequired and not table.find(Var.Admins.InGame, Player) then
				return false
			end

			Callback(Player, ...)
			
			return true
		end)

		return
	elseif RemoteType == "RemoteFunction" then
		Rem.OnServerInvoke = function(Player, ...)
			--// TODO: FIX
			--if AuthRequired and not table.find(Var.Admins.InGame, Player) then
			--	return false
			--end

			Utils.Logging.Print(`<-- [{Player.UserId}] {RemoteName}`)

			local t, cbk = tick(), Callback(Player, ...)

			Utils.Logging.Print(`--> Processed ({tick() - t})`)

			return cbk
		end

		return
	end

	return
end

function Utils.Time.RelativeFormat(Unix)
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

function Utils.Time.FormatSeconds(Seconds: number)
	local Minutes = math.floor(Seconds / 60)
	Seconds = Seconds % 60

	if Utils.GetSetting("DisplayHours") then
		local Hours = math.floor(Minutes / 60)
		Minutes = Minutes % 60
		return string.format("%02i:%02i:%02i", Hours, Minutes, Seconds)
	else
		return string.format("%02i:%02i.%02i", Minutes, math.floor(Seconds), math.floor((Seconds % 1) * 100))
	end
end

function Utils.GetGameOwner(
	IncludeType: boolean
): number | {OwnerID: number, MemberType: "User" | Group}
	local Success, Result, Type = pcall(function()
		local GameInfo = Var.Services.MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)

		if GameInfo.Creator.CreatorType == "User" then
			return GameInfo.Creator.Id, IncludeType and "User" or nil
		else
			return Var.Services.GroupService:GetGroupInfoAsync(GameInfo.Creator.CreatorTargetId).Owner.Id, IncludeType and "Group" or nil
		end
	end)
	
	return not IncludeType and Result or {
		ID = Result,
		MemberType = Type
	}
end

function Utils.GetShortNumer(Number)
	local Decimals = 2

	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (Decimals or 3)) / 10 ^ (Decimals or 3)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

function Utils.GetGameMedia()
	local Default = "" --// add soon

	local MediaData = Var.Services.HttpService:JSONDecode(Var.Services.HttpService:GetAsync(`{Var.ProxyURL}/games/v2/games/{game.GameId}/media`))["data"]
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
	
	return Default
end

function Utils.GetFilteredString(Player: Player, String: string): {Success: boolean, Message: string}
	local Success, Text = pcall(function()
		return Var.Services.TextService:FilterStringAsync(String, Player.UserId)
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

function Utils.t(
	Player: Player | nil,
	Key: string
): string
	if Player == nil then
		return require(Locales["en-us"])[Key]
	else
		local LocaleResult = (Var.CachedLocales[Player.UserId] or Var.DataStores.Settings:GetAsync(Player.UserId.."Locale"))
		
		return require(Locales:FindFirstChild(LocaleResult and LocaleResult or "en-us"))[Key] or Key
	end
end

return Utils