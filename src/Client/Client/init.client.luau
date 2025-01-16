--// Administer (2.0)
--// Administer Team 2022-2025

local SharedLibs = script.Libraries
local Assets = script.Assets
local Modules = script.Modules

local Neon = require(script.Parent:WaitForChild("ButtonAnims", 10):WaitForChild("neon", 10))
local Shime = require(SharedLibs.Shime)

local Utilities = require(Modules.Utilities)
local Var = require(Modules.Variables)

--// FIXME (FloofyPlasma): Find a better place to put this...
Close(false)

if Var.Services.UserInputService.TouchEnabled and not Var.Services.UserInputService.KeyboardEnabled then
	Print("Making adjustments to UI (Mobile)")
	Var.Mobile = true

	task.defer(function()
		NewNotification(
			"Administer",
			"rbxassetid://12500517462",
			"You've successfully opted in to the Administer Mobile Beta.",
			"Mobile Beta",
			25
		)
	end)
else
	Var.Mobile = false

	script.Parent.MobileOpen:Destroy()
	script.Parent:WaitForChild("MobileOpen", 10):Destroy()
end

--// Verify installation
local Success, Error = pcall(function(...)
	Var.Remotes.Ping:InvokeServer()
end)

if not Success then
	Error(`Failed to establish communication with the server, refer to {Error}`)
	NewNotification(
		"Administer",
		"rbxassetid://18512489355",
		"Administer server ping failed, it seems your client may be incorrectly installed or the server si not executing properly. Please reinstall from source.",
		"Startup failed",
		99999,
		{}
	)
	Var.MainFrame.Visible = false

	return
end

Var.MainFrame.Home.Welcome.Text = `<stroke color="rgb(0,0,0)" transparency = "0.85" thickness="0.4">Good {({
	"morning",
	"afternoon",
	"evening",
})[(os.date("*t").hour < 12 and 1 or os.date("*t").hour < 18 and 2 or 3)]}, <b>{Var.Services.Players.LocalPlayer.DisplayName}</b></stroke>. {Utilities.GetSetting(
	"HomepageGreeting"
)}`
Var.MainFrame.Home.PlayerImage.Image = Var.Services.Players:GetUserThumbnailAsync(
	Var.Services.Players.LocalPlayer.UserId,
	Enum.ThumbnailType.HeadShot,
	Enum.ThumbnailSize.Size352x352
)

task.defer(function()
	local PromColor = Var.Remotes.GetProminentColorFromUserID:InvokeServer(Var.Services.Players.LocalPlayer.UserId)

	Var.MainFrame.Home.Gradient2.ImageLabel.ImageColor3 = Color3.fromRGB(PromColor[1], PromColor[2], PromColor[3])
end)

--// TODO (FloofyPlasma): Give this whole thing a rewrite for type checking...

if InitErrored then
	task.defer(function()
		Error("Failed to boot client, missing required dependency (neon), please reinstall or roll back any changes!")
		NewNotification(
			"Administer",
			"rbxassetid://11601882008",
			"Startup aborted, please make sure Administer is correctly installed. (failed dependency: neon)",
			"Boot failure",
			15
		)
	end)

	return
end

task.defer(Utilities.StartSettingsCheck)

local MenuDebounce = false

Var.Services.UserInputService.InputBegan:Connect(function(Input: InputObject, GameProcessedEvent: boolean)
	if IsPlaying or GameProcessedEvent then return end
	if Input.KeyCode ~= Enum.KeyCode[string.upper(Utilities.GetSetting("PanelKeybind") :: string)] then return end

	local Down = Var.Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

	if Utilities.GetSetting("RequireShift") and Down then
		if not MenuDebounce then
			Open()
			MenuDebounce = true
		else
			Close(false)
			MenuDebounce = false
		end
	elseif not Down and not Utilities.GetSetting("RequireShift") then
		if not MenuDebounce then
			Open()
			--// TODO (FloofyPlasma): Bad hack? Why was this here...
			repeat
				task.wait(0.1)
			until Var.IsOpen
			MenuDebounce = true
		else
			Close(false)
			MenuDebounce = false
		end
	end
end)

if Var.Mobile then
	script.Parent
		:WaitForChild("MobileOpen", 10).Hit.TouchSwipe
		:Connect(function(SwipeDirection: Enum.SwipeDirection, numberOfTouches: number)
			if SwipeDirection == Enum.SwipeDirection.Left then
				Open()
				--// TODO (FloofyPlasma): Bad hack? Why was this here...
				repeat
					task.wait(0.1)
				until Var.IsOpen
				MenuDebounce = true
			end
		end)
end

Var.MainFrame.Header.Minimize.MouseButton1Click:Connect(function()
	Close(false)
	MenuDebounce = false
end)
 
local Success, Error = pcall(function()
	Var.MainFrame.Configuration.InfoPage.VersionDetails.Update.MouseButton1Click:Connect(function()
		local Label = Var.MainFrame.Configuration.InfoPage.VersionDetails.Update.Label
		Label.Text = "CHECKING"

		--// fake slowdown lol.
		task.wait(0.25)
		Var.Remotes.CheckForUpdates:InvokeServer()
		Label.Text = "COMPLETE"

		task.delay(3, function()
			Label.Text = "CHECK FOR UPDATES"
		end)
	end)
end)

if not Success then Print("Version checking ignored as this admin does not have access to the Configuration page!") end

local function GetVersionLabel(AppVersion): string
	return `<font color="rgb(139,139,139)">Your version </font>{AppVersion == Var.AppAPIVersion and `<font color="rgb(56,218,111)">is supported! ({Var.VersionString})</font>` or `<font color="rgb(255,72,72)">may not be supported ({Var.VersionString})</font>`}`
end

--// TODO (FloofyPlasma): Maybe like not make clones?
local function OpenApps(TimeToComplete: number): ()
	local Apps = Var.MainFrame.Apps
	local Clone = Apps.Var.MainFrame:Clone()

	Apps.Var.MainFrame.Visible = false
	Clone.Visible = false
	Clone.Name = "Duplicate"

	for _, Item: Instance | CanvasGroup in Clone:GetChildren() do
		if Item:IsA("UIGridLayout") then continue end
		if not Item:IsA("CanvasGroup") then continue end

		Item.GroupTransparency = 1
		Item.BackgroundTransparency = 1

		local Stroke = Item:FindFirstChildOfClass("UIStroke")

		if not Stroke then continue end
		Stroke.Transparency = 1
	end

	Clone.Size = UDim2.fromScale(2.2, 2)
	Clone.Parent = Apps

	Var.Services.TweenService
		:Create(
			Apps,
			TweenInfo.new(
				TimeToComplete + (TimeToComplete * 0.4),
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out,
				0,
				false
			),
			{ BackgroundTransparency = 0.1 }
		)
		:Play()
	Var.Services.TweenService
		:Create(
			Apps.Background,
			TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart),
			{ ImageTransparency = 0.4 }
		)
		:Play()

	local Tween = Var.Services.TweenService:Create(
		Clone,
		TweenInfo.new(TimeToComplete, Enum.EasingStyle.Quart),
		{ Size = UDim2.fromScale(0.965, 0.928) }
	) --// TODO (FloofyPlasma): Make this a better number

	for _, Item: Instance | CanvasGroup in Clone:GetChildren() do
		if not Item:IsA("CanvasGroup") then continue end

		Var.Services.TweenService
			:Create(
				Item,
				TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart),
				{ GroupTransparency = 0, BackgroundTransparency = 0.2 }
			)
			:Play()

		local Stroke = Item:FindFirstChildOfClass("UIStroke")
		if not Stroke then continue end
		Var.Services.TweenService
			:Create(Stroke, TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart), { Transparency = 0 })
			:Play()
	end

	Clone.Visible = true
	Tween:Play()
	Tween.Completed:Wait()

	Clone:Destroy()
	Apps.Var.MainFrame.Visible = true
end

--// TODO (FloofyPlasma): Maybe like not make clones??
local function CloseApps(TimeToComplete: number): ()
	local Apps = Var.MainFrame.Apps
	local Clone = Apps.Var.MainFrame:Clone()

	Apps.Var.MainFrame.Visible = false

	Clone.Visible = true
	Clone.Name = "Duplicate"
	Clone.Parent = Apps

	Var.Services.TweenService
		:Create(
			Apps,
			TweenInfo.new(
				TimeToComplete + (TimeToComplete * 0.4),
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out,
				0,
				false
			),
			{ BackgroundTransparency = 1 }
		)
		:Play()
	Var.Services.TweenService
		:Create(Apps.Background, TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart), { ImageTransparency = 1 })
		:Play()

	local Tween = Var.Services.TweenService:Create(
		Clone,
		TweenInfo.new(TimeToComplete, Enum.EasingStyle.Quart),
		{ Size = UDim2.fromScale(0.965, 0.928) }
	) --// TODO (FloofyPlasma): Make this a better number

	for _, Item: Instance | CanvasGroup in Clone:GetChildren() do
		if not Item:IsA("CanvasGroup") then continue end

		Var.Services.TweenService
			:Create(
				Item,
				TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart),
				{ GroupTransparency = 1, BackgroundTransparency = 1 }
			)
			:Play()

		local Stroke = Item:FindFirstChildOfClass("UIStroke")
		if not Stroke then continue end
		Var.Services.TweenService
			:Create(Stroke, TweenInfo.new(TimeToComplete + 0.2, Enum.EasingStyle.Quart), { Transparency = 1 })
			:Play()
	end

	Tween:Play()
	Tween.Completed:Wait()

	Clone:Destroy()
end

local function AnimatePopupWithCanvasGroup(Popup: CanvasGroup, CanvasGroup: CanvasGroup, FinalSize: UDim2): ()
	local Blocker = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")

	UICorner.Parent = Blocker

	Blocker.Size = UDim2.fromScale(1, 1)
	Blocker.BackgroundColor3 = Color3.fromRGB(16, 17, 20)
	Blocker.BackgroundTransparency = 1
	Blocker.Name = "Blocker"
	Blocker.Parent = CanvasGroup

	local BGTweenInfo =
		TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.25, Enum.EasingStyle.Cubic)
	local BlockerTween = Var.Services.TweenService:Create(Blocker, BGTweenInfo, { BackgroundTransparency = 0.45 })
	local UICornerTween = Var.Services.TweenService:Create(UICorner, BGTweenInfo, { CornerRadius = UDim.new(0, 24) })
	local MainGroupTween = Var.Services.TweenService:Create(
		CanvasGroup,
		BGTweenInfo,
		{ Size = UDim2.fromScale(0.75, 0.75), Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0.25 }
	)

	BlockerTween:Play()
	UICornerTween:Play()
	MainGroupTween:Play()

	--// TODO (FloofyPlasma): Find a better way to do this...
	local SizeStr: { string } = string.split(tostring(FinalSize), ",")
	local X: number = tonumber(string.split(string.gsub(SizeStr[1], "{", ""), " ")[1]) :: number
	local Y: number = tonumber(string.split(string.gsub(SizeStr[3], "{", ""), " ")[2]) :: number

	Popup.Size = UDim2.fromScale(X / 1.5, Y / 1.5)
	Popup.Position = UDim2.fromScale(0.5, 1.25)
	Popup.GroupTransparency = 0.5
	Popup.Visible = true

	Print("Calculated, proceeding")

	local PopupTween = Var.Services.TweenService:Create(
		Popup,
		TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number, Enum.EasingStyle.Cubic),
		{ Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 }
	)

	PopupTween:Play()
	Print("Played, waiting")
	PopupTween.Completed:Wait()
	Print("All done apparently...")

	Var.Services.TweenService
		:Create(
			Popup,
			TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number, Enum.EasingStyle.Quart),
			{ Size = FinalSize }
		)
		:Play()
end

local function ClosePopup(Popup: CanvasGroup, CanvasGroup: CanvasGroup): ()
	--// TODO (FloofyPlasma): Find a better way to do this...
	local SizeStr: { string } = string.split(tostring(Popup.Size), ",")
	local X: number = tonumber(string.split(string.gsub(SizeStr[1], "{", ""), " ")[1]) :: number
	local Y: number = tonumber(string.split(string.gsub(SizeStr[3], "{", ""), " ")[2]) :: number

	local Blocker: Instance? = CanvasGroup:FindFirstChild("Blocker")
	local UICorner: UICorner? = Blocker and Blocker:FindFirstChildOfClass("UICorner")

	if not Blocker then
		--// FIXME (FloofyPlasma): An animation was spammed, just remake it?
		Blocker = Instance.new("Frame") :: Frame
		UICorner = Instance.new("UICorner") :: UICorner

		if not UICorner or not Blocker then return end

		UICorner.CornerRadius = UDim.new(0, 24)
		UICorner.Parent = Blocker

		Blocker.Size = UDim2.fromScale(1, 1)
		Blocker.BackgroundColor3 = Color3.fromRGB(16, 17, 20)
		Blocker.BackgroundTransparency = 0.45
		Blocker.Name = "Blocker"
		Blocker.Parent = CanvasGroup
	end

	local Blocker = CanvasGroup:FindFirstChild("Blocker")

	local BGTweenInfo =
		TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.25, Enum.EasingStyle.Cubic)
	local BlockerTween = Var.Services.TweenService:Create(Blocker, BGTweenInfo, { BackgroundTransparency = 1 })
	local UICornerTween = Var.Services.TweenService:Create(UICorner, BGTweenInfo, { CornerRadius = UDim.new(0, 0) })
	local MainGroupTween = Var.Services.TweenService:Create(
		CanvasGroup,
		BGTweenInfo,
		{ Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 0 }
	)
	local PopupTween = Var.Services.TweenService:Create(
		Popup,
		TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 0.85, Enum.EasingStyle.Cubic),
		{ Size = UDim2.new(X * 0.35, 0, Y * 0.35, 0), GroupTransparency = 1 }
	)

	BlockerTween:Play()
	UICornerTween:Play()
	MainGroupTween:Play()
	PopupTween:Play()

	BlockerTween.Completed:Wait()
	Blocker:Destroy()
end

local IsEIEnabled = Utilities.GetSetting("EnableEditableImages")
local EnableWaiting = false

if IsEIEnabled == nil then --// (false) or true was always true due to logic so it would ignore the setting
	IsEIEnabled = true
end

local function CreateReflection(Image: string): EditableImage
	local RealEI = Var.Services.AssetService:CreateEditableImageAsync(Content.fromUri(Image))
	local Resized = Vector2.new(RealEI.Size.X, RealEI.Size.Y)

	local px = RealEI:ReadPixelsBuffer(Vector2.zero, Resized)
	local rpx = {}

	for i = 1, Resized.X * Resized.Y * 4 do
		table.insert(rpx, buffer.readu8(px, i - 1))
	end

	local npx = {}

	for Chunk = 0, (Resized.X * Resized.Y - 1) do
		local Index = Resized.Y * 4 - (Chunk % Resized.Y) * 4 + math.floor(Chunk / Resized.Y) * Resized.Y * 4 - 3
		table.move(rpx, Chunk * 4 + 1, Chunk * 4 + 4, Index, npx)

		if EnableWaiting then task.wait() end
	end

	local FinalBuffer = buffer.create(Resized.X * Resized.Y * 4)

	for i = 1, #npx do
		buffer.writeu8(FinalBuffer, i - 1, npx[i])
	end

	RealEI:WritePixelsBuffer(Vector2.zero, Resized, FinalBuffer)

	return RealEI
end

for _, Item: CanvasGroup | Instance in Var.MainFrame.Apps.Var.MainFrame:GetChildren() do
	if not Item:IsA("CanvasGroup") then continue end

	local Click: Instance? = Item:FindFirstChild("Click")
	local Icon: Instance? = Item:FindFirstChild("Icon")
	local Reflection: Instance? = Item:FindFirstChild("Reflection")

	if Click and Click:IsA("TextButton") then
		Click.MouseButton1Click:Connect(function()
			task.defer(CloseApps, tonumber(Utilities.GetSetting("AnimationSpeed")) :: number / 7 * 5.5)

			local LinkId, PageName = Item:GetAttribute("LinkID"), nil

			for _, Frame: Instance in Var.MainFrame:GetChildren() do
				if Frame:GetAttribute("LinkID") == LinkId then
					PageName = Frame.Name

					break
				end
			end

			if not LinkId then
				Var.MainFrame[Var.LastPage].Visible = false
				Var.LastPage = "NotFound"
				Var.MainFrame.NotFound.Visible = true
				return
			end

			Var.MainFrame[Var.LastPage].Visible = false
			Var.MainFrame[PageName].Visible = true

			Var.LastPage = PageName

			Var.MainFrame.Header.Mark.AppLogo.Image = Icon and Icon:IsA("ImageLabel") and Icon.Image

			local Title = Item:FindFirstChild("Title")

			Var.MainFrame.Header.Mark.HeaderLabel.Text =
				`<b>Administer</b> · {Title and Title:IsA("TextLabel") and Title.Text}`
		end)

		if not IsEIEnabled then continue end

		local S, E = pcall(function()
			if Reflection and Reflection:IsA("ImageLabel") and Icon and Icon:IsA("ImageLabel") then
				Reflection.ImageContent = Content.fromObject(CreateReflection(Icon.Image))
				Reflection.Visible = true

				local IconBG = Item:FindFirstChild("IconBG")

				if IconBG and IconBG:IsA("ImageLabel") then IconBG.Visible = false end
			end
		end)

		print(S, E)
		IsEIEnabled = S
	end
end

if #Var.MainFrame.Apps.Var.MainFrame:GetChildren() >= 250 then
	warn(
		"Warning: Administer has detected over 250 apps installed. Although there is no hardcoded limit, you may experience poor performance on anything above this."
	)
end

Var.MainFrame.Header.AppDrawer.MouseButton1Click:Connect(function()
	OpenApps(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 0.8)
end)

local AppConnections: { RBXScriptConnection } = {}

local function LoadApp(ServerURL, ID, Reason): string
	Print("Downloading full info for that app...")

	local Success, Data = pcall(function()
		return Var.Services.ReplicatedStorage.Var.Remotes.GetAppInfo:InvokeServer(ServerURL, ID)
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

	local AppInfoFrame = Var.MainFrame.Configuration.Marketplace.Install

	AppInfoFrame.Titlebar.Bar.Title.Text = Data["AppTitle"]
	AppInfoFrame.MetaCreated.Label.Text = `Created {Utilities.FormatRelativeTime(Data["AppCreatedUnix"])}`
	AppInfoFrame.MetaUpdated.Label.Text = `Updated {Utilities.FormatRelativeTime(Data["AppUpdatedUnix"])}`
	AppInfoFrame.MetaVersion.Label.Text =
		GetVersionLabel(tonumber(Data["AdministerMetadata"]["AdministerAppAPIPreferredVersion"]))
	if Reason == nil then
		AppInfoFrame.MetaServer.Label.Text =
			`Shown because <b>You're subscribed to {string.split(ServerURL, "/")[3]}</b>`
	else
		AppInfoFrame.MetaServer.Label.Text = `Shown because <b>{Reason}</b>`
	end
	AppInfoFrame.MetaInstalls.Label.Text = `<b>{Utilities.ShortNumber(Data["AppDownloadCount"])}</b> installs`
	AppInfoFrame.AppClass.Icon.Image = Data["AppType"] == "Theme" and "http://www.roblox.com/asset/?id=14627761757"
		or "http://www.roblox.com/asset/?id=14114931854"
	AppInfoFrame.Install.HeaderLabel.Text = "Install"

	xpcall(function()
		if Data["AppDevID"] == nil then error("") end
		AppInfoFrame.UserInfo.PFP.Image = Var.Services.Players:GetUserThumbnailAsync(
			Data["AppDevID"],
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size180x180
		)
		AppInfoFrame.UserInfo.Creator.Text = `@{Var.Services.Players:GetNameFromUserIdAsync(Data["AppDeveloper"])}`
	end, function()
		--// This app server does not support AppDevID yet
		Print("Missing AppDevID field in AppObject")
		print(Data["AppDeveloper"])
		print(Var.Services.Players:GetUserIdFromNameAsync(Data["AppDeveloper"]))
		print(
			Var.Services.Players:GetUserThumbnailAsync(
				Var.Services.Players:GetUserIdFromNameAsync(Data["AppDeveloper"]),
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size180x180
			)
		) --// why is it freezing:? i'm confused..
		AppInfoFrame.UserInfo.PFP.Image = Var.Services.Players:GetUserThumbnailAsync(
			Var.Services.Players:GetUserIdFromNameAsync(Data["AppDeveloper"]),
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size180x180
		)
		AppInfoFrame.UserInfo.Creator.Text = `@{Data["AppDeveloper"]}`
	end)

	for _, Tag in AppInfoFrame.Tags:GetChildren() do
		if Tag.Name ~= "Tag" and Tag:IsA("Frame") then Tag:Destroy() end
	end

	for _, TagData in Data["AppTags"] do
		local Tag = AppInfoFrame.Tags.Tag:Clone()

		Tag.TagText.Text = TagData
		Tag.Name = TagData
		Tag.Visible = true
		Tag.TagText.TextTransparency = 0
		Tag.Parent = AppInfoFrame.Tags
	end

	AppInfoFrame.Head.HeaderLabel.Text = `Install {Data["AppName"]}`
	AppInfoFrame.Description.Text = Data["AppLongDescription"]
	AppInfoFrame.Dislikes.Text = Utilities.ShortNumber(Data["AppDislikes"])
	AppInfoFrame.Likes.Text = Utilities.ShortNumber(Data["AppLikes"])

	local Percent = tonumber(Data["AppLikes"]) :: number
		/ (tonumber(Data["AppDislikes"]) :: number + tonumber(Data["AppLikes"]) :: number)
	AppInfoFrame.RatingBar.Positive.Size = UDim2.new(Percent, 0, 1, 0)
	AppInfoFrame.RatingBar.Positive.Percentage.Text = math.round(Percent * 100) .. "%"

	AppInfoFrame.Install.MouseButton1Click:Connect(function()
		AppInfoFrame.Install.HeaderLabel.Text = "Installing..."
		AppInfoFrame.Install.ImageLabel.Image = "rbxassetid://84027648824846"

		AppInfoFrame.Install.HeaderLabel.Text = Var.Remotes.InstallApp:InvokeServer(ServerURL, ID)[2]
		AppInfoFrame.Install.ImageLabel.Image = "rbxassetid://14651353224"
	end)

	AppInfoFrame.Head.Close.MouseButton1Click:Connect(function()
		ClosePopup(AppInfoFrame, AppInfoFrame.Parent.MainMarketplace)
	end)

	AnimatePopupWithCanvasGroup(
		Var.MainFrame.Configuration.Marketplace.Install,
		Var.MainFrame.Configuration.Marketplace.MainMarketplace,
		UDim2.fromScale(0.868, 1)
	)

	return "More"
end

local InProgress = false
local AR: { RBXScriptConnection } = {}

local function GetApps(): ()
	Print("Refreshing app list...")
	Var.MainFrame.Configuration.Marketplace.MPFrozen.Visible = false

	if InProgress then
		Warn("You're clicking too fast or your app servers are unresponsive! Please slow down.")
		Var.MainFrame.Configuration.Marketplace.MPFrozen.Visible = true

		return
	end

	InProgress = true

	for _, Connection in AppConnections do
		Connection:Disconnect()
	end

	for _, Connection in AR do
		Connection:Disconnect()
	end

	for _, Item in Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content:GetChildren() do
		if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
	end

	local AppList = Var.Remotes.GetAppList:InvokeServer()

	if AppList[1] == false then
		Warn("You're clicking too fast or your app servers are unresponsive! Please slow down.")
		Var.MainFrame.Configuration.Marketplace.MPFrozen.Visible = true
		Var.MainFrame.Configuration.Marketplace.MPFrozen.Subheading1.Text =
			`Sorry, but one or more app servers returned an error while processing that (code: {AppList[2]}, route /list). This may be a ban, a temporary ratelimit, or it may be unavailbable. Please retry your request again soon.\n\nIf you keep seeing this page please check the log and remove any defective app servers.`

		return
	end

	Var.MainFrame.Configuration.MenuBar.New.FMarketplace.Input.FocusLost:Connect(
		function(EnterPressed: boolean, InputThatCausedFocusLoss: InputObject)
			if not EnterPressed then return end

			Var.MainFrame.Configuration.Marketplace.PartialSearch.Visible = false
			Var.MainFrame.Configuration.Marketplace.MPFrozen.Visible = false

			local Result = Var.Remotes.SearchAppsByMarketplaceServer:InvokeServerInvokeServer(
				"https://administer.notpyx.me",
				Var.MainFrame.Configuration.MenuBar.New.FMarketplace.Input.Text
			)

			if Result.SearchIndex == "NoResultsFound" then
				Var.MainFrame.Configuration.Marketplace.PartialSearch.Visible = true
				Var.MainFrame.Configuration.Marketplace.PartialSearch.Text =
					"Sorry, but we couldn't find any results for that."

				return GetApps()
			elseif Result.RatioInfo.IsRatio == true then
				Var.MainFrame.Configuration.Marketplace.PartialSearch.Visible = true
				Var.MainFrame.Configuration.Marketplace.PartialSearch.Text =
					`We think you meant {Result.RatioInfo.RatioKeyword} ({string.sub(
						string.gsub(Result.RatioInfo.RatioConfidence, "0.", ""),
						1,
						2
					) .. "%"} confidence), showing results for that`
			end

			for _, Connection in AR do
				Connection:Disconnect()
			end

			for _, Item in Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content:GetChildren() do
				if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
			end

			for Index, SearchResult in Result.SearchIndex do
				local Frame = Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content.Template:Clone()
				Frame.Parent = Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content

				Frame.AppName.Text = SearchResult["AppName"]
				Frame.ShortDesc.Text = SearchResult["AppShortDescription"]
				Frame.InstallCount.Text = SearchResult["AppDownloadCount"]
				Frame.Rating.Text = "--%"
				Frame.Name = Index

				table.insert(
					AR,
					Frame.Install.MouseButton1Click:Connect(function()
						Frame.InstallIcon.Image = "rbxassetid://84027648824846"
						Frame.InstallLabel.Text = "Loading..."
						Frame.InstallLabel.Text = LoadApp(
							"https://administer.notpyx.me",
							SearchResult["AdministerMetadata"]["AdministerID"],
							`You searched for it ({SearchResult["IndexedBecause"]} in query).`
						)

						Frame.InstallIcon.Image = "rbxassetid://16467780710"
					end)
				)

				Frame.Visible = true
			end
		end
	)

	for Index, App in AppList do
		if App["processed_in"] ~= nil then
			Print(`Loaded {#AppList - 1} apps from the database in {App["processed_in"]}s`)
			continue
		end

		local Frame = Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content.Template:Clone()
		Frame.Parent = Var.MainFrame.Configuration.Marketplace.MainMarketplace.Content

		Frame.AppName.Text = App["AppName"]
		Frame.ShortDesc.Text = App["AppShortDescription"]
		Frame.InstallCount.Text = App["AppDownloadCount"]
		Frame.Rating.Text = string.sub(string.gsub(App["AppRating"], "0.", ""), 1, 2) .. "%"
		Frame.Name = Index

		table.insert(
			AR,
			Frame.Install.MouseButton1Click:Connect(function()
				Frame.InstallIcon.Image = "rbxassetid://84027648824846"
				Frame.InstallLabel.Text = "Loading..."
				Frame.InstallLabel.Text = LoadApp(App["AppServer"], App["AppID"], "")

				Frame.InstallIcon.Image = "rbxassetid://16467780710"
			end)
		)

		Frame.Visible = true
	end

	InProgress = false
end

local RanksFrame = Var.MainFrame.Configuration.Admins.Container.Ranks.Content
local AdminConnections: { RBXScriptConnection } = {}

local function RefreshAdmins(): ()
	for _, Item in RanksFrame:GetChildren() do
		if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
	end

	for _, Item in Var.MainFrame.Configuration.Admins.Container.Admins.Content:GetChildren() do
		if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
	end

	for _, Connection in AdminConnections do
		Connection:Disconnect()
	end

	AdminConnections = {}

	local Shimmer1 = Shime.new(Var.MainFrame.Configuration.Admins.Container.Ranks)
	local Shimmer2 = Shime.new(Var.MainFrame.Configuration.Admins.Container.Admins)

	Shimmer1:Play()
	Shimmer2:Play()

	task.defer(function()
		local List = Var.Remotes.GetRanks:InvokeServer("LegacyAdmins")

		for i, User in List do
			if User["MemberType"] == "User" then
				local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

				local Suc, Err = pcall(function()
					AdminPageTemplate.PFP.Image = tostring(
						Var.Services.Players:GetUserThumbnailAsync(
							tonumber(User["ID"]),
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size180x180
						)
					)
					AdminPageTemplate.Info.Text = `AdminID Override`

					AdminPageTemplate.Metadata.Text =
						`This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `@{Var.Services.Players:GetNameFromUserIdAsync(User["ID"])}`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					AdminPageTemplate.Name = User["ID"]
				end)

				if not Suc then
					print(Err)
					AdminPageTemplate.PFP.Image = ""
					AdminPageTemplate.Metadata.Text = `AdminID Override`

					AdminPageTemplate.Info.Text =
						`This user is in the override module, as such we don't have any information.`
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
					AdminPageTemplate.PFP.Image = GroupInfo["EmblemUrl"]
					AdminPageTemplate.Metadata.Text = `AdminID Override`

					AdminPageTemplate.Info.Text =
						`This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `{GroupInfo["Name"]} (all ranks)`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
					AdminPageTemplate.Name = User["ID"]
				end)

				if not Suc then
					print(Err)
					AdminPageTemplate.PFP.Image = ""
					AdminPageTemplate.Info.Text = `AdminID Override`

					AdminPageTemplate.Metadata.Text =
						`This user is in the override module, as such we don't have any information.`
					AdminPageTemplate.PlayerName.Text = `(group not found) all ranks`

					AdminPageTemplate.Visible = true
					AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
				end
			end
		end
	end)

	local List = Var.Remotes.GetRanks:InvokeServer()

	if typeof(List) == "string" then
		warn(debug.traceback(`Failed: {List}`))

		return "Something went wrong"
	else
		for i, v in List do
			local Template = RanksFrame.Template:Clone()

			Template.Name = v["RankName"]
			Template.RankName.Text = v["RankName"]
			Template.Info.Text =
				`Rank {v["RankID"]} • {v["PagesCode"] == "/" and #v["AllowedPages"] .. " pages" or "Full access"} • {#v["Members"]} member{#v["Members"] == 1 and "" or "s"} {v["Protected"] and "• Protected" or ""} • {v["Reason"]}`

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
						AdminPageTemplate.PFP.Image = tostring(
							game.Var.Services.Players:GetUserThumbnailAsync(
								tonumber(User["ID"]),
								Enum.ThumbnailType.HeadShot,
								Enum.ThumbnailSize.Size180x180
							)
						)
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						--// "Created by" replacement to prevent any name mistakes ("Created by AddedUsername" not "Created by CreatedUsermame")
						AdminPageTemplate.Metadata.Text =
							`{string.gsub(v["Reason"], "Created by", "Added by")} <b>{Utilities.FormatRelativeTime(
								v["ModifiedUnix"]
							)}</b>`
						AdminPageTemplate.PlayerName.Text = `@{Var.Services.Players:GetNameFromUserIdAsync(User["ID"])}`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end)

					if not Suc then
						print(Err)
						AdminPageTemplate.PFP.Image = ""
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						AdminPageTemplate.Metadata.Text =
							`{v["Reason"]} <b>{Utilities.FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `Deleted ({User["ID"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end
				else
					local AdminPageTemplate = RanksFrame.Parent.Parent.Admins.Content.Template:Clone()

					local Success, GroupInfo = pcall(function()
						return game:GetService("GroupService"):GetGroupInfoAsync(User["ID"])
					end)

					local Suc, Err = pcall(function()
						AdminPageTemplate.PFP.Image = GroupInfo["EmblemUrl"]
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						--// "Created by" replacement to prevent any name mistakes ("Created by AddedUsername" not "Created by CreatedUsermame")
						AdminPageTemplate.Metadata.Text =
							`{string.gsub(v["Reason"], "Created by", "Added by")} <b>{Utilities.FormatRelativeTime(
								v["ModifiedUnix"]
							)}</b>`
						AdminPageTemplate.PlayerName.Text =
							`{GroupInfo["Name"]} ({(User["GroupRank"] or 0) == 0 and "all ranks" or User["GroupRank"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end)

					if not Suc then
						print(Err)
						AdminPageTemplate.PFP.Image = ""
						AdminPageTemplate.Info.Text = `{v["RankName"]} (Rank {i})`
						AdminPageTemplate.Metadata.Text =
							`{v["Reason"]} <b>{Utilities.FormatRelativeTime(v["ModifiedUnix"])}</b>`
						AdminPageTemplate.PlayerName.Text = `Deleted ({User["ID"]})`

						AdminPageTemplate.Visible = true
						AdminPageTemplate.Parent = RanksFrame.Parent.Parent.Admins.Content
						AdminPageTemplate.Name = User["ID"]
					end
				end
			end
			xpcall(function()
				Template.Configure.MouseButton1Click:Connect(function()
					local NewAdmin = Var.MainFrame.MainFrame.Configuration.Admins.NewAdmin
					local AdminEnviornment = require(NewAdmin.AdminHelperEnv) :: any

					AdminEnviornment.EditMode = true
					AdminEnviornment.EditModeName = v["RankName"]
					AdminEnviornment.EditModeApps = v["AllowedPages"]
					AdminEnviornment.EditModeRank = v["RankID"]
					AdminEnviornment.EditModePages = v["PagesCode"]
					AdminEnviornment.EditModeIsProtected = v["Protected"]
					AdminEnviornment.EditModeReason = v["Reason"]
					AdminEnviornment.EditModeMembers = v["Members"]

					NewAdmin.Page1.Body.Text = AdminEnviornment.Strings.WelcBodyEdit
					NewAdmin.Page1.Header.Text = string.format(AdminEnviornment.Strings.WelcHeaderEdit, v["RankName"])
					NewAdmin.BottomData.RankTitle.Text = `Editing "{v["RankName"]}`

					NewAdmin.Page2.TextInput.Text = v["RankName"]

					AnimatePopupWithCanvasGroup(NewAdmin, NewAdmin.Parent.Container, UDim2.new(0.671, 0, 0.916, 0))
				end)
			end, function()
				Template.Info.Text =
					`Rank {v["RankID"]} • {v["PagesCode"] == "/" and #v["AllowedPages"] .. " pages" or "Full access"} • {#v["Members"]} member{#v["Members"] == 1 and "" or "s"} Editing disabled due to an error • {v["Reason"]}`
			end)
		end
	end

	Shimmer1:Pause()
	Shimmer2:Pause()
	Shimmer1:GetFrame():Destroy()
	Shimmer2:GetFrame():Destroy()
end

Var.MainFrame.Configuration.MenuBar.New.FMarketplace.Click.MouseButton1Click:Connect(GetApps)
Var.MainFrame.Configuration.MenuBar.New.DAdmins.Click.MouseButton1Click:Connect(RefreshAdmins)
Var.MainFrame.Configuration.Admins.NewAdmin.Page5.NextPage.MouseButton1Click:Connect(RefreshAdmins)

local IsDonating = false
local Passes = {}

xpcall(function(...)
	local _Content = Var.Remotes.GetPasses:InvokeServer()

	for _, Pass in _Content do
		local Cloned = Var.MainFrame.Configuration.InfoPage.Donate.Buttons.Temp:Clone()

		Cloned.Label.Text = `{Pass["price"]}`
		Cloned.MouseButton1Click:Connect(function()
			IsDonating = true
			Var.Services.MarketplaceService:PromptGamePassPurchase(Var.Services.Players.LocalPlayer, Pass["id"])
		end)
		Cloned.Visible = true
		Cloned.Parent = Var.MainFrame.Configuration.InfoPage.Donate.Buttons

		if
			Var.Services.MarketplaceService:UserOwnsGamePassAsync(Var.Services.Players.LocalPlayer.UserId, Pass["id"])
		then
			Var.MainFrame.Configuration.InfoPage.Donate.Message.Text =
				`Thank you for your support, {Var.Services.Players.LocalPlayer.DisplayName}! Your donation helps ensure future Administer updates for years to come ^^`
		end

		table.insert(Passes, Pass["id"])
	end
end, function(a0)
	print("Failed to fetch donation passes, assuming this is a permissions issue!")
end)

Var.Services.MarketplaceService.PromptGamePassPurchaseFinished:Connect(
	function(Player: Instance, GamePassId: number, WasPurchased: boolean)
		if WasPurchased and table.find(Passes, GamePassId) then
			Close(false)

			script.Parent.FullscreenMessage.LocalScript.Enabled = true
			require(SharedLibs.ConfettiCreator)()
		end
	end
)

local WidgetData = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_HomeWidgets"))
local Widgets = GetAvailableWidgets()["Large"]
local ActiveWidgets = {}

for _, UI in Var.MainFrame.Home:GetChildren() do
	if not table.find({ "Widget1", "Widget2" }, UI.Name) then continue end

	for _, Widget in Widgets do
		if Widget["Identifier"] == WidgetData[UI.Name] then
			xpcall(function()
				UI.SideData.Banner.Text = Widget["Name"]
				UI.SideData.BannerIcon.Image = Widget["Icon"]
			end, function() end)
			Widget["BaseUIFrame"].Parent = UI.Content
			Widget["BaseUIFrame"].Visible = true
			Widget["OnRender"](Var.Services.Players.LocalPlayer, UI.Content)

			UI:SetAttribute("AppName", string.split(Widget["Identifier"], "\\")[1])
			UI:SetAttribute("InitialWidgetName", string.split(Widget["Identifier"], "\\")[2])

			table.insert(ActiveWidgets, Widget)
		end
	end
end

local function EditHomepage(UI): ()
	local Editing = UI.Editing
	local _Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2
	local Selected = ""
	local SelectedTable = {}
	local Tweens: { Tween } = {}

	Editing.Visible = true
	Editing.Preview.Select.Visible = true

	local NewPreviewContent: CanvasGroup = UI.Content:Clone()

	--// Ensure it's safe
	for _, Item in NewPreviewContent:GetChildren() do
		if
			Item:IsA("LocalScript") or Item:IsA("Script") --[[ idk why it would be a script but best to check? ]]
		then
			Item:Destroy()
		end
	end

	NewPreviewContent.Parent = Editing:FindFirstChild("Preview")

	Tweens = {
		Var.Services.TweenService:Create(Editing.Preview, TweenInfo.new(_Speed, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.459, 0, 0.551, 0),
			Position = UDim2.new(0.271, 0, 0.057, 0),
			BackgroundTransparency = 0.4,
		}),
		--Var.Services.TweenService:Create(UI.Content, TweenInfo.new(_Speed * .8), {GroupTransparency = .9,}),
		Var.Services.TweenService:Create(
			NewPreviewContent,
			TweenInfo.new(_Speed * 0.35),
			{ Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }
		),
		Var.Services.TweenService:Create(Editing.Background, TweenInfo.new(_Speed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.AppName, TweenInfo.new(_Speed), { TextTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed), { TextTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.Last.ImageLabel, TweenInfo.new(_Speed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.Next.ImageLabel, TweenInfo.new(_Speed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(
			Editing.Preview.DefaultCorner_,
			TweenInfo.new(_Speed),
			{ CornerRadius = UDim.new(0, 18) }
		),
	}

	Editing.AppName.Text = UI:GetAttribute("AppName")
	Editing.WidgetName.Text = UI:GetAttribute("InitialWidgetName")

	task.spawn(function()
		Tweens[1]:Play()
		Tweens[2]:Play()
		Tweens[3]:Play()
		Tweens[8]:Play()
		task.wait(_Speed * 0.8)
		for _, Tween in Tweens do
			Tween:Play()
		end
	end)

	local HoverFX = {}
	local ShouldHover = true

	HoverFX[1] = Editing.Preview.Select.MouseEnter:Connect(function()
		if not ShouldHover then return end
		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(_Speed * 0.6, Enum.EasingStyle.Quart),
				{ Size = UDim2.new(0.472, 0, 0.614, 0), Position = UDim2.new(0.264, 0, 0.017, 0) }
			)
			:Play()
	end)

	HoverFX[2] = Editing.Preview.Select.MouseLeave:Connect(function()
		if not ShouldHover then return end
		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(_Speed * 0.6, Enum.EasingStyle.Quart),
				{ Size = UDim2.new(0.459, 0, 0.551, 0), Position = UDim2.new(0.271, 0, 0.057, 0) }
			)
			:Play()
	end)

	HoverFX["ClickEvent"] = Editing.Preview.Select.MouseButton1Click:Connect(function()
		for _, v in HoverFX do
			v:Disconnect()
		end
		Editing.Preview.Select.Visible = false

		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 0.4

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.264, 0, 0.189, 0) }
			),
			Var.Services.TweenService:Create(Editing.AppName, TweenInfo.new(_Speed), { TextTransparency = 1 }),
			Var.Services.TweenService:Create(Editing.WidgetName, TweenInfo.new(_Speed), { TextTransparency = 1 }),
			Var.Services.TweenService:Create(Editing.Last.ImageLabel, TweenInfo.new(_Speed), { ImageTransparency = 1 }),
			Var.Services.TweenService:Create(Editing.Next.ImageLabel, TweenInfo.new(_Speed), { ImageTransparency = 1 }),
		}

		for _, Tween in Tweens do
			Tween:Play()
		end

		Tweens[1].Completed:Wait()
		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2

		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.043, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }
			)
			:Play()
		Var.Services.TweenService:Create(Editing.Background, TweenInfo.new(_Speed), { ImageTransparency = 1 }):Play()
		Var.Services.TweenService
			:Create(Editing.Preview.DefaultCorner_, TweenInfo.new(_Speed), { CornerRadius = UDim.new(0, 0) })
			:Play()

		task.wait(_Speed)

		if Selected == "" then
			--// just exit
			Print("Exiting because nothing was selected!")
			for _, Element in Editing.Preview:GetChildren() do
				if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element.Parent = UI.Content end
			end

			Editing.Visible = false
			return
		end

		UI.SideData.Banner.Text = SelectedTable["Name"]
		UI.SideData.BannerIcon.Image = SelectedTable["Icon"]
		UI.Content:ClearAllChildren()

		local Res = Var.Remotes.UpdateHomePage:InvokeServer({
			["EventType"] = "UPDATE",
			["EventID"] = `ChangeWidget-{UI.Name}`,
			["WidgetID"] = UI.Name,
			["NewIdentifier"] = Selected,
		})

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element.Parent = UI.Content end
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

		if Count > #Widgets then Count = 1 end

		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2
		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.057, 0), GroupTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.81, 0), TextTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.647, 0), TextTransparency = 1 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		task.wait(_Speed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element:Destroy() end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(1, 0, 0.075, 0)
		Editing.AppName.Position = UDim2.new(1, 0, 0.81, 0)
		Editing.WidgetName.Position = UDim2.new(1, 0, 0.647, 0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2.45
		SelectedTable = Widget

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.271, 0, 0.057, 0), GroupTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.81, 0), TextTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.647, 0), TextTransparency = 0 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

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

		if Count > #Widgets then Count = 1 end

		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2
		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.057, 0), GroupTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.81, 0), TextTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.647, 0), TextTransparency = 1 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		task.wait(_Speed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element:Destroy() end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(-0.7, 0, 0.075, 0)
		Editing.AppName.Position = UDim2.new(-0.7, 0, 0.81, 0)
		Editing.WidgetName.Position = UDim2.new(-0.7, 0, 0.647, 0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		_Speed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2.45
		SelectedTable = Widget

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.271, 0, 0.057, 0), GroupTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.81, 0), TextTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(_Speed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.647, 0), TextTransparency = 0 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		Tweens[1].Completed:Wait()
		ShouldHover = true
	end)
end

Var.MainFrame.Home.Widget1.Edit.MouseButton1Click:Connect(function()
	EditHomepage(Var.MainFrame.Home.Widget1)
end)
Var.MainFrame.Home.Widget2.Edit.MouseButton1Click:Connect(function()
	EditHomepage(Var.MainFrame.Home.Widget2)
end)

local InstalledApps = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_InstalledApps"))

pcall(function()
	--// idk where else to put this so it's here too
	local Configuration = Var.MainFrame.Configuration
	local Apps = Configuration.Apps
	local Admins = Configuration.Admins.Container

	local Branch = game:GetService("HttpService"):JSONDecode(script.Parent:GetAttribute("_CurrentBranch"))
	Configuration.InfoPage.VersionDetails.Logo.Image = Branch["ImageID"]
	Configuration.InfoPage.VersionDetails.TextLogo.Text = Branch["Name"]

	local function Popup(
		Header,
		Text,
		Options: { { Text: string, Icon: string, Callback: ((boolean?) -> ()) -> () } },
		AppIcon
	): ()
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

	Admins.Ranks.Header.TextButton.MouseButton1Click:Connect(function()
		AnimatePopupWithCanvasGroup(Admins.Parent.NewAdmin, Admins, UDim2.new(0.671, 0, 0.916, 0))
	end)

	Admins.Parent.NewAdmin.Page5.NextPage.MouseButton1Click:Connect(function()
		ClosePopup(Admins.Parent.NewAdmin, Admins)
	end)

	Admins.Parent.NewAdmin.BottomData.Controls.Exit.MouseButton1Click:Connect(function()
		ClosePopup(Admins.Parent.NewAdmin, Admins)
	end)

	local function InitAppsPage()
		Configuration.MenuBar.New.CApps.Click.MouseButton1Click:Connect(function()
			for i, AppItem in Apps.Content:GetChildren() do
				if not AppItem:IsA("CanvasGroup") or AppItem.Name == "Template" then continue end
				AppItem:Destroy()
			end

			local AppsList = Var.Remotes.GetAllApps:InvokeServer("Bootstrapped")

			for k, App in AppsList do
				local NewTemplate = Apps.Content.Template:Clone()

				NewTemplate.AppName.Text = k
				NewTemplate.Name = k
				NewTemplate.Logo.Image = App["AppButtonConfig"]["Icon"]
				NewTemplate.AppShortDesc.Text = App["PrivateAppDesc"] ~= nil and App["PrivateAppDesc"]
					or "This app is installed locally in your Apps folder and metadata has not been loaded."
				NewTemplate.InstallDate.Text =
					`Installed {App["InstalledSince"] ~= nil and Utilities.FormatRelativeTime(App["InstalledSince"]) or "locally"}`

				if not IsEIEnabled then
					NewTemplate.BackgroundImage.Image = App["AppButtonConfig"]["Icon"]
				else
					NewTemplate.BackgroundImage.ImageContent = Content.fromObject(
						require(script.Libraries.QuickBlur):Blur(
							game:GetService("Var.Services.AssetService"):CreateEditableImageAsync(
								App["AppButtonConfig"]["BGOverride"] ~= nil and App["AppButtonConfig"]["BGOverride"]
									or App["AppButtonConfig"]["Icon"]
							),
							10,
							6
						)
					)
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
									Var.Remotes.ManageApp:InvokeServer({
										["App"] = App["AppID"],
										["Action"] = "disable",
										["Source"] = "Apps UI",
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
							},
						},
						App["AppButtonConfig"]["Icon"]
					)
				end)

				NewTemplate.Delete.MouseButton1Click:Connect(function()
					Popup(`Remove "{k}"?`, `This app will not start in any new servers but will continue running.`, {
						{
							["Text"] = "Yes",
							["Icon"] = "",
							["Callback"] = function(_Close)
								Var.Remotes.ManageApp:InvokeServer({
									["AppID"] = App["AppID"],
									["Action"] = "remove",
									["Source"] = "Apps UI",
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
						},
					}, App["AppButtonConfig"]["Icon"])
				end)

				--// animation todo
				NewTemplate.Settings.MouseButton1Click:Connect(function()
					Apps.Options.Visible = true

					--// Eventually dev apps will behave the same as normal ones. Just not today
					Apps.Options.Frame.HeaderLabel.Text = `Configure "{k}"`
					Apps.Options.DetailsCard.BackgroundImage.Image = App["AppButtonConfig"]["Icon"]
					Apps.Options.DetailsCard.Logo.Image = App["AppButtonConfig"]["Icon"]
					Apps.Options.DetailsCard.AppName.Text = k
					Apps.Options.DetailsCard.AppShortDesc.Text = App["PrivateAppDesc"] ~= nil and App["PrivateAppDesc"]
						or "Metadata cannot be loaded from locally installed applications."
					Apps.Options.DetailsCard.Details.Info_Source.Label.Text =
						`Installed from {App["InstallSource"] ~= nil and string.gsub(
							string.gsub(App["InstallSource"], "https://", ""),
							"http://",
							""
						) or "your local Apps folder"}`
					Apps.Options.DetailsCard.Details.Info_PingTime.Label.Text = `✓ {App["BuildTime"]}s`
					Apps.Options.DetailsCard.Details.Info_Version.Label.Text = App["Version"] ~= nil and App["Version"]
						or "v1"
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

if Utilities.GetSetting("TopbarPlus") then --// thanks dogo
	local container = SharedLibs.TopbarPlus
	local Icon = require(container.Icon)

	local appsTable = {}

	local AdministerIcon = Icon.new():setLabel("Administer"):setImage(18224047110):setCaption("Open Administer")

	local AppsIcon = Icon.new():setLabel("Apps"):setCaption("Open an app")

	--local CommandBar = Icon.new()
	--	:setLabel("Command bar")
	--	:setImage(18224047110)
	--	:setCaption("Run a command")

	for i, child in Var.MainFrame.Apps.Var.MainFrame:GetChildren() do
		if child:IsA("GuiObject") and child.Name ~= "Template" and child.Name ~= "Home" then
			table.insert(
				appsTable,
				Icon.new()
					:setLabel(child.Name)
					:bindEvent("deselected", function()
						Open()

						local LinkID, PageName = child:GetAttribute("LinkID"), nil
						for i, Frame in Var.MainFrame:GetChildren() do
							if Frame:GetAttribute("LinkID") == LinkID then
								PageName = Frame.Name
								break
							end
						end

						if LinkID == nil then
							script.Parent.Main[Var.LastPage].Visible = false
							Var.LastPage = "NotFound"
							script.Parent.Main.NotFound.Visible = true
							return
						end

						Var.MainFrame[Var.LastPage].Visible = false
						Var.MainFrame[PageName].Visible = true

						Var.LastPage = PageName
						Var.MainFrame.Header.Mark.AppLogo.Image = child.Icon.Image
						Var.MainFrame.Header.Mark.HeaderLabel.Text = `<b>Administer</b> • {PageName}`

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
		if IsPlaying then
			AdministerIcon:select()
			return
		end

		Close(false)
	end)

	AdministerIcon.selected:Connect(function()
		if IsPlaying then
			AdministerIcon:deselect()
			return
		end

		Open()
	end)
end

script.Assets.LocalScript.Enabled = Utilities.GetSetting("EnableClickEffects")

if Utilities.GetSetting("ChatCommand") == true then
	--// Register this for LCS users
	Var.Services.Players.LocalPlayer.Chatted:Connect(function(m)
		if m == "/adm" then Open() end
	end)

	xpcall(function()
		local Command = Instance.new("TextChatCommand")

		Command.PrimaryAlias = "/adm"
		Command.SecondaryAlias = "/administer"
		Command.Triggered:Connect(Open)
		Command.Parent = game.TextChatService.TextChatCommands
	end, function()
		Print("TCS is disabled (or something else failed), ignoring custom command for TCS")
	end)
end
