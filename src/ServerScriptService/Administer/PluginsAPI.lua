local Plugin = {}

local ExistingButtons = {}
local Administer
local ActivateUI = true
Plugin.APIVersion = "0.2"


---------------------------------


Plugin.ActivateUI = function(UI)
	if not ActivateUI then return end 
	Administer = UI
	ActivateUI = false
end

Plugin.NewButton = function(ButtonIcon, Name, Frame, Letter, Tip)
	if table.find(ExistingButtons,ExistingButtons[Name]) then
		return {false, "Button was found already"}
	end
	local Success, Dock = pcall(function()
		return Administer:WaitForChild("Main"):WaitForChild("Apps"):WaitForChild("MainFrame")
	end)

	if not Success then
		warn(`[Administer PluginAPI]: Something went wrong on our end, check the documentation or installation. (Failed building PluginButtonObject for {Name})`)
		return {false, "Something went wrong on our end, try checking the documentation."}
	end

	local Button: TextButton = Dock:WaitForChild("Template"):Clone()

	local Success, Error = pcall(function()
		Button.Visible = true
		Button.Name = Letter..Name
		Button.Icon.Image = ButtonIcon
		Button.Desc.Text = Tip
		Button.Title.Text = Name

		local PluginFrame = Frame:Clone()
		PluginFrame.Visible = true
		PluginFrame.Parent = Administer.Main
		PluginFrame.Name = Frame.Name
		PluginFrame.Visible = false
	end)
	if not Success then
		Button:Destroy()
		return {false, `Could not build the button! This is likely a configuration issue on your end - try checking the documentation. Error: {Error}`}
	else
		Button.Parent = Dock
		return {true, "Success!"}
	end
end

Plugin.Build = function(OnBuild, PluginConfig, PluginButton, Widgets)
	--print("[Administer]: Starting App with "..Plugin.APIVersion.." API...")
	--task.wait()
	--warn(PluginConfig)
	
	--local Button = NewButton(
	--	PluginButton["Icon"],
	--	PluginButton["Name"],
	--	PluginButton["Frame"],
	--	PluginButton["Letter"],
	--	PluginButton["Tip"]
	--)
	
	--if Button[1] == false then
	--	error(`BuildPlugin failure: {Button[2]}`)
	--end
	
	task.spawn(function()
		OnBuild(PluginConfig)
	end)
end

Plugin.PluginEventsFolder = function(Name)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerPlugins")
	if not Events then
		Events = Instance.new("Folder")
		Events.Parent = game.ReplicatedStorage
		Events.Name = "AdministerPlugins"
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

Plugin.NewRemoteEvent = function(Name, FolderName, OnServerEvent)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerPlugins"):FindFirstChild(FolderName)
	if not Events then
		return nil, "Folder not found! Call API.PluginEventsFolder("..FolderName..") to make one!"
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

Plugin.NewRemoteFunction = function(Name: string, FolderName: string, OnServerInvoke)
	local Events = game.ReplicatedStorage:FindFirstChild("AdministerPlugins"):FindFirstChild(FolderName)
	if not Events then
		return nil, "Folder not found! Call API.PluginEventsFolder("..FolderName..") to make one!"
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

Plugin.RemoveRemote = function(Name: string, FolderName: string, Force: boolean)
	local Event = game.ReplicatedStorage.AdministerPlugins:FindFirstChild(FolderName):FindFirstChild(Name)
	if not Event then 
		return {false, "Event or folder does not exist!"}
	end
	if Event:GetAttribute("ACTIVECONNECTIONS") and not Force then
		return {false, "This event has active connections! To force the removal, pass Force through as trye"}
	end
	Event:Destroy()
	return {true, "The operation completed successfully."}
end



return Plugin
