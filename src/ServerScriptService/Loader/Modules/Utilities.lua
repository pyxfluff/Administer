--// pyxfluff 2024

--// Initialization
local Utils = {}

--// Dependencies
local Var = require(script.Parent.Parent.Core.Variables)

Utils.GetSetting = function(Setting)

end

Utils.Logging = {
	Print = function()

	end,

	Warn = function()

	end,

	Error = function()

	end
}

Utils.IsAdmin = function(self, Player: Player)
	if self.GetSetting("SandboxMode") and game:GetService("RunService"):IsStudio() or game.GameId == 3331848462 then
		return true, "Sandbox mode enabled as per settings", 1, "Admin"
	end

	local RanksIndex = game:GetService("DataStoreService"):GetDataStore("Administer_Admins"):GetAsync("CurrentRanks")

	if table.find({}, Player.UserId) ~= nil then
		return true, "Found in AdminIDs override", 1, "Admin"
	else
		for i, v in {} do
			if Player:IsInGroup(v) then
				return true, "Found in AdminIDs override", 1, "Admin"
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

Utils.NewNotification = function(Admin, Body, Title, Icon, Duration, NotificationSound, Options)
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

function Utils.NewRemote(RemoteType: string, RemoteName: string, AuthRequired: boolean, Callback: Function)
	if not table.find({"RemoteFunction", "RemoteEvent"}, RemoteType) then
		return false, "Invalid remote type!"
	end

	local Rem = Instance.new(RemoteType)
	Rem.Name = RemoteName
	Rem.Parent = Var.RemotesPath

	if RemoteType == "RemoteEvent" then
		Rem.OnServerEvent:Connect(function(Player, ...)
			if AuthRequired and not table.find(Var.Admins.InGame, Player) then
				return {false, "Unauthorized"}
			end

			return Callback(Player, ...)
		end)

		return
	elseif RemoteType == "RemoteFunction" then
		Rem.OnServerInvoke = function(Player, ...)
			if AuthRequired and not table.find(Var.Admins.InGame, Player) then
				return {false, "Unauthorized"}
			end

			Utils.Logging.Print(`<-- [{Player.UserId}] {RemoteName}`)

			local t, cbk = tick(), Callback(Player, ...)

			Utils.Logging.Print(`--> Processed ({tick() - t})`)

			return cbk
		end

		return
	end

	return
end

return Utils