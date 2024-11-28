local App = {
	APIVersion = "1.0",
	AdministerVersion = require(script.Parent.Config).Version,
	AllApps = {}
}

local ExistingButtons = {}
local Administer
local ActivateUI = true

---------------------------------

type Notification =  {
	Player: Player,
	Body: string,
	HeaderText: string,
	Icon: string?,
	OpenDuration: number?,
	Buttons: Table?,
	NotificationVisiblity:  "PLAYER" | "ALL_ADMINS",
	ShelfVisiblity: "FOR_TARGET" | "ALL_ADMINS" | "DO_NOT_DISPLAY",
	NotificationPriority: "CRITICAL" | "NORMAL" | "LOW"
}

App.ActivateUI = function(UI)
	if not ActivateUI then return end 
	Administer = UI
	ActivateUI = false

	local Events = game.ReplicatedStorage:FindFirstChild("AdministerApps")
	if not Events then
		Events = Instance.new("Folder")
		Events.Parent = game.ReplicatedStorage
		Events.Name = "AdministerApps"
	end
end

local NewButton = function(ButtonIcon, Name, Frame, Tip, HasBG, BGOverride)
	if table.find(ExistingButtons,ExistingButtons[Name]) then
		return {false, "Button was found already"}
	end

	local Success, Dock = pcall(function()
		return Administer:WaitForChild("Main"):WaitForChild("Apps"):WaitForChild("MainFrame")
	end)

	if not Success then
		warn(`[Administer AppAPI]: Failed finding the AppDock, is the panel fully loaded in? (Failed building AppButtonObject for {Name})`)
		return {false, "Something went wrong on our end, try checking the documentation."}
	end

	local Button: TextButton = Dock:WaitForChild("Template"):Clone()

	local Success, Error = pcall(function()
		local LinkID = game:GetService("HttpService"):GenerateGUID(false)

		Button.Visible = true
		Button.Name = Name
		Button.Icon.Image = ButtonIcon
		Button.Desc.Text = Tip
		Button.Reflection.Image = ButtonIcon
		Button.Title.Text = Name
		Button.IconBG.Visible = HasBG ~= nil and HasBG or true
		Button:SetAttribute("LinkID", LinkID)
		Button:SetAttribute("BackgroundOverride", BGOverride)

		local AppFrame = Frame:Clone()
		AppFrame.Parent = Administer.Main
		AppFrame.Name = Frame.Name
		AppFrame.Visible = false
		AppFrame:SetAttribute("LinkID", LinkID)
		AppFrame:SetAttribute("LinkedButton", Button.Name) --// easier server lookups

	end)
	if not Success then
		Button:Destroy()
		return {false, `Could not build the button! This is likely the result of a misconfiguration to the data passed to Administer. Error: {Error}`}
	else
		Button.Parent = Dock
		return {true, "Success!"}
	end
end

local function GetSetting(Setting): boolean | string
	local SettingModule = require(script.Parent.Config).Settings

	for i, v in pairs(SettingModule) do
		if v["Name"] == Setting then
			return v["Value"]
		end
	end
	return "Not found"
end


App.Build = function(OnBuild, AppConfig, AppButton)
	repeat task.wait() until Administer

	local Events = Instance.new("Folder")
	Events.Name = AppButton["Name"]
	Events.Parent = game.ReplicatedStorage.AdministerApps

	local BuiltAPI = {
		NewNotification = function(Notif: Notification)
			local TweenService = game:GetService("TweenService")
			local Panel = Notif.Player.PlayerGui.AdministerMainPanel
			local OpenTime = GetSetting("AnimationSpeed") * 1.25

			local Placeholder  = Instance.new("Frame")
			Placeholder.Parent = Panel.Notifications
			Placeholder.BackgroundTransparency = 1
			Placeholder.Size = UDim2.new(1.036,0,0.142,0)

			local Notification: Frame = Panel.Notifications.Template:Clone()
			Notification.Visible = true		
			Notification = Notification.NotificationContent
			Notification.Parent.Position = UDim2.new(0,0,1.3,0)
			Notification.Parent.Parent = Panel.NotificationsTweening
			Notification.Body.Text = Notif.Body
			Notification.Header.Title.Text = `<b>{AppButton["Name"]}</b> • {Notif.HeaderText}`
			Notification.Header.Administer.Image = AppButton["Icon"]
			Notification.Header.ImageL.Image = Notif.Icon  

			for i, Object in Notif.Buttons do
				local NewButton = Notification.Buttons.DismissButton:Clone()
				NewButton.Parent = Notification.Buttons

				NewButton.Name = Object["Text"]
				NewButton.Title.Text = Object["Text"]
				NewButton.ImageL.Image = Object["Icon"]
				NewButton.MouseButton1Click:Connect(function()
					Object["OnClick"]()
				end)
			end

			if Notif.Icon == "" then
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
					Notification.Parent:Destroy() -- shut up
				end)
			end

			Notification.Buttons.DismissButton.MouseButton1Click:Connect(Close)
			task.delay(Notif.OpenDuration, Close)
		end,

		AppNotificationBlip = function(Player: Player, Count: int)
			local AdministerPanel = Player.PlayerGui:FindFirstChild("AdministerMainPanel")
			if not AdministerPanel then
				return false, "This person does not have Administer, or their panel is missing this app."
			end
		end,

		IsAdmin = function(Player: Player, GroupsList)
			-- Manual overrides first
			local RanksIndex = game:GetService("DataStoreService"):GetDataStore("Administer_Admins"):GetAsync("CurrentRanks") or {}

			if table.find(require(script.Parent.Admins).Admins, Player.UserId) ~= nil then
				return true, "Found in AdminIDs override", 1, "Admin"
			else
				for i, v in pairs(require(script.Parent.Admins).Admins) do
					if not GroupsList then
						if Player:IsInGroup(v) then
							return true, "Found in AdminIDs override", 1, "Admin"
						end
					else
						if table.find(GroupsList, v) then
							return true, "Found in AdminIDs override", 1, "Admin"
						end
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
				end
			end, function(er)
				--// Safe to ignore an error
				print(er, "probably safe to ignore but idk!")
			end)

			if Result["IsAdmin"] then
				return Result["IsAdmin"], Result["Reason"], Result["RankID"], Result["RankName"]
			end

			--if RanksData["IsAdmin"] then
			--	return true, "Data based on settings configured by an admin.", RanksData["RankId"], RanksData["RankName"]
			--end

			for ID, Group in RanksIndex.GroupAdminIDs do
				ID = string.split(ID, "_")[1]
				if not Player:IsInGroup(ID) then continue end

				if Group["RequireRank"] then
					return Player:GetRankInGroup(ID) == Group["RankNumber"], "User is in group", Group["AdminRankID"], Group["AdminRankName"]
				else
					return true, "User is in group", Group["AdminRankID"], Group["AdminRankName"]
				end
			end

			return false, "Not in the admin index", 0, "NonAdmin"
		end,

		GetGlobalSetting = function(SettingName)
			--// Usually settings are protected against explots in the main code. What you do here should probably be secured.
			return GetSetting(SettingName)
		end,

		GetConfig = function()
			--// Once again, exposing your config to the world is a bad idea. Be sure to perform IsAdmin checks.
			return require(script.Parent.Config)
		end,
	}


	BuiltAPI.NewRemoteEvent = function(Name, OnServerEvent, ...)
		local NewEvent = Events:FindFirstChild(Name)
		if NewEvent then
			return NewEvent--, "Event already exists! To delete it, call API.DeleteEvent("..Name..",true)"
		else
			NewEvent = Instance.new("RemoteEvent")
			NewEvent.Name = Name
			NewEvent.Parent = Events
			if typeof(OnServerEvent) == "function" then
				NewEvent.OnServerEvent:Connect(OnServerEvent, ...)
			end
			return NewEvent
		end
	end

	BuiltAPI.NewRemoteFunction = function(Name: string, OnServerInvoke)
		local NewEvent = Events:FindFirstChild(Name)
		if NewEvent then
			return NewEvent--, "Event already exists! To delete it, call API.DeleteEvent("..Name..",true)"
		else
			NewEvent = Instance.new("RemoteFunction")
			NewEvent.Name = Name
			NewEvent.Parent = Events
			if typeof(OnServerInvoke) == "function" then
				NewEvent.OnServerInvoke = OnServerInvoke
			end
			return NewEvent
		end
	end

	local Button = NewButton(
		AppButton["Icon"],
		AppButton["Name"],
		AppButton["Frame"],
		AppButton["Tip"],
		AppButton["HasBG"],
		AppButton["BGOverride"]
	)

	if Button[1] == false then
		error(`BuildApp failure: {Button[2]}`)
	end

	task.spawn(function()
		OnBuild(AppConfig, BuiltAPI)
	end)

	App.AllApps[AppButton["Name"]] = {
		["AppConfig"] = AppConfig,
		["AppButtonConfig"] = AppButton
	}
end

App.AppEventsFolder = function(Name)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerApps")
	if not Events then
		Events = Instance.new("Folder")
		Events.Parent = game.ReplicatedStorage
		Events.Name = "AdministerApps"
	end
	local NewFolder = Events:FindFirstChild(Name)
	if NewFolder then
		return NewFolder, "Folder already exists!"
	else
		NewFolder = Instance.new("Folder")
		NewFolder.Name = Name
		NewFolder.Parent = Events
	end
end

return App