--/ Administer

--// PyxFluff 2022-2024

local Settings = game.ReplicatedStorage:WaitForChild("AdministerRemotes"):WaitForChild("SettingsRemotes"):WaitForChild("RequestSettings"):InvokeServer()

for i, v in pairs(Settings) do
	local ClonedTemplate 

	if type(v["Value"]) == "boolean" then
		ClonedTemplate = script.Parent.Page.BoolTemplate:Clone()
		ClonedTemplate.Parent = script.Parent.Page
		ClonedTemplate.Name = v["Name"]
		ClonedTemplate.SettingName.Text = v["Name"]
		ClonedTemplate.Parent = script.Parent.Page
		ClonedTemplate.Description.Text = v["Description"]
		ClonedTemplate.Visible = true


		if v["Value"] == false then
			task.delay(2.5, function()
				ClonedTemplate.Action.Label.Text = "ENABLE"
				ClonedTemplate.Action.Icon.Image = "rbxassetid://14115271671"
			end)
		else
			task.delay(2.5, function()
				ClonedTemplate.Action.Label.Text = "DISABLE"
				ClonedTemplate.Action.Icon.Image = "rbxassetid://15105963940"
			end)
		end

		ClonedTemplate.Action.MouseButton1Click:Connect(function()
			local Result = game.ReplicatedStorage.AdministerRemotes.SettingsRemotes.ChangeSetting:InvokeServer(v["Name"], not v["Value"])

			if Result[1] then
				ClonedTemplate.Action.Label.Text = string.upper(Result[2]) --// some themes will prefer sentence case
				if v["Value"] == false then
					task.delay(2.5, function()
						ClonedTemplate.Action.Label.Text = "DISABLE"
						ClonedTemplate.Action.Icon.Image = "rbxassetid://15105963940"
					end)
					v["Value"] = true
				else
					task.delay(2.5, function()
						ClonedTemplate.Action.Label.Text = "ENABLE"
						ClonedTemplate.Action.Icon.Image = "rbxassetid://14115271671"
					end)
					v["Value"] = false
				end
			else
				ClonedTemplate.Action.Text = `FAILED: ({Result[2]})`
				task.delay(5, function()
					if v["Value"] == false then			
						ClonedTemplate.Action.Text = "ENABLE"
					else
						ClonedTemplate.Action.Text = "DISABLE"
					end
				end)
			end
		end)
	elseif type(v["Value"]) == "string" or type(v["Value"]) == "number" then --// TODO: Slider type
		local ClonedTemplate = script.Parent.Page.InputTemplate:Clone()
		ClonedTemplate.Parent = script.Parent.Page
		ClonedTemplate.Name = v["Name"]
		ClonedTemplate.SettingName.Text = v["Name"]
		ClonedTemplate.Parent = script.Parent.Page
		ClonedTemplate.Description.Text = v["Description"]
		ClonedTemplate.Action.Text = v["Value"]
		ClonedTemplate.Visible = true

		ClonedTemplate.Action.FocusLost:Connect(function(WasEnter, Input)
			if WasEnter then
				v["Value"] = ClonedTemplate.Action.Text
				local Result = game.ReplicatedStorage.AdministerRemotes.SettingsRemotes.ChangeSetting:InvokeServer(v["Name"], ClonedTemplate.Action.Text)

				ClonedTemplate.Action.Text = Result[2]
				task.delay(2.5, function()
					ClonedTemplate.Action.Text = v["Value"]
				end)
			end
		end)
	end
end