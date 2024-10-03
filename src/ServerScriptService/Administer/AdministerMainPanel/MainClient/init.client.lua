--// Administer
--// PyxFluff 2022-2024

--// This code does most of the stuff client side.
--// Please do not make modifications to this code. Modify functions via Apps.

--// Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local AssetService = game:GetService("AssetService")

--// Variables
local AdministerRemotes = ReplicatedStorage:WaitForChild("AdministerRemotes")
local RequestSettingsRemote = AdministerRemotes:WaitForChild("SettingsRemotes"):WaitForChild("RequestSettings")
local __Version = 1.0
local VersionString = "1.0"
local WidgetConfigIdealVersion = "1.0"
local Settings = RequestSettingsRemote:InvokeServer()
local MainFrame = script.Parent:WaitForChild("Main")
local Neon = require(script.Parent.ButtonAnims:WaitForChild("neon"))
local IsOpen = true
local LastPage = "Home"

local function GetSetting(Setting)
	local SettingModule = Settings

	if SettingModule == {false} then --// future proof
		error("[Administer]: Oops, your settings did not authenticate properly. This is probably a bug with the ranking system. Please provide a detailed error report to the Administer team.")
	end

	for i, v in SettingModule do
		local Success, Result = pcall(function() 
			if v["Name"] == Setting then
				return v["Value"] or "Corrupted Setting!"
			else
				return "CONT"
			end
		end) 

		if not Success then
			return "Corrupted setting (No \"Name\") ... " .. Result	
		elseif Result == "CONT" then
			continue
		else
			return Result
		end
	end

	return "Not found"
end

--// Logging setup, pcall in use because this person may not have access to the Configuration menu
local Print, Warn, Error
pcall(function()
	local LogFrame = script.Parent.Main.Configuration.ErrorLog.ScrollingFrame
	local function Log(Message, ImageId)
		local New = LogFrame.Template:Clone()

		New.Parent = LogFrame
		New.Visible = true
		New.Text.Text = Message
		New.Timestamp.Text = os.date(`%I:%M:%S %p, %m/%d/%y ({tick()})`)
		New.ImageLabel.Image = ImageId
	end

	game:GetService("LogService").MessageOut:Connect(function(Message, Type)
		if Type ~= Enum.MessageType.MessageInfo then
			local New = LogFrame.Template:Clone()
			New.Parent = LogFrame
			New.Visible = true
			New.Text.Text = Message
			New.Timestamp.Text = os.date(`%I:%M:%S %p, %m/%d/%y ({tick()})`)
		end
	end)

	Print = function(str)
		if GetSetting("Verbose") then
			print("[Administer]: "..str)
			Log(str, "")
		end
	end

	Warn = function(str)
		warn("[Administer]: "..str)
		Log(str, "")
	end

	Error = function(str)
		Log(str, "")
		error("[Administer]: "..str)
	end

end)

local IsPlaying, InitErrored
local function Open()
	IsPlaying = true
	MainFrame.Visible = true
	-- script.Parent:SetAttribute("IsVisible", true) // testing removal of this, if it proves problematic this will return
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

local function NewNotification(AppTitle: string, Icon: string, Body: string, Heading: string, Duration: number?, Options: Table?, OpenTime: int?)
	local Panel = script.Parent

	Duration = Duration
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
	Notification.Header.Title.Text = `<b>{AppTitle}</b> · {Heading}`
	--Notification.Header.Administer.Image = Icon
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

	for i, v in Tweens do
		v:Play()
	end

	Tweens[1].Completed:Wait()
	Placeholder:Destroy()
	Notification.Parent.Parent = Panel.Notifications

	local function Close(instant: boolean)
		if not instant then instant = false end
		local NotifTween2 = TweenService:Create(
			Notification,
			TweenInfo.new(
				(instant and 0 or OpenTime * .7),
				Enum.EasingStyle.Quad
			),
			{
				Position = UDim2.new(1,0,0,0),
				GroupTransparency = 1
			}
		)

		NotifTween2:Play()
		NotifTween2.Completed:Wait()
		Notification.Parent:Destroy()
	end

	Notification.Buttons.DismissButton.MouseButton1Click:Connect(Close)
	task.delay(Duration, Close)
end



local Mobile = false

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	Print("Making adjustments to UI (Mobile)")
	Mobile = true
	task.spawn(function()
		NewNotification("Administer", "rbxassetid://12500517462", "You've successfully opted in to the Administer Mobile Beta.", "Mobile Beta", 25)
	end)
else
	script.Parent.MobileBackground:Destroy()
	script.Parent:WaitForChild("MobileOpen"):Destroy()
end

local function Close(instant: boolean)
	if not instant then instant = false end
	IsPlaying = true
	script.Parent:SetAttribute("IsVisible", false)

	local succ, err = pcall(function()
		Neon:UnbindFrame(script.Parent.Main.Blur)
	end)
	local Duration
	if instant then Duration = 0 else Duration = (tonumber(GetSetting("AnimationSpeed")) or 1) * .5 end

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
		TweenService:Create(script.Parent.MobileBackground, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(MainFrame, TweenInfo.new(Duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			--Position = UDim2.fromScale(main.Position.X.Scale, main.Position.Y.Scale + 0.05),
			Size = UDim2.new(1.4,0,1.5,0),
			GroupTransparency = 1
		}):Play()
	end
	task.spawn(function()
		task.wait(Duration)
		IsPlaying = false
		MainFrame.Visible = false
	end)
end

--// Verify installation
local Suc, Err = pcall(function()
	AdministerRemotes.Ping:InvokeServer()
end)

if not Suc then
	print(Err)
	Close(false)
	NewNotification("Administer", "rbxassetid://18512489355", "Administer server ping failed, it seems your client may be incorrectly installed or the server si not executing properly. Please reinstall from source.", "Startup failed", 99999, {})
	script.Parent.Main.Visible = false
	return
end

Close(true)

local function ShortNumber(Number)
	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (GetSetting("ShortNumberDecimals") or 2)) / 10 ^ (GetSetting("ShortNumberDecimals") or 2)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

MainFrame.Home.Welcome.Text = `Good {({"morning", "afternoon", "evening"})[(os.date("*t").hour < 12 and 1 or os.date("*t").hour < 18 and 2 or 3)]}, <b>{game.Players.LocalPlayer.DisplayName}</b>. {GetSetting("HomepageGreeting")}`
MainFrame.Home.PlayerImage.Image = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)

task.spawn(function()
	local PromColor = game.ReplicatedStorage.AdministerRemotes.GetProminentColorFromUserID:InvokeServer(133017837)

	MainFrame.Home.Gradient2.ImageLabel.ImageColor3 = Color3.fromRGB(PromColor[1], PromColor[2], PromColor[3])
end)

local function GetAvailableWidgets()
	local Widgets = {Small = {}, Large = {}}

	for i, v in MainFrame:GetChildren() do
		local WidgFolder = v:FindFirstChild(".widgets")
		if not WidgFolder then continue end

		local Done, Result = pcall(function()
			local Config = require(WidgFolder:FindFirstChild(".widgetconfig"))

			if not Config then Error(`{v.Name}: Invalid Administer Widget folder (missing .widgetconfig, please read the docs!)`) end

			local SplitGenerator = string.split(Config["_generator"], "-")
			if SplitGenerator[1] ~= "AdministerWidgetConfig" then Error(`{v.Name}: Not a valid Administer widget configuration file (bad .widgetconfig, please read the docs!)`) end
			if SplitGenerator[2] ~= WidgetConfigIdealVersion then Warn(`{v.Name}: Out of date Widget Config version (current {SplitGenerator[1]} latest: {WidgetConfigIdealVersion}!`) end

			for _, Widget in Config["Widgets"] do
				if Widget["Type"] == "SMALL_LABEL" then
					table.insert(Widgets["Small"], Widget)
				elseif Widget["Type"] == "LARGE_BOX" then
					table.insert(Widgets["Large"], Widget)
				else
					Error(`{v.Name}: Bad widget type (not in predefined list)`)
				end
				Widget["Identifier"] = `{v.Name}\\{Widget["Name"]}`
				Widget["AppName"] = v.Name
			end
		end)
	end

	return Widgets
end

--script.Parent.Main.Header.MobileToggle.Visible = Mobile

if InitErrored then
	task.spawn(function()
		NewNotification("Startup aborted, please make sure Administer is correctly installed. (failed dependency: neon)", "Something went wrong", "rbxassetid://11601882008", 15)
		return
	end)
end

task.spawn(function()
	while task.wait(GetSetting("SettingsCheckTime")) do
		Settings = RequestSettingsRemote:InvokeServer()
	end
end)


local MenuDebounce = false
UserInputService.InputBegan:Connect(function(key, WasGameProcessed)
	if WasGameProcessed or IsPlaying then 
		return
	end
	local Down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
	if key.KeyCode == Enum.KeyCode[GetSetting("PanelKeybind")] then
		if GetSetting("RequireShift") == true and Down then
			if MenuDebounce == false then
				Open()
				--repeat task.wait(.1) until IsOpen
				--script.Parent.Main.Position = UDim2.new(.078,0,.145,0);
				MenuDebounce = true
			else
				Close(false)
				MenuDebounce = false
			end

		elseif Down == false and GetSetting("RequireShift") == false then
			if MenuDebounce == false then
				Open()
				repeat task.wait(.1) until IsOpen
				--script.Parent.Main.Position =  UDim2.new(.078,0,.145,0);
				MenuDebounce = true
			else
				Close(false)
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
			MenuDebounce = true
		end
	end)
end


script.Parent.Main.Header.Minimize.MouseButton1Click:Connect(function()
	Close(false)
	MenuDebounce = false
end)

local Success, Error = pcall(function()
	script.Parent.Main.Configuration.InfoPage.VersionDetails.Update.MouseButton1Click:Connect(function()
		local tl = script.Parent.Main.Configuration.InfoPage.VersionDetails.Update.Label
		tl.Text = "CHECKING"

		--// fake slowdown here bc it was a little TOO fast
		task.wait(1)
		AdministerRemotes.CheckForUpdates:InvokeServer()
		tl.Text = "COMPLETE"

		task.delay(3, function()
			tl.Text = "CHECK FOR UPDATES"
		end)
	end)
end)

if not Success then
	print("Version checking ignored as this admin does not have access to the Configuration page!")
end

local function FormatRelativeTime(Unix)
	local TimeDifference = os.time() - (Unix ~= nil and Unix or 0)

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

local function GetVersionLabel(AppVersion) 
	return `<font color="rgb(139,139,139)">Your version </font>{AppVersion == __Version and `<font color="rgb(56,218,111)">is supported! ({VersionString})</font>` or `<font color="rgb(255,72,72)">may not be supported ({VersionString})</font>`}`
end

local function OpenApps(TimeToComplete: number)
	local Apps = MainFrame.Apps
	local Clone = Apps.MainFrame:Clone()

	Apps.MainFrame.Visible = false

	Clone.Parent = Apps
	Clone.Visible = false
	Clone.Name = "Duplicate"

	for i, v in Clone:GetChildren() do
		if v:IsA("UIGridLayout") then continue end

		if v:IsA("CanvasGroup") then
			v.GroupTransparency = 1
			v.BackgroundTransparency = 1
		elseif v:IsA("TextLabel") then
			v.TextTransparency = 1
		elseif v:IsA("ImageLabel") then
			v.ImageTransparency = 1
		end
	end

	Clone.Size = UDim2.new(2.2,0,2,0)
	TweenService:Create(Apps, TweenInfo.new(TimeToComplete + (TimeToComplete * .4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {BackgroundTransparency = .1}):Play()
	TweenService:Create(Apps.Background, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {ImageTransparency = .4}):Play()

	local Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete + 0, Enum.EasingStyle.Quart), {Size = UDim2.new(.965,0,.928,0)}) --// silence error
	for i, v: CanvasGroup in Clone:GetChildren() do
		if not v:IsA("CanvasGroup") then continue end

		TweenService:Create(v, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {GroupTransparency = 0, BackgroundTransparency = .2}):Play()

		for i, v in v:GetChildren() do
			if v:IsA("TextLabel") then --// remove this system soon? its canvasgroup i dont see why we cant just tween GroupTransparency
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
			elseif v.Name == "IconBG" then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {ImageTransparency = .5}):Play()
			elseif v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(TimeToComplete * .4, Enum.EasingStyle.Quart), {ImageTransparency = 0}):Play()
			end
		end
	end

	Clone.Visible = true
	Tween:Play()
	Tween.Completed:Wait()

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
	TweenService:Create(Apps.Background, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {ImageTransparency = 1}):Play()

	local Tween = TweenService:Create(Clone, TweenInfo.new(TimeToComplete + 0, Enum.EasingStyle.Quart), {Size = UDim2.new(1.5,0,1.6,0)})

	for i, v: CanvasGroup in Clone:GetChildren() do
		if not v:IsA("CanvasGroup") then continue end

		TweenService:Create(v, TweenInfo.new(TimeToComplete + .2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, GroupTransparency = 1}):Play()

		for i, v in v:GetChildren() do
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

local IsEIEnabled = GetSetting("EnableEditableImages")
--local EnableWaiting = GetSetting("EditableImageRenderingDelay")
local EnableWaiting = false

if IsEIEnabled == nil then --// (false) or true was always true due to logic so it would ignore the setting
	IsEIEnabled = true
end

local function CreateReflection(Image)
	--// Sadly this is mostly just wasted effort for now bc editableimages arent on the real client just yet..

	local AssetService = game:GetService("AssetService")
	local EditableImage = AssetService:CreateEditableImageAsync(Image)

	--// resize to be 1/10th as big (maybe larger eventually? tying to reduce lag rn)
	local Resized = Vector2.new(math.floor(EditableImage.Size.X / 10), math.floor(EditableImage.Size.Y / 10))
	EditableImage:Resize(Resized)

	local px = EditableImage:ReadPixels(Vector2.zero, Resized)
	local npx = {}

	Print(`Trying to render an EditableImage ({(#px/4-1)}px)`)

	for Chunk = 0, (#px/4 - 1) do
		local Index = Resized.Y*4 - (Chunk % Resized.Y)*4 + math.floor(Chunk/Resized.Y)*Resized.Y*4 - 3
		table.move(px, Chunk*4+1, Chunk*4+4, Index, npx)

		if EnableWaiting then task.wait() end
	end

	EditableImage:WritePixels(Vector2.zero, Resized, npx)
	return EditableImage
end

for i, v in MainFrame.Apps.MainFrame:GetChildren() do
	if not v:IsA("CanvasGroup") then continue end

	v.Click.MouseButton1Click:Connect(function()
		task.spawn(CloseApps, GetSetting("AnimationSpeed") / 7 * 5.5)
		local LinkID, PageName = v:GetAttribute("LinkID"), nil
		for i, Frame in MainFrame:GetChildren() do
			if Frame:GetAttribute("LinkID") == LinkID then
				PageName = Frame.Name
				break
			end
		end

		if LinkID == nil then
			script.Parent.Main[LastPage].Visible = false	
			LastPage = "NotFound"
			script.Parent.Main.NotFound.Visible = true
			return
		end

		MainFrame[LastPage].Visible = false
		MainFrame[PageName].Visible = true

		LastPage = PageName
		MainFrame.Header.Mark.AppLogo.Image = v.Icon.Image
		MainFrame.Header.Mark.HeaderLabel.Text = `<b>Administer</b> · {v.Title.Text}`
	end)

	if not IsEIEnabled then 
		continue
	end

	IsEIEnabled, _ = pcall(function()
		CreateReflection(v.Icon.Image).Parent = v.Reflection
		v.Reflection.Visible = true

		require(script.QuickBlur):Blur(game:GetService("AssetService"):CreateEditableImageAsync(v:GetAttribute("BackgroundOverride") ~= nil and v:GetAttribute("BackgroundOverride") or v.Icon.Image), 10, 6).Parent = v.IconBG
		v.IconBG.Visible = true
	end)
end

if #MainFrame.Apps.MainFrame:GetChildren() >= 250 then
	warn("Warning: Administer has detected over 250 apps installed. Although there is no hardcoded limit, you may experience poor performance on anything above this.")
end

MainFrame.Header.AppDrawer.MouseButton1Click:Connect(function()
	OpenApps(GetSetting("AnimationSpeed") * .8)
end)

local AppConnections = {}
local function LoadApp(ServerURL, ID, Reason)
	warn("Downloading full info for that app...")

	local Success, Data = pcall(function()
		return ReplicatedStorage.AdministerRemotes.GetAppInfo:InvokeServer(ServerURL, ID)
	end)

	if not Success then 
		warn(`Failed to fetch app {ID} from {ServerURL} - is the server active and alive?`) 
		print(Data)
		return "The server didn't return an OK status code." 
	elseif Data["Error"] ~= nil then
		warn(`App server lookup returned external error: {Data["Error"]}`)
		return "Something went wrong, check logs."
	elseif Data[1] == 404 then
		return "This app is missing."
	end

	local AppInfoFrame = MainFrame.Configuration.Marketplace.Install

	AppInfoFrame.Titlebar.Bar.Title.Text = Data["AppTitle"]
	AppInfoFrame.MetaCreated.Label.Text = `Created {FormatRelativeTime(Data["AppCreatedUnix"])}`
	AppInfoFrame.MetaUpdated.Label.Text = `Updated {FormatRelativeTime(Data["AppUpdatedUnix"])}`
	AppInfoFrame.MetaVersion.Label.Text = GetVersionLabel(tonumber(Data["AdministerMetadata"]["AdministerVersionLastValidated"]))
	AppInfoFrame.MetaServer.Label.Text = `Shown because {Reason or `<b>You're subscribed to {string.split(ServerURL, "/")[3]}`}</b>`
	AppInfoFrame.MetaInstalls.Label.Text = `<b>{ShortNumber(Data["AppDownloadCount"])}</b> installs`
	AppInfoFrame.AppClass.Icon.Image = Data["AppType"] == "Theme" and "http://www.roblox.com/asset/?id=14627761757" or "http://www.roblox.com/asset/?id=14114931854"
	AppInfoFrame.UserInfo.Creator.Text = `<font size="17" color="rgb(255,255,255)" transparency="0">@{Data["AppDeveloper"]}</font><font size="14" color="rgb(255,255,255)" transparency="0"> </font><font size="7" color="rgb(58,58,58)" transparency="0">{Data["AdministerMetadata"]["AppDeveloperAppCount"]} Apps on this server</font>`
	AppInfoFrame.UserInfo.PFP.Image = game.Players:GetUserThumbnailAsync(game.Players:GetUserIdFromNameAsync(Data["AppDeveloper"]), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
	AppInfoFrame.Install.HeaderLabel.Text = "Install"

	AppInfoFrame.Parent.Searchbar.Visible = false
	AppInfoFrame.Parent.Header.Visible = false
	AppInfoFrame.Parent.Content.Visible = false

	for i, v in Data["AppTags"] do
		local Tag = AppInfoFrame.Tags.Tag:Clone()
		Tag.TagText.Text = v
		Tag.Visible = true
		Tag.Parent = AppInfoFrame.Tags
		Tag.TagText.TextTransparency = 0
	end

	AppInfoFrame.HeaderLabel.Text = `Install {Data["AppName"]}`
	AppInfoFrame.Icon.Image = `https://www.roblox.com/asset/?id={Data["AppIconID"]}`
	AppInfoFrame.Description.Text = Data["AppLongDescription"]
	AppInfoFrame.Dislikes.Text = ShortNumber(Data["AppDislikes"])
	AppInfoFrame.Likes.Text = ShortNumber(Data["AppLikes"])

	local Percent = tonumber(Data["AppLikes"]) / (tonumber(Data["AppDislikes"]) + tonumber(Data["AppLikes"]))
	AppInfoFrame.RatingBar.Positive.Size = UDim2.new(Percent, 0, 1, 0)
	AppInfoFrame.RatingBar.Positive.Percentage.Text = math.round(Percent * 100) .. "%"
	AppInfoFrame.Visible = true

	AppInfoFrame.Install.MouseButton1Click:Connect(function()
		AppInfoFrame.Install.HeaderLabel.Text = "Processing..."
		AppInfoFrame.Install.ImageLabel.Image = "rbxassetid://84027648824846"

		AppInfoFrame.Install.HeaderLabel.Text = AdministerRemotes.InstallApp:InvokeServer(ServerURL, ID)[2]
		AppInfoFrame.Install.ImageLabel.Image = "rbxassetid://14651353224"
	end)

	AppInfoFrame.Close.MouseButton1Click:Connect(function()
		AppInfoFrame.Parent.Searchbar.Visible = true
		AppInfoFrame.Parent.Header.Visible = true
		AppInfoFrame.Parent.Content.Visible = true
		AppInfoFrame.Visible = false
	end)

	return "More"
end

local InProgress = false

local function GetApps()
	Print("Refreshing app list...")

	if InProgress then 
		Warn("You're clicking too fast or your app servers are unresponsive! Please slow down.")
		return
	end

	InProgress = true

	for i, Connection: RBXScriptConnection in AppConnections do
		Connection:Disconnect()
	end

	for i, v in MainFrame.Configuration.Marketplace.Content:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end

	local AppList = AdministerRemotes.GetAppList:InvokeServer()

	for k, v in AppList do
		if v["processed_in"] ~= nil then continue end

		local Frame = MainFrame.Configuration.Marketplace.Content.Template:Clone()
		Frame.Parent = MainFrame.Configuration.Marketplace.Content

		Frame.AppName.Text = v["AppName"]
		Frame.ShortDesc.Text = v["AppShortDescription"]
		Frame.InstallCount.Text = v["AppDownloadCount"]
		Frame.Rating.Text = string.sub(string.gsub(v["AppRating"], "0.", ""), 1, 2).."%"
		Frame.Name = k

		Frame.Install.MouseButton1Click:Connect(function()
			-- AdministerRemotes.InstallApp:InvokeServer(v["AppID"])

			Frame.InstallIcon.Image = "rbxassetid://84027648824846"
			Frame.InstallLabel.Text = "Loading..."
			Frame.InstallLabel.Text = LoadApp(v["AppServer"], v["AppID"])

			Frame.InstallIcon.Image = "rbxassetid://16467780710"
		end)

		Frame.Visible = true
	end
	InProgress = false
end

local RanksFrame = MainFrame.Configuration.Admins.Ranks.Content
local AdminConnections = {}

-- Admins page
local function RefreshAdmins()
	for i, v in MainFrame.Configuration.Admins.Ranks.Content:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end

	for i, v in MainFrame.Configuration.Admins.Admins.Content:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end

	for _, Conn in AdminConnections do
		Conn:Disconnect()
	end

	AdminConnections = {}

	local Shimmer1 = require(script.Shime).new(RanksFrame.Parent)
	local Shimmer2 = require(script.Shime).new(RanksFrame.Parent.Parent.Admins)

	Shimmer1:Play()
	Shimmer2:Play()
	
	--// Do this while the server is working on this
	task.spawn(function()
		local List = AdministerRemotes.GetRanks:InvokeServer("LegacyAdmins")
		
		print(List)
		
		for i, User in List do
			if User["MemberType"] == "User" then
				local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

				local Suc, Err = pcall(function()
					AdminPageTemplate.PFP.Image = tostring(game.Players:GetUserThumbnailAsync(tonumber(User["ID"]), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180))
					AdminPageTemplate.Info.Text = `AdminID Override`

					AdminPageTemplate.Metadata.Text = `This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `@{game.Players:GetNameFromUserIdAsync(User["ID"])}`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					AdminPageTemplate.Name = User["ID"]
				end)

				if not Suc then
					print(Err)
					AdminPageTemplate.PFP.Image = ""
					AdminPageTemplate.Metadata.Text = `AdminID Override`

					AdminPageTemplate.Info.Text = `This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `(user not found) all ranks`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
				end
			else
				local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

				local Success, GroupInfo = pcall(function()
					return game:GetService("GroupService"):GetGroupInfoAsync(User["ID"])
				end)

				local Suc, Err = pcall(function()
					AdminPageTemplate.PFP.Image =  GroupInfo["EmblemUrl"]
					AdminPageTemplate.Metadata.Text = `AdminID Override`

					AdminPageTemplate.Info.Text = `This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `{GroupInfo["Name"]} (all ranks)`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					AdminPageTemplate.Name = User["ID"]
				end)

				if not Suc then
					print(Err)
					AdminPageTemplate.PFP.Image = ""
					AdminPageTemplate.Info.Text = `AdminID Override`

					AdminPageTemplate.Metadata.Text = `This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `(group not found) all ranks`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
				end
			end
		end
	end)

	local List = AdministerRemotes.GetRanks:InvokeServer()

	if typeof(List) == "string" then
		warn(`Failed: {List}`)
		return "Something went wrong"
	else
		for i, v in List do
			local Template = RanksFrame.Template:Clone()

			Template.Name = v["RankName"]
			Template.RankName.Text = v["RankName"]
			Template.Info.Text = `Rank {v["RankID"]} • {v["PagesCode"] == "/" and #v["AllowedPages"].." pages" or "Full access"} • {#v["Members"]} member{#v["Members"] == 1 and "" or "s"} {v["Protected"] and "• Protected" or ""} • {v["Reason"]}`

			if #v["AllowedPages"] == 6 then --// im so confused
				for k, _ in v["AllowedPages"] do
					local App = Template.Pages.Frame:Clone()

					App.Visible = true
					App.AppName.Text = v["AllowedPages"][k]["DisplayName"]
					App.ImageLabel.Image = v["AllowedPages"][k]["Icon"]
					App.Parent = Template.Pages
				end
			elseif #v["AllowedPages"] > 6 then
				for j = 1, 5 do
					local App = Template.Pages.Frame:Clone()

					App.Visible = true
					App.AppName.Text = v["AllowedPages"][j]["DisplayName"]
					App.ImageLabel.Image = v["AllowedPages"][j]["Icon"]
					App.Parent = Template.Pages
				end

				local App = Template.Pages.Frame:Clone()
				App.Visible = true
				App.AppName.Text = `{#v["AllowedPages"] - 5} others...`
				App.Parent = Template.Pages
			else
				for k, _ in v["AllowedPages"] do
					local App = Template.Pages.Frame:Clone()

					App.Visible = true
					App.AppName.Text = v["AllowedPages"][k]["DisplayName"]
					App.ImageLabel.Image = v["AllowedPages"][k]["Icon"]
					App.Parent = Template.Pages
				end
			end

			Template.Parent = RanksFrame
			Template.Visible = true

			for _, User in v["Members"] do 
				if not tonumber(User["ID"]) then
					warn(`Bad admin ID? ({User["ID"]} was not of type number)`)
					continue
				end

				if User["MemberType"] == "User" then
					local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

					local Suc, Err = pcall(function()
						AdminPageTemplate.PFP.Image = tostring(game.Players:GetUserThumbnailAsync(tonumber(User["ID"]), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180))
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						--// "Created by" replacement to prevent any name mistakes ("Created by AddedUsername" not "Created by CreatedUsermame")
						AdminPageTemplate.Metadata.Text = `{string.gsub(v["Reason"], "Created by", "Added by")} <b>{FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `@{game.Players:GetNameFromUserIdAsync(User["ID"])}`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end)

					if not Suc then
						print(Err)
						AdminPageTemplate.PFP.Image = ""
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						AdminPageTemplate.Metadata.Text = `{v["Reason"]} <b>{FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `Deleted ({User["ID"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					end
				else
					local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

					local Success, GroupInfo = pcall(function()
						return game:GetService("GroupService"):GetGroupInfoAsync(User["ID"])
					end)

					local Suc, Err = pcall(function()
						AdminPageTemplate.PFP.Image =  GroupInfo["EmblemUrl"]
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						--// "Created by" replacement to prevent any name mistakes ("Created by AddedUsername" not "Created by CreatedUsermame")
						AdminPageTemplate.Metadata.Text = `{string.gsub(v["Reason"], "Created by", "Added by")} <b>{FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `{GroupInfo["Name"]} ({(User["GroupRank"] or 0) == 0 and "all ranks" or User["GroupRank"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end)

					if not Suc then
						print(Err)
						AdminPageTemplate.PFP.Image = ""
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						AdminPageTemplate.Metadata.Text = `{v["Reason"]} <b>{FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `Deleted ({User["ID"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					end
				end
			end

			Template.Configure.MouseButton1Click:Connect(function()
				print(v)	
				local ConfigFrame = RanksFrame.Parent.Parent.EditRank
				local FinishedEdits = {}
				local Connections = {}

				ConfigFrame.Visible = true

				ConfigFrame.Header.TLabel.Text = `Edit "{v["RankName"]}"`
				--ConfigFrame.RankID.Text = `Rank {i} · Created by {game.Players:GetNameFromUserIdAsync(v["CreatorID"])}`
				ConfigFrame.RankID.Text = `Rank {i} · {v["Reason"]}`
				ConfigFrame.RankIDContainer.RankID.Text = i
				ConfigFrame.PlayerContainer.CreatorImage.Image = game.Players:GetUserThumbnailAsync(v["CreatorID"], Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)

			end)
		end
	end

	Shimmer1:Pause()
	Shimmer2:Pause()
	Shimmer1:GetFrame():Destroy()
	Shimmer2:GetFrame():Destroy()
end

MainFrame.Configuration.MenuBar.buttons.FMarketplace.TextButton.MouseButton1Click:Connect(GetApps)
MainFrame.Configuration.MenuBar.buttons.DAdmins.TextButton.MouseButton1Click:Connect(RefreshAdmins)

-- fetch donation passes
xpcall(function()
	local _Content = AdministerRemotes.GetPasses:InvokeServer()

	for i, v in _Content do
		local Cloned = script.Parent.Main.Configuration.InfoPage.Donate.Buttons.Temp:Clone()

		--// thanks roblox :heart:
		Cloned.Parent = script.Parent.Main.Configuration.InfoPage.Donate.Buttons
		Cloned.Label.Text = `{v["price"]}`
		Cloned.MouseButton1Click:Connect(function()
			MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, v["id"])
		end)
		Cloned.Visible = true
	end
end, function()
	print("Failed to fetch donation passes, assuming this is a permissions issue!")
end)

--// homescreen

local WidgetData = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_HomeWidgets"))
local Widgets = GetAvailableWidgets()["Large"]
local ActiveWidgets = {}

for i, UI in MainFrame.Home:GetChildren() do
	if not table.find({"Widget1", "Widget2"}, UI.Name) then continue end

	for i, Widget in Widgets do
		if Widget["Identifier"] == WidgetData[UI.Name] then
			UI.Banner.Text = Widget["Name"]
			UI.BannerIcon.Image = Widget["Icon"]
			Widget["BaseUIFrame"].Parent = UI.Content
			Widget["BaseUIFrame"].Visible = true
			Widget["OnRender"](game.Players.LocalPlayer, UI.Content)

			UI:SetAttribute("AppName", string.split(Widget["Identifier"], "\\")[1])
			UI:SetAttribute("InitialWidgetName", string.split(Widget["Identifier"], "\\")[2])

			table.insert(ActiveWidgets, Widget)
		end
	end
end

--task.spawn(function() --// New thread here because I don't know
--	while task.wait(.5) do
--		for i, Widget in ActiveWidgets do
--			if Widget["WidgetType"] == "LARGE_BOX" then
--			elseif Widget["WidgetType"] == "SMALL_LABEL" then

--			end
--		end
--	end
--end)

local function EditHomepage(UI)
	local Editing: Frame = UI.Editing
	local _Speed = GetSetting("AnimationSpeed") * 1.2
	local Selected = ""
	local SelectedTable = {}
	local Tweens = {}

	Editing.Visible = true
	Editing.Preview.Select.Visible = true

	local NewPreviewContent: CanvasGroup = UI.Content:Clone()
	NewPreviewContent.Parent = Editing.Preview

	--// Ensure it's safe
	for _, Item in NewPreviewContent:GetChildren() do
		if Item:IsA("LocalScript") or Item:IsA("Script") --[[ idk why it would be a script but best to check? ]] then 
			Item:Destroy()
		end
	end

	Tweens = {
		TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Size = UDim2.new(.459,0,.551,0), Position = UDim2.new(.271,0,.057,0), BackgroundTransparency = .4}),
		TweenService:Create(UI.Content, TweenInfo.new(_Speed * .8), {GroupTransparency = .9}),
		TweenService:Create(Editing.Background, TweenInfo.new(_Speed), {ImageTransparency = 0}),
		TweenService:Create(Editing.AppName, TweenInfo.new(_Speed), {TextTransparency = 0}),
		TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed), {TextTransparency = 0}),
		TweenService:Create(Editing.Last.ImageLabel, TweenInfo.new(_Speed), {ImageTransparency = 0}),
		TweenService:Create(Editing.Next.ImageLabel, TweenInfo.new(_Speed), {ImageTransparency = 0}),
	}

	Editing.AppName.Text = UI:GetAttribute("AppName")
	Editing.WidgetName.Text = UI:GetAttribute("InitialWidgetName")

	task.spawn(function()
		Tweens[1]:Play()
		Tweens[2]:Play()
		Tweens[3]:Play()
		task.wait(_Speed * .8)
		for i, Tween in Tweens do Tween:Play() end
	end)

	local HoverFX = {}
	local ShouldHover = true

	HoverFX[1] = Editing.Preview.Select.MouseEnter:Connect(function()
		if not ShouldHover then return end
		TweenService:Create(Editing.Preview, TweenInfo.new(_Speed * .6, Enum.EasingStyle.Quart), {Size = UDim2.new(.472,0,.614,0), Position = UDim2.new(.264,0,.017,0)}):Play()
	end)

	HoverFX[2] = Editing.Preview.Select.MouseLeave:Connect(function()
		if not ShouldHover then return end
		TweenService:Create(Editing.Preview, TweenInfo.new(_Speed * .6, Enum.EasingStyle.Quart), {Size = UDim2.new(.459,0,.551,0), Position = UDim2.new(.271,0,.057,0)}):Play()
	end)

	HoverFX["ClickEvent"] = Editing.Preview.Select.MouseButton1Click:Connect(function()
		for _, v in HoverFX do v:Disconnect() end
		Editing.Preview.Select.Visible = false

		_Speed = GetSetting("AnimationSpeed") * .4

		Tweens = {
			TweenService:Create(Editing.Preview, TweenInfo.new(GetSetting("AnimationSpeed") * 1.2, Enum.EasingStyle.Quart), {Position = UDim2.new(.264,0,.189,0)}),
			TweenService:Create(Editing.AppName, TweenInfo.new(_Speed), {TextTransparency = 1}),
			TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed), {TextTransparency = 1}),
			TweenService:Create(Editing.Last.ImageLabel, TweenInfo.new(_Speed), {ImageTransparency = 1}),
			TweenService:Create(Editing.Next.ImageLabel, TweenInfo.new(_Speed), {ImageTransparency = 1}),
			TweenService:Create(UI.Content, TweenInfo.new(_Speed), {GroupTransparency = 1}),
		}

		for i, Tween in Tweens do 
			Tween:Play()
		end

		Tweens[1].Completed:Wait()
		_Speed = GetSetting("AnimationSpeed") * 1.2

		TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}):Play()
		TweenService:Create(UI.Content, TweenInfo.new(_Speed), {GroupTransparency = 0}):Play()
		TweenService:Create(Editing.Background, TweenInfo.new(_Speed), {ImageTransparency = 1}):Play()

		task.wait(_Speed)

		if Selected == "" then
			--// just exit
			Print("Exiting because nothing was selected!")
			for _, Element in Editing.Preview:GetChildren() do
				if not table.find({"DefaultCorner_", "Select"}, Element.Name) then 
					Element.Parent = UI.Content
				end
			end

			Editing.Visible = false
			return
		end

		UI.Banner.Text = SelectedTable["Name"]
		UI.BannerIcon.Image = SelectedTable["Icon"]
		UI.Content:ClearAllChildren()

		local Res = AdministerRemotes.UpdateHomePage:InvokeServer({
			["EventType"] = "UPDATE",
			["EventID"] = `ChangeWidget-{UI.Name}`,
			["WidgetID"] = UI.Name,
			["NewIdentifier"] = Selected
		})

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({"DefaultCorner_", "Select"}, Element.Name) then 
				Element.Parent = UI.Content
			end
		end

		Editing.Visible = false
	end)

	--// start finding other widgets to use
	local Widgets = GetAvailableWidgets()["Large"]
	local Count = 0 --// 0 by default because ideally they have one already?
	local Buttons = {}

	Buttons[1] = Editing.Next.MouseButton1Click:Connect(function()
		ShouldHover = false
		Count += 1

		if Count > #Widgets then
			Count = 1
		end

		_Speed = GetSetting("AnimationSpeed") * 2
		Tweens = {
			TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(-.5,0,.057,0), GroupTransparency = 1}),
			TweenService:Create(Editing.AppName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(-.5,0,.81,0), TextTransparency = 1}),
			TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed,Enum.EasingStyle.Quart), {Position = UDim2.new(-.5,0,.647,0), TextTransparency = 1}),
		} for _, t in Tweens do t:Play() end

		task.wait(_Speed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({"DefaultCorner_", "Select"}, Element.Name) then 
				Element:Destroy() 
			end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(1,0,.075,0)
		Editing.AppName.Position = UDim2.new(1,0,.81,0)
		Editing.WidgetName.Position = UDim2.new(1,0,.647,0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		_Speed = GetSetting("AnimationSpeed") * 2.45
		SelectedTable = Widget

		Tweens = {
			TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.271,0,.057,0), GroupTransparency = 0}),
			TweenService:Create(Editing.AppName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.04,0,.81,0), TextTransparency = 0}),
			TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.04,0,.647,0), TextTransparency = 0}),
		} for _, t in Tweens do t:Play() end

		Tweens[1].Completed:Wait()
		ShouldHover = true
	end)

	Buttons[2] = Editing.Last.MouseButton1Click:Connect(function()
		ShouldHover = false
		Count -= 1

		if Count < 1 then
			Count = 0
			return
		end

		if Count > #Widgets then
			Count = 1
		end

		_Speed = GetSetting("AnimationSpeed") * 2
		Tweens = {
			TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(1,0,.057,0), GroupTransparency = 1}),
			TweenService:Create(Editing.AppName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(1,0,.81,0), TextTransparency = 1}),
			TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed,Enum.EasingStyle.Quart), {Position = UDim2.new(1,0,.647,0), TextTransparency = 1}),
		} for _, t in Tweens do t:Play() end

		task.wait(_Speed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({"DefaultCorner_", "Select"}, Element.Name) then 
				Element:Destroy() 
			end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(-.7,0,.075,0)
		Editing.AppName.Position = UDim2.new(-.7,0,.81,0)
		Editing.WidgetName.Position = UDim2.new(-.7,0,.647,0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		_Speed = GetSetting("AnimationSpeed") * 2.45
		SelectedTable = Widget

		Tweens = {
			TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.271,0,.057,0), GroupTransparency = 0}),
			TweenService:Create(Editing.AppName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.04,0,.81,0), TextTransparency = 0}),
			TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {Position = UDim2.new(.04,0,.647,0), TextTransparency = 0}),
		} for _, t in Tweens do t:Play() end

		Tweens[1].Completed:Wait()
		ShouldHover = true
	end)
end

MainFrame.Home.Widget1.Edit.MouseButton1Click:Connect(function()
	EditHomepage(MainFrame.Home.Widget1)
end)
MainFrame.Home.Widget2.Edit.MouseButton1Click:Connect(function()
	EditHomepage(MainFrame.Home.Widget2)
end)

--// Apps page, also pcall protected incase there is no configuration page
local InstalledApps = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_InstalledApps"))

pcall(function()
	--// idk where else to put this so it's here too
	local Configuration = MainFrame.Configuration
	local Apps = Configuration.Apps
	local Admins = Configuration.Admins

	local Branch = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_CurrentBranch"))
	Configuration.InfoPage.VersionDetails.Logo.Image = Branch["ImageID"]
	Configuration.InfoPage.VersionDetails.TextLogo.Text = Branch["Name"]

	local function Popup(Header, Text, Options, AppIcon)
		--// like everything else, this will soon have an animation
		--// hopefully 1.1 or 1.0 RC2

		local function ClosePopup()
			--// animation ... ...
			Apps.MessageBox.Visible = false
		end

		Apps.MessageBox.Visible = true
		Apps.MessageBox.Header.Text = Header
		Apps.MessageBox.Content.Text = Text
		Apps.MessageBox.AppLogo.LogoImage.Image = AppIcon

		Apps.MessageBox.Button1.Label.Text = Options[1].Text
		Apps.MessageBox.Button1.Icon.Image = Options[1].Icon
		Apps.MessageBox.Button1.MouseButton1Click:Connect(function()
			Options[1].Callback(ClosePopup)
		end)

		Apps.MessageBox.Button2.Label.Text = Options[2].Text
		Apps.MessageBox.Button2.Icon.Image = Options[2].Icon
		Apps.MessageBox.Button2.MouseButton1Click:Connect(function()
			Options[2].Callback(ClosePopup)
		end)
	end

	--// eventually there will be an animation here but i can't have development delayed any more
	Admins.Ranks.Header.TextButton.MouseButton1Click:Connect(function()
		Admins.NewAdmin.Visible = true
	end)

	local function InitAppsPage()
		Configuration.MenuBar.buttons.CApps.TextButton.MouseButton1Click:Connect(function()
			for i, AppItem in Apps.Content:GetChildren() do
				if not AppItem:IsA("CanvasGroup") or AppItem.Name == "Template" then continue end
				AppItem:Destroy()
			end

			local AppsList = AdministerRemotes.GetAllApps:InvokeServer("Bootstrapped")

			for k, App in AppsList do
				local NewTemplate = Apps.Content.Template:Clone()

				NewTemplate.AppName.Text =	k
				NewTemplate.Name = k
				NewTemplate.Logo.Image = App["AppButtonConfig"]["Icon"]
				NewTemplate.AppShortDesc.Text = App["PrivateAppDesc"] ~= nil and App["PrivateAppDesc"] or "This app is installed locally in your Apps folder and metadata has not been loaded."
				NewTemplate.InstallDate.Text = `Installed {App["InstalledSince"] ~= nil and FormatRelativeTime(App["InstalledSince"]) or "locally"}`

				if not IsEIEnabled then
					NewTemplate.BackgroundImage.Image = App["AppButtonConfig"]["Icon"]
				else
					require(script.QuickBlur):Blur(game:GetService("AssetService"):CreateEditableImageAsync(App["AppButtonConfig"]["BGOverride"] ~= nil and App["AppButtonConfig"]["BGOverride"] or App["AppButtonConfig"]["Icon"]), 10, 6).Parent = NewTemplate.BackgroundImage
				end

				NewTemplate.Parent = Apps.Content
				NewTemplate.Visible = true

				--// buttons!!!
				NewTemplate.Disable.MouseButton1Click:Connect(function(Close)
					Popup(
						`Disable "{k}"`, 
						`You can re-enable it from the "Disabled Apps" menu. The app may be able to continue running for this session but it will not be started in any new servers.`, 
						{
							{
								["Text"] = "Yes", 
								["Icon"] = "",
								["Callback"] = function(_Close)
									AdministerRemotes.ManageApp:InvokeServer({
										["App"] = App["AppID"],
										["Action"] = "disable",
										["Source"] = "Apps UI"
									})

									_Close(false)
									InitAppsPage()
								end,
							},
							{
								["Text"] = "Cancel",
								["Icon"] = "",
								["Callback"] = function(_Close)
									_Close(false)
								end,
							}
						},
						App["AppButtonConfig"]["Icon"]
					)
				end)

				NewTemplate.Delete.MouseButton1Click:Connect(function()
					Popup(
						`Remove "{k}"?`, 
						`This app will not start in any new servers but will continue running.`, 
						{
							{
								["Text"] = "Yes", 
								["Icon"] = "",
								["Callback"] = function(_Close)
									AdministerRemotes.ManageApp:InvokeServer({
										["AppID"] = App["AppID"],
										["Action"] = "remove",
										["Source"] = "Apps UI"
									})

									_Close(false)
									InitAppsPage()
								end,
							},
							{
								["Text"] = "Cancel",
								["Icon"] = "",
								["Callback"] = function(_Close)
									_Close()
								end,
							}
						},
						App["AppButtonConfig"]["Icon"]
					)
				end)

				--// animation todo
				NewTemplate.Settings.MouseButton1Click:Connect(function()
					Apps.Options.Visible = true

					--// Eventually dev apps will behave the same as normal ones. Just not today
					Apps.Options.Frame.HeaderLabel.Text = `Configure "{k}"`
					Apps.Options.DetailsCard.BackgroundImage.Image = App["AppButtonConfig"]["Icon"]
					Apps.Options.DetailsCard.Logo.Image = App["AppButtonConfig"]["Icon"]
					Apps.Options.DetailsCard.AppName.Text = k
					Apps.Options.DetailsCard.AppShortDesc.Text = App["PrivateAppDesc"] ~= nil and App["PrivateAppDesc"] or "Metadata cannot be loaded from locally installed applications."
					Apps.Options.DetailsCard.Details.Info_Source.Label.Text = `Installed from {App["InstallSource"] ~= nil and string.gsub(string.gsub(App["InstallSource"], "https://", ""), "http://", "") or "your local Apps folder"}`
					Apps.Options.DetailsCard.Details.Info_PingTime.Label.Text = `✓ {App["BuildTime"]}s`
					Apps.Options.DetailsCard.Details.Info_Version.Label.Text = App["Version"] ~= nil and App["Version"] or "v1"
				end)
			end

			--// out here to not have a memory leak
			Apps.Options.Exit.MouseButton1Click:Connect(function()
				Apps.Options.Visible = false
			end)
		end)
	end

	InitAppsPage()
end)

if GetSetting("TopbarPlus") then --// thanks dogo
	local container  = script.TopbarPlus
	local Icon = require(container.Icon)

	local appsTable = {}

	local AdministerIcon = Icon.new()
		:setLabel("Administer")
		:setImage(18224047110)
		:setCaption("Open Administer")

	local AppsIcon = Icon.new()
		:setLabel("Apps")
		:setCaption("Open an app")

	--local CommandBar = Icon.new()
	--	:setLabel("Command bar")
	--	:setImage(18224047110)
	--	:setCaption("Run a command")

	for i,child in MainFrame.Apps.MainFrame:GetChildren() do
		if child:IsA("GuiObject") and child.Name ~= "Template" and child.Name ~= "Home" then
			table.insert(appsTable,
				Icon.new()
					:setLabel(child.Name)
					:bindEvent("deselected", function()
						Open()

						local LinkID, PageName = child:GetAttribute("LinkID"), nil
						for i, Frame in MainFrame:GetChildren() do
						if Frame:GetAttribute("LinkID") == LinkID then
							PageName = Frame.Name
							break
						end
					end

						if LinkID == nil then
						script.Parent.Main[LastPage].Visible = false	
						LastPage = "NotFound"
						script.Parent.Main.NotFound.Visible = true
						return
					end

						MainFrame[LastPage].Visible = false
						MainFrame[PageName].Visible = true

						LastPage = PageName
						MainFrame.Header.Mark.AppLogo.Image = child.Icon.Image
						MainFrame.Header.Mark.HeaderLabel.Text = `<b>Administer</b> • {PageName}`

						AppsIcon:deselect()
					end)
					:setImage(child.Icon.Image)
					:oneClick()
			)
		end
	end

	AppsIcon:setDropdown(appsTable)

	--AppsIcon.selected:Connect(function()
	--	Open()
	--	OpenApps(0)
	--	AppsIcon:deselect()
	--	AdministerIcon:select()
	--end)

	AdministerIcon.deselected:Connect(function()
		Close(false)
	end)

	AdministerIcon.selected:Connect(function()
		Open()
	end)
end