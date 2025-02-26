--// Administer (2.0.0)

--// pyxfluff (2024-2025)

local Frontend = { Popup = {}, Drawer = {} }

local Modules = script.Parent
local Libraries = script.Parent.Parent.Libraries

local Utilities = require(Modules.Utilities)
local Var = require(Modules.Variables)

function Frontend.Render() end

function Frontend.CloneElement(Element: GuiObject, Props: {}, OnClone: ((Clone: GuiObject) -> ())?): ()
	local Clone = Element:Clone()

	for Property, Value in Props do
		Clone[Property] = Value
	end

	Clone.Parent = Element.Parent

	if typeof(OnClone) == "nil" then
		return Clone
	else
		return OnClone(Clone)
	end
end

function Frontend.Log(Text, LogLevel)
	--// TODO
	return { MainFrame = {} }
end

function Frontend.Open(): ()
	if not Var.Panel then Var.Panel = Frontend.Render() end
	local AS = tonumber(Utilities.GetSetting("AnimationSpeed"))
	local X: number = 0.85
	local Y: number = 0.7

	Var.MainFrame.Size = UDim2.fromScale(X / 1.5, Y / 1.5)
	Var.MainFrame.GroupTransparency = 0.5

	Var.IsPanelAnimating = true
	Var.MainFrame.Visible = true
	if Utilities.GetSetting("UseAcrylic") then
		Libraries.Neon:BindFrame(Var.Panel.MainFrame, {
			Transparency = 0.95,
			BrickColor = BrickColor.new("Institutional white"),
		})
	end

	if not Var.Mobile then
		Var.MainFrame.Position = UDim2.fromScale(0.5, 1.25)
	else
		Var.MainFrame.Position = UDim2.fromScale(1.25, 0.5)
	end

	local PopupTween = Var.Services.TweenService:Create(
		Var.MainFrame,
		TweenInfo.new(AS, Enum.EasingStyle.Cubic),
		{ Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 }
	)
	PopupTween:Play()
	PopupTween.Completed:Wait()
	Var.Services.TweenService
		:Create(Var.MainFrame, TweenInfo.new(AS, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(X, Y),
		})
		:Play()

	Var.OpenSound:Play()
	task.delay(AS, function()
		Var.IsPanelAnimating = false
	end)
end

function Frontend.Close(Instant: boolean): ()
	if not Instant then Instant = false end --// TODO (FloofyPlasma): Redundant?

	Var.IsPanelAnimating = true

	xpcall(function(...)
		Libraries.Neon:UnbindFrame(Var.MainFrame)
	end, function(a0)
		--// We can ignore this, it probably happened bc a skid is spamming the keybind.
		Var.InitErrored = true
	end)

	local Duration = 0
	if not Instant then Duration = (tonumber(Utilities.GetSetting("AnimationSpeed")) or 1) end

	local X: number = 0.85
	local Y: number = 0.7

	local OT = Var.Services.TweenService:Create(
		Var.MainFrame,
		TweenInfo.new(Duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(X / 1.5, Y / 1.5),
			GroupTransparency = 0.5,
		}
	)

	OT:Play()
	OT.Completed:Wait()

	if not Var.Mobile then
		Var.Services.TweenService
			:Create(
				Var.MainFrame,
				TweenInfo.new(Duration, Enum.EasingStyle.Cubic),
				{ Position = UDim2.fromScale(0.5, 1.5), GroupTransparency = 1 }
			)
			:Play()
	else
		Var.Services.TweenService
			:Create(
				Var.MainFrame,
				TweenInfo.new(Duration, Enum.EasingStyle.Cubic),
				{ Position = UDim2.fromScale(1.5, 0.5), GroupTransparency = 1 }
			)
			:Play()
	end

	task.delay(Duration, function()
		Var.IsPanelAnimating = false
		Var.MainFrame.Visible = false
	end)
end

function Frontend.CheckForUpdates(Products: {}?): ()
	--// TODO: Full product checking, need to redo this regardless
	local Label = Var.MainFrame.Configuration.InfoPage.VersionDetails.Update.Label
	Label.Text = "CHECKING"

	--// fake slowdown lol
	task.wait(0.25)
	Var.Remotes.CheckForUpdates:InvokeServer()
	Label.Text = "COMPLETE"

	task.delay(3, function()
		Label.Text = "CHECK FOR UPDATES"
	end)
end

function Frontend.Drawer.Open(TimeToComplete: number): ()
	local Apps = Var.MainFrame.AppDrawer
	local Container = Instance.new("CanvasGroup")
	local UiC = Instance.new("UICorner")

	Container.Size = UDim2.new(1, 0, 1, 0)
	Container.Position = UDim2.new(0, 0, 0, 0)

	Container.ZIndex = 99999
	Container.Parent = Apps.AppDrawerCover
	Container.BackgroundTransparency = 1
	Container.BackgroundColor3 = Color3.fromRGB(11, 12, 17)

	UiC.CornerRadius = UDim.new(0, 18)
	UiC.Parent = Container

	Apps.Visible = true
	Apps.Position = UDim2.new(0, 0, 0.75, 0)

	Apps.AppHolder.Position = UDim2.new(0, 0, 0.45, 0)

	for _, Child in Var.MainFrame:GetChildren() do
		if Child:IsA("Frame") and Child.Visible == true and Child ~= Apps then Child.Parent = Container end
	end

	Var.Services.TweenService
		:Create(Container, TweenInfo.new(TimeToComplete, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false), {
			GroupTransparency = 0.2,
			BackgroundTransparency = 0.25,
			Size = UDim2.new(0.95, 0, 0.95, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		})
		:Play()

	Var.Services.TweenService
		:Create(Apps, TweenInfo.new(TimeToComplete * 0.3, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0, 0, 0, 0),
		})
		:Play()

	Var.Services.TweenService
		:Create(Apps.AppHolder, TweenInfo.new(TimeToComplete * 0.55, Enum.EasingStyle.Quart), {
			GroupTransparency = 0,
			Position = UDim2.new(0, 0, 0, 0),
		})
		:Play()
end

function Frontend.Drawer.Close(TimeToComplete: number): ()
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

function Frontend.Drawer.HoverBegin() end

function Frontend.Drawer.HoverEnd() end

function Frontend.Popup.Open(Popup: CanvasGroup, CanvasGroup: CanvasGroup, FinalSize: UDim2): ()
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

	Utilities.Logging.Print("Calculated, proceeding")

	local PopupTween = Var.Services.TweenService:Create(
		Popup,
		TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number, Enum.EasingStyle.Cubic),
		{ Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 }
	)

	PopupTween:Play()
	Utilities.Logging.Print("Played, waiting")
	PopupTween.Completed:Wait()
	Utilities.Logging.Print("All done apparently...")

	Var.Services.TweenService
		:Create(
			Popup,
			TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number, Enum.EasingStyle.Quart),
			{ Size = FinalSize }
		)
		:Play()
end

function Frontend.Popup.Close(Popup: CanvasGroup, CanvasGroup: CanvasGroup): ()
	--// TODO (FloofyPlasma): Find a better way to do this...
	local SizeStr: { string } = string.split(tostring(Popup.Size), ",")
	local X: number = tonumber(string.split(string.gsub(SizeStr[1], "{", ""), " ")[1]) :: number
	local Y: number = tonumber(string.split(string.gsub(SizeStr[3], "{", ""), " ")[2]) :: number

	local Blocker: Instance = CanvasGroup:FindFirstChild("Blocker") :: Instance
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

function Frontend.Popup.new(
	Header,
	Text,
	Options: { { Text: string, Icon: string, Callback: ((boolean?) -> ()) -> () } },
	AppIcon,
	Apps -- TODO
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

return Frontend
