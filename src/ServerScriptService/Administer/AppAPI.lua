local App = {}

local ExistingButtons = {}
local Administer
local ActivateUI = true
App.APIVersion = "0.1"


---------------------------------


App.ActivateUI = function(UI)
	if not ActivateUI then return end 
	Administer = UI
	ActivateUI = false
end

App.NewButton = function(ButtonIcon, Name, Frame, Letter, Tip)
	
	repeat task.wait(1) until Administer
	
	if table.find(ExistingButtons,ExistingButtons[Name]) then
		return {false, "Button was found already"}
	end
	local Success, Dock = pcall(function()
		return Administer:WaitForChild("Main"):WaitForChild("Apps"):WaitForChild("MainFrame")
	end)

	if not Success then
		warn(`[Administer AppAPI]: Something went wrong on our end, check the documentation or installation. (Failed building AppButtonObject for {Name})`)
		return {false, "Something went wrong on our end, try checking the documentation."}
	end

	local Button: TextButton = Dock:WaitForChild("Template"):Clone()

	local Success, Error = pcall(function()
		Button.Visible = true
		Button.Name = Letter..Name
		Button.Icon.Image = ButtonIcon
		Button.Desc.Text = Tip
		Button.Title.Text = Name

		local AppFrame = Frame:Clone()
		AppFrame.Parent = Administer.Main
		AppFrame.Name = Frame.Name
		AppFrame.Visible = false
	end)
	if not Success then
		Button:Destroy()
		return {false, `Could not build the button! This is likely a configuration issue on your end - try checking the documentation. Error: {Error}`}
	else
		Button.Parent = Dock
		return {true, "Success!"}
	end
end

App.Build = function(OnBuild, AppConfig, AppButton)
	print("[Administer]: Starting App with "..App.APIVersion.." API...")

	local BuiltAPI = {
		NewNotification = function(Admin: Player, Body: string, Heading: string, Icon: string?, Duration: number?, Options: Table?, OpenTime: int?)
			local TweenService = game:GetService("TweenService")
			local Panel = Admin.PlayerGui.AdministerMainPanel
			-- This code is very old and has been fixed to my ability.
			-- I dislike the dummy notification thing, it's very hacky,
			-- but it works.

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
			Notification.Header.Title.Text = `<b>{AppButton["Name"]}</b> • {Heading}`
			Notification.Header.Administer.Image = AppButton["Icon"]
			Notification.Header.ImageL.Image = Icon  
			
			for i, Object in Options do
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
				Notification.Parent:Destroy()
			end
			
			Notification.Buttons.DismissButton.MouseButton1Click:Connect(Close)

			task.wait(Duration)
			
			Close()
		end,
	}
	
	local Button = App.NewButton(
		AppButton["Icon"],
		AppButton["Name"],
		AppButton["Frame"],
		AppButton["Letter"],
		AppButton["Tip"]
	)
	
	if Button[1] == false then
		error(`BuildApp failure: {Button[2]}`)
	end
	
	task.spawn(function()
		OnBuild(AppConfig, BuiltAPI)
	end)
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

App.NewRemoteEvent = function(Name, FolderName, OnServerEvent)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerApps"):FindFirstChild(FolderName)
	if not Events then
		return nil, "Folder not found! Call API.AppEventsFolder("..FolderName..") to make one!"
	end
	local NewEvent = Events:FindFirstChild(Name)
	if NewEvent then
		return NewEvent--, "Event already exists! To delete it, call API.DeleteEvent("..Name..",true)"
	else
		NewEvent = Instance.new("RemoteEvent")
		NewEvent.Name = Name
		NewEvent.Parent = Events
		if typeof(OnServerEvent) == "function" then
			NewEvent.OnServerEvent:Connect(OnServerEvent)
			NewEvent:SetAttribute("ACTIVECONNECTIONS", true)
		end
		return NewEvent
	end
end

App.NewRemoteFunction = function(Name: string, FolderName: string, OnServerInvoke)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerApps"):FindFirstChild(FolderName)
	if not Events then
		return nil, "Folder not found! Call API.AppEventsFolder("..FolderName..") to make one!"
	end
	local NewEvent = Events:FindFirstChild(Name)
	if NewEvent then
		return NewEvent--, "Event already exists! To delete it, call API.DeleteEvent("..Name..",true)"
	else
		NewEvent = Instance.new("RemoteFunction")
		NewEvent.Name = Name
		NewEvent.Parent = Events
		if typeof(OnServerInvoke) == "function" then
			NewEvent.OnServerInvoke = OnServerInvoke
			NewEvent:SetAttribute("ACTIVECONNECTIONS", true)
		end
		return NewEvent
	end
end

App.RemoveRemote = function(Name: string, FolderName: string, Force: boolean)
	local Event = game.ReplicatedStorage.AdministerApps:FindFirstChild(FolderName):FindFirstChild(Name)
	if not Event then 
		return {false, "Event or folder does not exist!"}
	end
	if Event:GetAttribute("ACTIVECONNECTIONS") and not Force then
		return {false, "This event has active connections! To force the removal, pass Force through as trye"}
	end
	Event:Destroy()
	return {true, "The operation completed successfully."}
end



return App