local SoundClick = Instance.new("Sound", script.Parent)
SoundClick.SoundId = "rbxassetid://178104975"

local SoundEnter = Instance.new("Sound", script.Parent)
SoundEnter.SoundId = "rbxassetid://5991592592"
SoundEnter.Volume = 0.5
SoundClick.Volume = 0.5

local mouse = game.Players.LocalPlayer:GetMouse()
local Settings = game.ReplicatedStorage
	:WaitForChild("AdministerRemotes")
	:WaitForChild("SettingsRemotes")
	:WaitForChild("RequestSettings")
	:InvokeServer()

local function GetSetting(Setting)
	local SettingModule = Settings

	for i, v in pairs(SettingModule) do
		if v["Name"] == Setting then return v["Value"] end
	end
	return "Not found"
end

--print("Clicker deployed to "..script.Parent.Name)
for i, v in script.Parent.Parent:GetDescendants() do
	if v:IsA("TextButton") or v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			require(script.Parent.Parent.ButtonAnims).AddEffect(
				v,
				game.Players.LocalPlayer:GetMouse(),
				0.3,
				Color3.new(0.678431, 0.713725, 0.772549)
			)
		end)

		if v.Visible == true then SoundEnter:Play() end

		if GetSetting("PlayClickSound") then SoundClick:Play() end
	end
end
