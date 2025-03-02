--// Administer (2.0)
--// pyxfluff 2022-2025

local SharedLibs = script.Libraries
local Assets = script.Assets
local Modules = script.Modules

print("Importing modules.")
local Var = require(Modules.Variables)

local Admins = require(Modules.Admins)
local Apps = require(Modules.Apps)
local Frontend = require(Modules.Frontend)
local Utilities = require(Modules.Utilities)
local Widgets = require(Modules.Widgets)

local t = Utilities.Translate

print("Done, starting initialization of client logic")
Frontend.Close(true)

Var.Services.UserInputService.InputBegan:Connect(function(KeyCode, IsGameProc)
    if KeyCode.KeyCode == Enum.KeyCode.F2 then
        Frontend.Open()
    end
end)
    


print(t("admin.RankDefault"))

if not pcall(function()
	Var.Remotes.Ping:InvokeServer()
end) then
	--Utilities.NewNotification("Administer", "")
	error(`Could not connect to the server, is Administer improperly installed?`)
end

Var.MainFrame.Header.Mark.AppLogo.MouseButton1Click:Connect(function()
	Frontend.Drawer.Open(2)
end)

--// Button hooks

--[[
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

if not Success then Print("Version checking ignored as this admin does not have access to the Configuration page!") end

local IsEIEnabled = Utilities.GetSetting("EnableEditableImages")
local EnableWaiting = false

if IsEIEnabled == nil then --// (false) or true was always true due to logic so it would ignore the setting
	IsEIEnabled = true
end

for _, Item: CanvasGroup | Instance in Var.MainFrame.Apps.Var.MainFrame:GetChildren() do
	--// TODO
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

	Admins.Ranks.Header.TextButton.MouseButton1Click:Connect(function()
		AnimatePopupWithCanvasGroup(Admins.Parent.NewAdmin, Admins, UDim2.new(0.671, 0, 0.916, 0))
	end)

	Admins.Parent.NewAdmin.Page5.NextPage.MouseButton1Click:Connect(function()
		ClosePopup(Admins.Parent.NewAdmin, Admins)
	end)

	Admins.Parent.NewAdmin.BottomData.Controls.Exit.MouseButton1Click:Connect(function()
		ClosePopup(Admins.Parent.NewAdmin, Admins)
	end)
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
]]
