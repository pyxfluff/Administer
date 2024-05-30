--[[
Administer

------

darkpixlz 2022-2024

This code does most of the stuff client side.

]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local AdministerRemotes = ReplicatedStorage:WaitForChild("AdministerRemotes");
local RequestSettingsRemote = AdministerRemotes:WaitForChild("SettingsRemotes"):WaitForChild("RequestSettings");

local LogFrame = script.Parent.Main.Configuration.ErrorLog.ScrollingFrame
local __Version = 1.0
local VersionString = "1.0 Beta 1"
local Decimals = 2

local Settings = RequestSettingsRemote:InvokeServer()

local function GetSetting(Setting)
	local SettingModule = Settings

	for i, v in pairs(SettingModule) do
		if v["Name"] == Setting then
			return v["Value"]
		end
	end
	return "Not found"
end

local function Log(Message, ImageId)
	local New = LogFrame.Template:Clone()
	New.Parent = LogFrame
	New.Visible = true
	New.Text.Text = Message
	New.Timestamp.Text = os.date(`%I:%M:%S %p, %m/%d/%y ({tick()})`)
	New.ImageLabel.Image = ImageId
end

local function Print(str)
	print("[Administer]: "..str)
	Log(str, "")
end

local function Warn(str)
	warn("[Administer]: "..str)
	Log(str, "")
end

local function Error(str)
	Log(str, "")
	error("[Administer]: "..str)
end

local IsOpen, InPlaying, InitErrored
local MainFrame = script.Parent:WaitForChild("Main", 5)

local function ChangeTheme(Theme)
	Warn("Building Theme...")
	MainFrame.BackgroundColor3 = Theme.BackgroundColor
end
--ChangeTheme("Default")
local LastPage = "Home"

local function ShortNumber(Number)
	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (Decimals or 3)) / 10 ^ (Decimals or 3)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

--script.Parent.Main.Home.Welcome.Text = string.format(
--	"Good %s, <b>%s</b>. %s",
--	({
--		"evening", 
--		"morning", 
--		"afternoon"
--	})[math.floor((tonumber(os.date("%H")) + 24 - 4) % 24 / 6) + 1],
--	game.Players.LocalPlayer.DisplayName, 
--	GetSetting("HomepageGreeting") or "Welcome to Administer!"
--)


script.Parent.Main.Home.PlayerImage.Image = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
-- Mobile: rbxassetid://12500517462
-- Desktop: rbxassetid://10065089093

--// Navigation \\--
local function NewNotification(Body: string, Heading: string, Icon: string?, Duration: number?, AppName: string, Options: Table?, OpenTime: int?)
	-- This code is very old and has been fixed to my ability.
	-- I dislike the dummy notification thing, it's very hacky,
	-- but it works.
	
	Duration = Duration or GetSetting("NotificationCloseTimer")
	OpenTime = OpenTime or 1.25
	
	local Placeholder  = Instance.new("Frame")
	Placeholder.Parent = script.Parent.Notifications
	Placeholder.BackgroundTransparency = 1
	Placeholder.Size = UDim2.new(0.996,0,0.096,0)
	
	local Notification: Frame = script.Parent.Notifications.Template:Clone() -- typehinting for dev
	Notification.Position = UDim2.new(0,0,1.3,0)
	Notification.Visible = true
	Notification.Parent = script.Parent.NotificationsTweening
	
	Notification.Body.Text = Body
	Notification.Header.Title.Text = `<b>{AppName or "Administer"}</b> • {Heading}`
	Notification.Header.ImageL.Image = Icon          
	
	if Icon == "" then
		Notification.Header.Title.Size = UDim2.new(1,0,.965,0)
		Notification.Header.Title.Position = UDim2.new(1.884,0,.095,0)
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
			Notification,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(-.018,0,.858,0)
			}
		)
	}
	
	for i, v: Instance in ipairs(Notification:GetDescendants()) do
		if v:IsA("TextLabel") then
			v.TextTransparency = 1
			table.insert(Tweens, TweenService:Create(
				v,
				TweenInfo.new(OpenTime * .5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					TextTransparency = 0
				})
			)
		elseif v:IsA("ImageLabel") then
			v.ImageTransparency = 1
			table.insert(Tweens, TweenService:Create(
				v,
				TweenInfo.new(OpenTime * .5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					ImageTransparency = 0
				})
			)
		elseif v.Name == "Blur" then
			v.BackgroundTransparency = 1
			table.insert(Tweens, TweenService:Create(
				v,
				TweenInfo.new(OpenTime * .5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					BackgroundTransparency = .6
				})
			)
		end
	end
	
	for i, v in pairs(Tweens) do
		v:Play()
	end
	
	Tweens[1].Completed:Wait()
	Placeholder:Destroy()
	
	Notification.Parent = script.Parent.Notifications
	
	task.wait(Duration)
	--// TODO
	
	local Placeholder2  = Instance.new("Frame")
	Placeholder2.Parent = script.Parent.Notifications
	Placeholder2.BackgroundTransparency = 1
	Placeholder2.Size = UDim2.new(0.996,0,0.096,0)
	
	Notification.Parent = script.Parent.NotificationsTweening
	local NotifTween2 = TweenService:Create(
		Notification,
		TweenInfo.new(
			0.1,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In,
			0,
			false,
			0
		),
		{
			Position = UDim2.new(1.8,0,0.904,0)
		}
	)
	
	NotifTween2:Play()
	NotifTween2.Completed:Wait()
	Notification:Destroy()
	Placeholder2:Destroy()
end

local Mobile = false

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	Print("Making adjustments to UI (Mobile)")
	local Header = MainFrame.Header
	Header.Mark.Logo.Position = UDim2.new(-0.274, 0,0.088, 0)
	for i, v in ipairs(MainFrame.Dock.buttons:GetChildren()) do
		local asset = v:FindFirstChild("Desc")
		if asset then
			asset.Visible = false
		else
			Warn("Could not find Desc in button")
		end
	end
	MainFrame.Dock.buttons.UIGridLayout.CellPadding = UDim2.new(.02,0,.5,0)
	MainFrame.Dock.buttons.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Header.Size = UDim2.new(1,0,.142,0)
	local Dock = MainFrame.Dock
	Dock.Position = UDim2.new(0.016, 0,0.134, 0)
	Dock.Size = UDim2.new(0.967, 0,0.093, 0)
	Mobile = true
	NewNotification("You've successfully opted in to the Administer Mobile Beta. Please note that at the moment mobile support is buggy, expect changes soon.", "Mobile Beta", "rbxassetid://12500517462", 5)
else
	script.Parent.MobileBackground:Destroy()
	script.Parent:WaitForChild("MobileOpen"):Destroy()
end

--script.Parent.Main.Header.MobileToggle.Visible = Mobile

local UserInputService = game:GetService("UserInputService")
local Neon = require(script.Parent.ButtonAnims:WaitForChild("neon"))
local IsOpen = true

local OriginalProperties = {}

local function StoreOriginalProperties(UIElement)
	local properties = {}
	if UIElement:IsA("Frame") then
		properties.BackgroundTransparency = UIElement.BackgroundTransparency
	elseif UIElement:IsA("CanvasGroup") then
		properties.BackgroundTransparency = UIElement.BackgroundTransparency
	elseif UIElement:IsA("TextBox") or UIElement:IsA("TextButton") or UIElement:IsA("TextLabel") then
		properties.BackgroundTransparency = UIElement.BackgroundTransparency
		properties.TextTransparency = UIElement.TextTransparency
	elseif UIElement:IsA("ImageLabel") or UIElement:IsA("ImageButton") then
		properties.BackgroundTransparency = UIElement.BackgroundTransparency
		properties.ImageTransparency = UIElement.ImageTransparency
	else
		return
	end
	OriginalProperties[UIElement] = properties
end

local function TweenAllToOriginalProperties()
	for UIElement, v in pairs(OriginalProperties) do	
		TweenService:Create(UIElement, TweenInfo.new(tonumber(GetSetting("AnimationSpeed") / 10 * 6), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v):Play()
	end
end

local function Open()
	IsPlaying = true
	MainFrame.Visible = true
	script.Parent:SetAttribute("IsVisible", true) --// TODO remove this
	if GetSetting("UseAcrylic") then
		Neon:BindFrame(script.Parent.Main.Blur, {
			Transparency = 0.95,
			BrickColor = BrickColor.new("Institutional white")
		})
	end
	
	MainFrame.Visible = true
	TweenService:Create(MainFrame, TweenInfo.new(tonumber(GetSetting("AnimationSpeed")), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		--	Position = UDim2.new(0.078, 0, 0.145, 0),
		Size = UDim2.new(.843,0,.708,0),
		GroupTransparency = 0
		--BackgroundTransparency = 0.5
	}):Play()

	script.Sound:Play()
	--task.spawn(TweenAllToOriginalProperties)
	task.delay(1, function() IsPlaying = false end)
end

local function Close()
	IsPlaying = true
	script.Parent:SetAttribute("IsVisible", false)

	local succ, err = pcall(function()
		Neon:UnbindFrame(script.Parent.Main.Blur)
	end)
	
	local Duration = (tonumber(GetSetting("AnimationSpeed")) or 1) * .5

	if not succ then
		InitErrored = true
		task.spawn(function()
			NewNotification("Something went wrong during initialization, is Administer properly installed? Aborting startup...", "Could not initialize", "rbxassetid://12500517462", 10)
		end)	
	end


	if not Mobile then
		TweenService:Create(MainFrame, TweenInfo.new(Duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			--Position = UDim2.fromScale(main.Position.X.Scale, main.Position.Y.Scale + 0.05),
			Size = UDim2.new(1.4,0,1.5,0),
			GroupTransparency = 1
		}):Play()
	else
	--	TweenService:Create(script.Parent.MobileBackground, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	--		ImageTransparency = 1
	--	}):Play()

	--	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
	--		--Position = UDim2.fromScale(main.Position.X.Scale, main.Position.Y.Scale + 0.05),
	--		Size = UDim2.new(1.2,0,1.5,0),
	--		Transparency = 1
	--	}):Play()
	end
	task.spawn(function()
		task.wait(Duration)
		IsPlaying = false
		MainFrame.Visible = false
	end)
end

--// check we're installed right before filling memory

local Suc, Err = pcall(function()
	AdministerRemotes.Ping:FireServer()
end)

if not Suc then
	print(Err)
	Close()
	NewNotification("Administer is not installed correctly or the server code is not functional. Please reinstall.", "Startup failed", "", 999)
	script.Parent.Main.Visible = false
	return
end

for i, v in ipairs(script.Parent.Main:GetDescendants()) do
	StoreOriginalProperties(v)
end

Close()

if InitErrored then
	task.spawn(function()
		NewNotification("Startup aborted, please make sure Administer is correctly installed. [Error: acrylic_setting_not_found]", "Something went wrong", "rbxassetid://11601882008", 15)
		script.Parent:Destroy()
	end)
end

script.Parent.Main.Visible = false
IsPlaying = false

task.spawn(function()
	task.wait(2)
	NewNotification("Administer is now starting. Starting workers.", "Starting", "rbxassetid://14535622232", 10)
	task.wait(GetSetting("SettingsCheckTime"))
	while true do
		Settings = RequestSettingsRemote:InvokeServer()
		task.wait(GetSetting("SettingsCheckTime"))
	end
end)


local Down
local MenuDebounce = false
local UserInputService = game:GetService("UserInputService")

-- I eventually want to rescript this to be more efficient and cleaner

UserInputService.InputBegan:Connect(function(key, WasGameProcessed)
	if WasGameProcessed or IsPlaying then 
		return
	end
	Down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
	--if key.KeyCode == GetSetting("PanelKeybind") then
	if key.KeyCode == Enum.KeyCode.Z then
		if GetSetting("RequireShift") == true and Down then
			if MenuDebounce == false then
				Open()
				repeat task.wait(.1) until IsOpen
				--script.Parent.Main.Position = UDim2.new(.078,0,.145,0);
				MenuDebounce = true
			else
				Close()
				MenuDebounce = false
			end

		elseif Down == false and GetSetting("RequireShift") == false then
			if MenuDebounce == false then
				Open()
				repeat task.wait(.1) until IsOpen
				--script.Parent.Main.Position =  UDim2.new(.078,0,.145,0);
				MenuDebounce = true
			else
				Close()
				MenuDebounce = false
			end
		else
		end
	else return end
end)

-- Mobile opening
if Mobile then
	script.Parent.MobileOpen.Hit.TouchSwipe:Connect(function(SwipeDirection)
		if SwipeDirection == Enum.SwipeDirection.Left then
			Open()
			repeat task.wait() until IsOpen
			script.Parent.Main.Position =  UDim2.new(.078,0,.145,0)
			MenuDebounce = true
		end
	end)
end


script.Parent.Main.Header.Minimize.MouseButton1Click:Connect(function()
	Close()
	MenuDebounce = false
end)

local Success, Error = pcall(function()
	script.Parent.Main.Configuration.InfoPage.VersionDetails.Update.MouseButton1Click:Connect(function()
		local tl = script.Parent.Main.Configuration.InfoPage.VersionDetails.Update.Check
		tl.Text = "Checking..."
		
		AdministerRemotes.CheckForUpdates:FireServer()
		tl.Parent.Value.Changed:Connect(function()
			tl.Text = "Complete!"
		end)
		
		task.delay(function()
			tl.Text = "Check for updates"
		end)
	end)
end)

if not Success then
	print("Version checking ignored as this admin does not have access to the Configuration page!")
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

local function GetVersionLabel(PluginVersion) 
	return `<font color="rgb(139,139,139)">Your version </font> {PluginVersion == __Version and `<font color="rgb(56,218,111)">is supported! ({VersionString})</font>` or `<font color="rgb(255,72,72)">may not be supported ({VersionString})</font>`}`
end

local function OpenApps(TimeToComplete: number)
	local Apps = MainFrame.Apps
	local Clone = Apps.MainFrame:Clone()

	Apps.MainFrame.Visible = false

	Clone.Parent = Apps
	Clone.Visible = false
	Clone.Name = "Duplicate"

	for i, v in ipairs(Clone:GetChildren()) do
		if v:IsA("UIGridLayout") then continue end

		if v:IsA("Frame") then
			v.BackgroundTransparency = 0
		elseif v:IsA("TextLabel") then
			v.TextTransparency = 1
		elseif v:IsA("ImageLabel") then
			v.ImageTransparency = 1
		end
	end

	Clone.Size = UDim2.new(1.5,0,1.6,0)
	TweenService:Create(Apps, TweenInfo.new(TimeToComplete + (TimeToComplete * .4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {BackgroundTransparency = .1}):Play()

	local Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete, Enum.EasingStyle.Quart), {Size= UDim2.new(.965,0,.928,0)})
	for i, v: Frame in ipairs(Clone:GetChildren()) do
		if not v:IsA("Frame") then continue end

		TweenService:Create(v, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {BackgroundTransparency = .2}):Play()

		for i, v in ipairs(v:GetChildren()) do
			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
			elseif v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {ImageTransparency = 0}):Play()
			end
		end
	end

	Clone.Visible = true
	Tween:Play()
	Tween.Completed:Wait()

	--Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {Size = UDim2.new(.947,0,.894,0)})
	--Tween:Play()

	--Tween.Completed:Wait()

	--Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {Size= UDim2.new(.965,0,.928,0)})
	--Tween:Play()

	--Tween.Completed:Wait()

	Clone:Destroy()
	Apps.MainFrame.Visible = true
end

local function CloseApps(TimeToComplete: number)
	local Apps = MainFrame.Apps
	local Clone = Apps.MainFrame:Clone()
	Apps.MainFrame.Visible = false

	Apps.MainFrame.Visible = false

	Clone.Parent = Apps
	Clone.Visible = true
	Clone.Name = "Duplicate"

	TweenService:Create(Apps, TweenInfo.new(TimeToComplete + (TimeToComplete * .4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {BackgroundTransparency = 1}):Play()

	local Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete, Enum.EasingStyle.Quart), {Size = UDim2.new(1.5,0,1.6,0)})

	for i, v: Frame in ipairs(Clone:GetChildren()) do
		if not v:IsA("Frame") then continue end

		TweenService:Create(v, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()

		for i, v in ipairs(v:GetChildren()) do
			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
			elseif v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {ImageTransparency = 1}):Play()
			end
		end
	end
	
	Tween:Play()
	Tween.Completed:Wait()
	Clone:Destroy()
end


task.wait(.5)

for i, v in ipairs(MainFrame.Apps.MainFrame:GetChildren()) do
	if not v:IsA("Frame") then continue end
	
	local frame = string.sub(v.Name, 2,100)
	v.Click.MouseButton1Click:Connect(function()
		if script.Parent.Main:FindFirstChild(frame) then
			task.spawn(CloseApps, GetSetting("AnimationSpeed") / 7 * 5.5)
			
			MainFrame[tostring(LastPage)].Visible = false
			LastPage = frame
			MainFrame[frame].Visible = true
			
			MainFrame.Header.AppDrawer.CurrentApp.Image = v.Icon.Image
			MainFrame.Header.Mark.HeaderLabel.Text = `<b>Administer</b> • {frame}`
		else
			script.Parent.Main.Animation.Position = UDim2.new(0,0,0,0)
			script.Parent.Main.Animation:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)

			task.wait(.2)
			script.Parent.Main[tostring(LastPage)].Visible = false	
			LastPage = "Other"
			script.Parent.Main.Other.Visible = true
			script.Parent.Main.Animation:TweenSizeAndPosition(UDim2.new(0,0,1,0), UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			script.Parent.Main.Animation.Position = UDim2.new(0,0,0,0)
		end
	end)
end

if #MainFrame.Apps.MainFrame:GetChildren() >= 100 then
	warn("Warning: Administer has detected over 100 apps installed. Although there is no hardcoded limit, you may experience poor performance on anything above 100.")
end

MainFrame.Header.AppDrawer.MouseButton1Click:Connect(function()
	OpenApps(GetSetting("AnimationSpeed") / 7 * 5.5)
end)

game:GetService("LogService").MessageOut:Connect(function(Message, Type)
	if Type ~= Enum.MessageType.MessageInfo then
		local New = LogFrame.Template:Clone()
		New.Parent = LogFrame
		New.Visible = true
		New.Text.Text = Message
		New.Timestamp.Text = os.date(`%I:%M:%S %p, %m/%d/%y ({tick()})`)
	end

end)


-- AdministerRemotes.NewLog.OnClientEvent:Connect(function(Message, ImageId)
--	local New = LogFrame.Template:Clone()
--	New.Parent = LogFrame
--	New.Visible = true
--	New.Text.Text = Message
--	New.Timestamp.Text = os.date(`%I:%M:%S %p, %m/%d/%y ({tick()})`)
--	New.ImageLabel.Image = ImageId
--end)

local PluginConnections = {}

local function LoadPlugin(ServerURL, ID, Reason)
	warn("Downloading full info for that plugin...")

	local Success, Data = pcall(function()
		return ReplicatedStorage.AdministerRemotes.GetPluginInfo:InvokeServer(ServerURL, ID)
	end)

	if not Success then 
		warn(`Failed to fetch PluginID {ID} from {ServerURL} - is the server active and alive?`) 
		print(Data)
		return "The server died" 
	elseif Data["Error"] ~= nil then
		warn(Data["Error"])
		return "Something went wrong, check logs"
	elseif Data[1] == 404 then
		return "That plugin wasn't found, this is likely a plugin server misconfiguration."
	end
	
	local PluginInfoFrame = MainFrame.Configuration.Marketplace.Install

	PluginInfoFrame.Titlebar.Bar.Title.Text = Data["PluginTitle"]
	PluginInfoFrame.MetaCreated.Label.Text = `Created {FormatRelativeTime(Data["PluginCreatedUnix"])}`
	PluginInfoFrame.MetaUpdated.Label.Text = `Updated {FormatRelativeTime(Data["PluginUpdatedUnix"])}`
	PluginInfoFrame.MetaVersion.Label.Text = GetVersionLabel(tonumber(Data["AdministerMetadata"]["AdministerVersionLastValidated"]))
	PluginInfoFrame.MetaServer.Label.Text = `Shown because {Reason or `<b>You're subscribed to {string.split(ServerURL, "/")[3]}`}</b>`
	PluginInfoFrame.MetaInstalls.Label.Text = `<b>{ShortNumber(Data["PluginDownloadCount"])}</b> installs`
	PluginInfoFrame.PluginClass.Icon.Image = Data["PluginType"] == "Theme" and "http://www.roblox.com/asset/?id=14627761757" or "http://www.roblox.com/asset/?id=14114931854"
	PluginInfoFrame.UserInfo.Creator.Text = `<font size="17" color="rgb(255,255,255)" transparency="0">@{Data["PluginDeveloper"]}</font><font size="14" color="rgb(255,255,255)" transparency="0"> </font><font size="7" color="rgb(58,58,58)" transparency="0">{Data["AdministerMetadata"]["PluginDeveloperPluginCount"]} plugins on this server</font>`
	PluginInfoFrame.UserInfo.PFP.Image = game.Players:GetUserThumbnailAsync(game.Players:GetUserIdFromNameAsync(Data["PluginDeveloper"]), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)

	for i, v in ipairs(Data["PluginTags"]) do
		local Tag = PluginInfoFrame.Tags.Tag:Clone()
		Tag.TagText.Text = v
		Tag.Visible = true
		Tag.Parent = PluginInfoFrame.Tags
		Tag.BackgroundTransparency = 0
		Tag.TagText.TextTransparency = 0
	end

	PluginInfoFrame.HeaderLabel.Text = `Install {Data["PluginName"]}`
	PluginInfoFrame.Icon.Image = `http://www.roblox.com/asset/?id={Data["PluginIconID"]}`
	PluginInfoFrame.Description.Text = Data["PluginLongDescription"]
	PluginInfoFrame.Dislikes.Text = ShortNumber(Data["PluginDislikes"])
	PluginInfoFrame.Likes.Text = ShortNumber(Data["PluginLikes"])

	local Percent = tonumber(Data["PluginLikes"]) / (tonumber(Data["PluginDislikes"]) + tonumber(Data["PluginLikes"]))
	PluginInfoFrame.RatingBar.Positive.Size = UDim2.new(Percent, 0, 1, 0)
	PluginInfoFrame.RatingBar.Positive.Percentage.Text = math.round(Percent * 100) .. "%"
	PluginInfoFrame.Visible = true

	PluginInfoFrame.Install.MouseButton1Click:Connect(function()
		PluginInfoFrame.Install.HeaderLabel.Text = AdministerRemotes.InstallPlugin:InvokeServer(ServerURL, ID)[2]
	end)

	return "More"
end

local InProgress = false

local function GetPlugins()
	print("Refreshing plugin list...")
	
	if InProgress then 
		Warn("You're clicking too fast or your app servers are unresponsive!")
		return
	end
	
	InProgress = true

	for i, Connection: RBXScriptConnection in ipairs(PluginConnections) do
		Connection:Disconnect()
	end
	
	for i, v in ipairs(MainFrame.Configuration.Marketplace.Content:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end

	local PluginList = AdministerRemotes.GetPluginList:InvokeServer()

	for i, v in pairs(PluginList) do
		local Frame = MainFrame.Configuration.Marketplace.Content.Template:Clone()
		Frame.Parent = MainFrame.Configuration.Marketplace.Content

		Frame.PluginName.Text = v["PluginName"]
		Frame.ShortDesc.Text = v["PluginShortDescription"]
		Frame.InstallCount.Text = v["PluginDownloadCount"]
		Frame.Rating.Text = v["PluginRating"].."%"
		Frame.Name = i

		Frame.Install.MouseButton1Click:Connect(function()
			-- AdministerRemotes.InstallPlugin:InvokeServer(v["PluginID"])

			Frame["play-free-icon-font 1"].Image = "rbxassetid://11102397100"
--			local c = script.Spinner:Clone()
--			c.Parent = Frame["play-free-icon-font 1"]
--			c.Enabled = true
			Frame.InstallLabel.Text = "Loading..."
			Frame.InstallLabel.Text = LoadPlugin(v["PluginServer"], v["PluginID"])
		end)

		Frame.Visible = true
	end
	InProgress = false
end

-- Admins page

local function RefreshAdmins()
	for i, v in ipairs(MainFrame.Configuration.Admins.Ranks.Content:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end
	
	local List = AdministerRemotes.GetRanks:InvokeServer()
	if typeof(List) == "string" then
		warn(`Failed: {List}`)
		return "Something went wrong"
	else
		for i, v in ipairs(List) do
			local RanksFrame = MainFrame.Configuration.Admins.Ranks.Content
			
			local Template = RanksFrame.Template:Clone()
			
			Template.Name = v["RankName"]
			Template.RankName.Text = v["RankName"]
			Template.Info.Text = `Rank {v["RankID"]} • {#v["AllowedPages"]} pages {v["Protected"] and "• Protected" or ""} • {v["Reason"]}`
			
			if #v["AllowedPages"] >= 6 then
				for j = 1, 5 do
					local App = Template.Pages.Frame:Clone()
					
					App.Visible = true
					App.AppName.Text = v["AllowedPages"][j]["DisplayName"]
					App.ImageLabel.Text = v["AllowedPages"][j]["Icon"]
				end
				local App = Template.Pages.Frame:Clone()

				App.Visible = true
				App.AppName.Text = `{#v["AllowedPages"] - 5} others...`
			else
				for k, j in ipairs(v["AllowedPages"]) do
					local App = Template.Pages.Frame:Clone()

					App.Visible = true
					App.AppName.Text = v["AllowedPages"][k]["DisplayName"]
					App.ImageLabel.Image = v["AllowedPages"][k]["Icon"]
					
					App.Parent = Template.Pages
				end
			end
			
			Template.Parent = RanksFrame
			Template.Visible = true
		end
	end
end

MainFrame.Configuration.MenuBar.buttons.FMarketplace.TextButton.MouseButton1Click:Connect(GetPlugins)
MainFrame.Configuration.MenuBar.buttons.DAdmins.TextButton.MouseButton1Click:Connect(RefreshAdmins)

-- fetch donation passes

local MarketplaceService = game:GetService("MarketplaceService")

local _Content = AdministerRemotes.GetPasses:InvokeServer()

print(_Content)

for i, v in ipairs(game:GetService("HttpService"):JSONDecode(_Content)["data"]) do
	local Cloned = script.Parent.Main.Configuration.InfoPage.Donate.Buttons.Temp:Clone()
	
	--// thanks roblox :herart:
	Cloned.Parent = script.Parent.Main.Configuration.InfoPage.Donate.Buttons
	Cloned.Text = `{v["price"]}`
	Cloned.MouseButton1Click:Connect(function()
		MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, v["id"])
	end)
	Cloned.Visible = true
end