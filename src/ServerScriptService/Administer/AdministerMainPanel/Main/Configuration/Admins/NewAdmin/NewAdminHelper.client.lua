-- darkpixlz 2023 - 2024

-- Administer


local TweenService = game:GetService("TweenService")

local function SwapPages(Page1, Page2, NewIcon, Spin)
	for _, descendant in pairs(Page1:GetDescendants()) do
		if descendant:IsA("ImageLabel") then
			TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif descendant:IsA("GuiObject") then
			TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("TextLabel") then
			TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif descendant:IsA("Frame") then
			TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
		end
	end
	local Tweem = TweenService:Create(Page1, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Position = UDim2.new({-.5,0,0,0})})
	Tweem:Play()

	-- For reasons unknown to me, this does not work and will not work. If you know, let me know, because I sure as heck don't.
	--TweenService:Create(script.Parent.SideDecor.ImageLabel, TweenInfo.new(.2, Enum.EasingStyle.Cubic), {Position = UDim2.new({.15,0,.356,0}), ImageTransparency = 1}):Play()

	Tweem.Completed:Wait()
	for _, descendant in pairs(Page2:GetDescendants()) do
		if descendant:IsA("ImageLabel") then
			descendant.ImageTransparency = 1
			descendant.BackgroundTransparency = 1
		elseif descendant:IsA("GuiObject") then
			descendant.Transparency = 1
		elseif descendant:IsA("TextLabel") then
			descendant.TextTransparency = 1
			descendant.BackgroundTransparency = 1
		elseif descendant:IsA("Frame") then
			descendant.BackgroundTransparency = 1
		end
	end

	Page2.Position = UDim2.new(0.3,0,0,0)

	if Spin == true then
		script.Parent.SideDecor.ImageLabel.Script.Disabled = false
	else
		script.Parent.SideDecor.ImageLabel.Script.Disabled = true
		task.wait(.1)
		script.Parent.SideDecor.ImageLabel.Rotation = 0
	end
	script.Parent.SideDecor.ImageLabel.Image = NewIcon

	Page2.Visible = true
	Page1.Visible = false

	for _, descendant in pairs(Page2:GetDescendants()) do
		if descendant:IsA("ImageLabel") then
			TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0,
			}):Play()
			--elseif descendant:IsA("GuiObject") then
			--TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			--	Transparency = 0
			--}):Play()
		elseif descendant:IsA("TextLabel") then
			TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
			}):Play()
		elseif descendant:IsA("TextBox") then
			TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				BackgroundTransparency = 0,
			}):Play()
		elseif descendant:IsA("TextButton") then
			TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
			}):Play()
			if descendant.Name == "NextPage" then
				TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0,
				}):Play()
			end
		elseif descendant:IsA("Frame") and not descendant:GetAttribute("hide") then
			TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0
			}):Play()
		end
	end

	TweenService:Create(Page2, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Position = UDim2.new({0,0,0,0})}):Play()
	--TweenService:Create(script.Parent.SideDecor.ImageLabel, TweenInfo.new(.2, Enum.EasingStyle.Cubic), {Position = UDim2.new({.239,0,.356,0}), ImageTransparency = 0}):Play()
end

-- all of the next buttons

local Frames = script.Parent
local ConnectionsTable
local FinalData = {}

Frames.Page1.NextPage.MouseButton1Click:Connect(function()
	-- Verify the filtering service is online
	SwapPages(Frames.Page1, Frames.Loading, "rbxassetid://11102397100", true)
	
	local Success, FilterResult = pcall(function()
		return game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer("test string")
	end)

	if Success and FilterResult[1] then
		SwapPages(Frames.Loading, Frames.Page2, "rbxassetid://15084609272", false)

		ConnectionsTable = Frames.Page2.TextInput:GetPropertyChangedSignal("Text"):Connect(function()
			Frames.Page2.PreviewText.Text = `Preview: {game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer(Frames.Page2.TextInput.Text)[2]}`
		end)
	else
		SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://14147040290", false)

		Frames.Page5.Header.Text = "Oops! That's not meant to happen."
		if FilterResult[2] then
			Frames.Page5.Body.Text = "Failed to connect to Roblox's filtering service. This likely isn't an issue with your game, try again later.\n\n"..FilterResult[2] or "{{result}}"
		else
			Frames.Page5.Body.Text = "Failed to call the remote to filter. Did you install Administer wrong?\n\n"..FilterResult or "{{result}}"
		end
	end
end)

Frames.Page2.NextPage.MouseButton1Click:Connect(function()
	SwapPages(Frames.Page2, Frames.Loading, "rbxassetid://11102397100", true)

	ConnectionsTable:Disconnect()

	for i, v in ipairs(Frames.Page3.Members.Members:GetChildren()) do
		if not v:GetAttribute("IsTemplate") and v:IsA("Frame") then
			v:Destroy()
		end
	end

	ConnectionsTable = {
		Frames.Page3.AddPane.AddGroup.Click.MouseButton1Click:Connect(function() 
			local Clone = Frames.Page3.Members.Members.GroupTemplate:Clone()

			Clone.Parent = Frames.Page3.Members.Members
			Clone.Visible = true
			Clone:SetAttribute("IsTemplate", false)
			Clone:SetAttribute("TemplateType", "Group")

			ConnectionsTable["Check1"] = Clone.TextInput:GetPropertyChangedSignal("Text"):Connect(function()
				local Checking = false
				
				local CheckTask = function()
					Checking = true
					local Success, Info = pcall(function()
						return game:GetService("GroupService"):GetGroupInfoAsync(tonumber(Clone.TextInput.Text))
					end)
					print(Success, Info)

					if Success then
						Clone._Name.Text = `{Info["Name"]}`
						Clone.Image.Image = Info["EmblemUrl"]
					else
						Clone._Name.Text = `Unknown`
						Clone.Image.Image = "rbxassetid://15105863258"
					end

					ConnectionsTable["Close1"] = Clone.Delete.MouseButton1Click:Connect(function()
						Clone:Destroy()
					end)
				end

				if Checking then
					task.cancel(CheckTask) --// too quick, stop the old one...
					task.spawn(CheckTask)
				else
					Checking = true
					task.spawn(CheckTask)
				end
			end)
		end),

		Frames.Page3.AddPane.AddUser.Click.MouseButton1Click:Connect(function() 
			local Clone = Frames.Page3.Members.Members.PlayerTemplate:Clone()

			Clone.Parent = Frames.Page3.Members.Members
			Clone.Visible = true
			Clone:SetAttribute("IsTemplate", false)
			Clone:SetAttribute("TemplateType", "User")

			ConnectionsTable["Check2"] = Clone.TextInput:GetPropertyChangedSignal("Text"):Connect(function()
				local Success, Info = pcall(function()
					return {
						game.Players:GetNameFromUserIdAsync(Clone.TextInput.Text),
						game.Players:GetUserThumbnailAsync(Clone.TextInput.Text, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					}
				end)

				print(Success, Info)

				if Success then
					Clone._Name.Text = `{Info[1]}`
					Clone.Image.Image = Info[2]
				else
					Clone._Name.Text = `Unknown`
					Clone.Image.Image = "rbxassetid://15105863258"
				end

				ConnectionsTable["Close2"] = Clone.Delete.MouseButton1Click:Connect(function()
					Clone:Destroy()
				end)
			end)
		end)
	}

	SwapPages(Frames.Loading, Frames.Page3, "rbxassetid://15082548595")
end)

Frames.Page3.NextPage.MouseButton1Click:Connect(function()
	SwapPages(Frames.Page3, Frames.Loading, "rbxassetid://11102397100", true)

	for i, v in ipairs(ConnectionsTable) do
		v:Disconnect()
	end

	-- We fetch apps locally to make sure it's accurate
	for i, v in ipairs(script.Parent.Parent.Parent.Parent.Apps.MainFrame:GetChildren()) do
		if not table.find({'AHome', 'Template', 'UIGridLayout'}, v.Name) then
			local Template = Frames.Page4.Apps.Apps.Template:Clone()

			Template.Parent = Frames.Page4.Apps.Apps
			Template.AppName.Text = v.Title.Text
			Template.Icon.Image = v.Icon.Image
			Template.Name = v.Title.Text
			Template.StatusImage.Image = "rbxassetid://15106359967"
			Template.Status.Text = "Enabled"
			Template:SetAttribute("TechName", v.Name)

			ConnectionsTable[v.Title.Text] = Template.Toggle.MouseButton1Click:Connect(function()
				--[[
				hidden assetid rbxassetid://15082584039
				show assetid rbxassetid://15106359967
				]]
				if Template:GetAttribute("Showing") then
					Template.StatusImage.Image = "rbxassetid://15082598696"
					Template.Status.Text = "Disabled"
					Template:SetAttribute("Showing", false)
				else
					Template.StatusImage.Image = "rbxassetid://15106359967"
					Template.Status.Text = "Enabled"
					Template:SetAttribute("Showing", true)	

				end
			end)
		end
	end

	SwapPages(Frames.Loading, Frames.Page4, "rbxassetid://14865439768")
end)

Frames.Page4.NextPage.MouseButton1Click:Connect(function()
	-- Start packaging the data
	SwapPages(Frames.Page4, Frames.Loading, "rbxassetid://11102397100", true)

	local Members, AllowedPages = {}, {}

	for i, v in ipairs(Frames.Page3.Members.Members:GetChildren()) do
		if not v:IsA("Frame") then continue end
		if v:GetAttribute('IsTemplate') then continue end

		if v:GetAttribute('TemplateType') == 'GroupTemplate' then
			table.insert(Members, {
				['MemberType'] = "Group",
				['ID'] = v.TextInput.Text or 0,
			})
		else
			table.insert(Members, {
				['MemberType'] = "User",
				['ID'] = v.TextInput.Text or 0,
			})
		end
	end

	for i, v in ipairs(Frames.Page4.Apps.Apps:GetChildren()) do
		if not v:IsA("Frame") then continue end
		if v.Name == "Template" then continue end
		if not v:GetAttribute("Showing") then continue end

		table.insert(AllowedPages, {
			['Name'] = v:GetAttribute('TechName'),
			['DisplayName'] = v.AppName.Text or "Failed to fetch",
			['Icon'] = v.Icon.Image or "rbxassetid://0"
		})
	end

	FinalData = {
		['Name'] = game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer(Frames.Page2.TextInput.Text)[2],
		['Protected'] = false, -- may be configurable soon
		['Members'] = Members,
		['PagesCode'] = '/',
		['AllowedPages'] = AllowedPages
	}
	
	local Result = game.ReplicatedStorage.AdministerRemotes.NewRank:InvokeServer(FinalData)
	if Result["Success"] then
		SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://13531414092")
	else
		print('failed, fill out data TODO')
		print(Result)
		SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://13531414092")
		Frames.Page5.Header.Text = "Oops, something happened that shouldn't have."
		Frames.Page5.Body.Text = `Something unexpected happened, and the server code didn't handle it right. This is either a misconfiguration or Administer issue. Do your part and report it if it's not you. Check the error information below:\n\n`..``
	end
end)

Frames.Page5.NextPage.MouseButton1Click:Connect(function()
	Frames.Visible = false
	SwapPages(Frames.Page5, Frames.Page1)
end)