--// pyxfluff 2025

local Modules = script.Parent
local Libs = script.Parent.Parent.Libraries

local Frontend = require(Modules.Frontend)
local Utilities = require(Modules.Utilities)
local Var = require(Modules.Variables)

local Admins = {}
local Connections: { RBXScriptConnection } = {}

local RanksFrame = Var.MainFrame.Configuration.Admins.Container.Ranks.Content

--// TODO: OPTIMIZE THIS
function Admins.Load(): ()
	for _, Item in RanksFrame:GetChildren() do
		if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
	end

	for _, Item in Var.MainFrame.Configuration.Admins.Container.Admins.Content:GetChildren() do
		if Item:IsA("Frame") and Item.Name ~= "Template" then Item:Destroy() end
	end

	for _, Connection in Connections do
		Connection:Disconnect()
	end

	Connections = {}

	local Shimmer1 = Libs.Shime.new(Var.MainFrame.Configuration.Admins.Container.Ranks)
	local Shimmer2 = Libs.Shime.new(Var.MainFrame.Configuration.Admins.Container.Admins)

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

				local _, GroupInfo = pcall(function()
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

					local _, GroupInfo = pcall(function()
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
		end
	end

	Shimmer1:Pause()
	Shimmer2:Pause()
	Shimmer1:GetFrame():Destroy()
	Shimmer2:GetFrame():Destroy()
end

function Admins.RunCreatorApp()
	--// TODO
	local TweenService = game:GetService("TweenService")
	local Page = 1
	local CanGoBack = true
	local CanProgress = true
	local Env = require(script.Parent.AdminHelperEnv)

	local function SwapPages(Page1, Page2, NewIcon, Spin, PageNumber)
		if type(Spin) == "number" then PageNumber = Spin end

		Page = PageNumber
		local TTC = 0.4

		for _, descendant in Page1:GetDescendants() do
			if descendant:IsA("ImageLabel") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1,
					BackgroundTransparency = 1,
				}):Play()
			elseif descendant:IsA("GuiObject") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
				}):Play()
			elseif descendant:IsA("TextLabel") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 1,
					BackgroundTransparency = 1,
				}):Play()
			elseif descendant:IsA("Frame") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1,
				}):Play()
			end
		end
		local Tweem = TweenService:Create(
			Page1,
			TweenInfo.new(TTC * 1.3, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(-0.5, 0, 0, 0) }
		)

		Tweem:Play()
		TweenService:Create(
			script.Parent.SideDecor.ImageLabel,
			TweenInfo.new(TTC, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(0, 0, 0.5, 0), ImageTransparency = 1 }
		):Play()
		TweenService:Create(
			script.Parent.SideDecor.AdmSpinner,
			TweenInfo.new(TTC, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(0, 0, 0.5, 0), GroupTransparency = 1 }
		):Play()

		Tweem.Completed:Wait()
		for _, descendant in Page2:GetDescendants() do
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

		Page2.Position = UDim2.new(0.3, 0, 0, 0)
		script.Parent.SideDecor.ImageLabel.Position = UDim2.new(0.8, 0, 0.5, 0)
		script.Parent.SideDecor.AdmSpinner.Position = UDim2.new(0.8, 0, 0.5, 0)

		script.Parent.SideDecor.AdmSpinner.Visible = Spin
		script.Parent.SideDecor.ImageLabel.Image = NewIcon
		script.Parent.SideDecor.ImageLabel.Visible = not Spin

		Page2.Visible = true
		Page1.Visible = false

		for _, descendant in Page2:GetDescendants() do
			if descendant:IsA("ImageLabel") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0,
				}):Play()
			--elseif descendant:IsA("GuiObject") then
			--TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			--	Transparency = 0
			--}):Play()
			elseif descendant:IsA("TextLabel") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0,
				}):Play()
			elseif descendant:IsA("TextBox") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0,
					BackgroundTransparency = 0,
				}):Play()
			elseif descendant:IsA("TextButton") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0,
				}):Play()
				if descendant.Name == "NextPage" then
					TweenService
						:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0,
						})
						:Play()
				end
			elseif descendant:IsA("Frame") and not descendant:GetAttribute("hide") then
				TweenService:Create(descendant, TweenInfo.new(TTC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0,
				}):Play()
			end
		end

		local ET = TweenService:Create(
			Page2,
			TweenInfo.new(TTC * 1.2, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(0, 0, 0, 0) }
		)
		TweenService:Create(
			script.Parent.SideDecor.ImageLabel,
			TweenInfo.new(TTC, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(0.5, 0, 0.5, 0), ImageTransparency = 0 }
		):Play()
		TweenService:Create(
			script.Parent.SideDecor.AdmSpinner,
			TweenInfo.new(TTC, Enum.EasingStyle.Cubic),
			{ Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 0 }
		):Play()

		ET:Play()

		local Dots = script.Parent.BottomData.Controls.Dots

		for i, Dot in Dots:GetChildren() do
			if not Dot:IsA("Frame") then continue end
			Dot.UIStroke.Thickness = 0
		end

		Dots[`Dot{PageNumber}`].UIStroke.Thickness = 2
		script.Parent.BottomData.StepLabel.Text = `Step {Page}/5`

		ET.Completed:Wait() --// stop the animation from being too quick
	end

	script.Parent.BottomData.Controls.ALast.MouseButton1Click:Connect(function()
		if not CanGoBack then return end

		Page -= 1
		SwapPages(script.Parent[`Page{Page + 1}`], script.Parent[`Page{Page}`], "rbxassetid://14147040290", false, Page)
	end)

	--// buttons
	local Frames = script.Parent
	local ConnectionsTable
	local FinalData = {}

	Frames.Page1.NextPage.MouseButton1Click:Connect(function()
		-- Verify the filtering service is online
		SwapPages(Frames.Page1, Frames.Loading, "rbxassetid://11102397100", true, 1)

		Env = require(script.Parent.AdminHelperEnv) --// Re-fetch config just incase it changed

		if Env.EditModeIsProtected then
			SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://14147040290", false, 5)

			Frames.Page5.Header.Text = "Access Denied"
			Frames.Page5.Body.Text =
				"Sorry, but this rank is protected and may not be edited. Please contact whoever installed Administer."
			return
		end

		local Success, FilterResult = pcall(function()
			return game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer("test string")
		end)

		if Success and FilterResult[1] then
			SwapPages(Frames.Loading, Frames.Page2, "rbxassetid://15084609272", false, 2)

			ConnectionsTable = Frames.Page2.TextInput:GetPropertyChangedSignal("Text"):Connect(function()
				Frames.Page2.PreviewText.Text =
					`Preview: {game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer(
						Frames.Page2.TextInput.Text
					)[2]}`
			end)
		else
			SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://14147040290", false, 5)

			Frames.Page5.Header.Text = "Oops! That's not meant to happen."
			if FilterResult[2] then
				Frames.Page5.Body.Text = "Failed to connect to Roblox's filtering service. This likely isn't an issue with your game, try again later.\n\n"
						.. FilterResult[2]
					or "The server did not send an error."
			else
				Frames.Page5.Body.Text = "Failed to call the remote to filter. Did you install Administer wrong?\n\n"
						.. FilterResult
					or "The server did not send an error."
			end
		end
	end)

	Frames.Page2.NextPage.MouseButton1Click:Connect(function()
		SwapPages(Frames.Page2, Frames.Loading, "rbxassetid://11102397100", true, 2)

		ConnectionsTable:Disconnect()

		for i, v in Frames.Page3.Members.Members:GetChildren() do
			if not v:GetAttribute("IsTemplate") and v:IsA("Frame") then v:Destroy() end
		end

		local function NewGroupCard(PresetID, PresetRank)
			local Clone = Frames.Page3.Members.Members.GroupTemplate:Clone()
			local Checking = false

			Clone.Parent = Frames.Page3.Members.Members
			Clone.Visible = true
			Clone:SetAttribute("IsTemplate", false)
			Clone:SetAttribute("TemplateType", "Group")

			local CheckTask = function()
				Checking = true
				local Success, Info = pcall(function()
					return game:GetService("GroupService"):GetGroupInfoAsync(tonumber(Clone.TextInput.Text))
				end)

				if Success then
					Clone._Name.Text = `{Info["Name"]}`
					Clone.Image.Image = Info["EmblemUrl"]
				else
					Clone._Name.Text = `Group not found!`
					Clone.Image.Image = "rbxassetid://15105863258"
				end

				Checking = false
			end

			ConnectionsTable["Check" .. math.random(1, 500)] = Clone.TextInput.FocusLost:Connect(function()
				if Checking then
					task.cancel(CheckTask) --// too quick, stop the old one...
					task.spawn(CheckTask)
				else
					Checking = true
					task.spawn(CheckTask)
				end
			end)
			ConnectionsTable["Close" .. math.random(1, 500)] = Clone.Delete.MouseButton1Click:Connect(function()
				Clone:Destroy()
			end)

			Clone.TextInput.Text = PresetID or ""
			Clone.GroupRankInput.Text = PresetRank or ""

			CheckTask()
		end

		local function NewUserCard(PresetID)
			local Clone = Frames.Page3.Members.Members.PlayerTemplate:Clone()

			Clone.Parent = Frames.Page3.Members.Members
			Clone.Visible = true
			Clone:SetAttribute("IsTemplate", false)
			Clone:SetAttribute("TemplateType", "User")

			local function CheckTask()
				local Success, Info = pcall(function()
					return {
						game.Players:GetNameFromUserIdAsync(Clone.TextInput.Text),
						game.Players:GetUserThumbnailAsync(
							Clone.TextInput.Text,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size100x100
						),
					}
				end)

				if Success then
					Clone._Name.Text = `{Info[1]}`
					Clone.Image.Image = Info[2]
				else
					Clone._Name.Text = `Not found`
					Clone.Image.Image = "rbxassetid://15105863258"
				end
			end

			ConnectionsTable["Check" .. math.random(1, 500)] = Clone.TextInput.FocusLost:Connect(function()
				CheckTask()
			end)
			ConnectionsTable["Close" .. math.random(1, 500)] = Clone.Delete.MouseButton1Click:Connect(function()
				Clone:Destroy()
			end)

			Clone.TextInput.Text = PresetID or ""
			CheckTask()
		end

		ConnectionsTable = {
			Frames.Page3.AddPane.AddGroup.Click.MouseButton1Click:Connect(function()
				NewGroupCard()
			end),

			Frames.Page3.AddPane.AddUser.Click.MouseButton1Click:Connect(function()
				NewUserCard()
			end),
		}

		for i, User in Env.EditModeMembers do
			if User.MemberType == "User" then
				NewUserCard(User.ID)
			else
				NewGroupCard(User.ID, User.GroupRank)
			end
		end

		SwapPages(Frames.Loading, Frames.Page3, "rbxassetid://15082548595", false, 3)

		print(Env)
	end)

	Frames.Page3.NextPage.MouseButton1Click:Connect(function()
		SwapPages(Frames.Page3, Frames.Loading, "rbxassetid://11102397100", true, 3)

		for i, v in ConnectionsTable do
			v:Disconnect()
		end

		for i, Child in Frames.Page4.Apps.Apps:GetChildren() do
			if Child.Name ~= "Template" and Child:IsA("Frame") then Child:Destroy() end
		end

		local function NewAppCard(AppName, Icon, TechName, DescText)
			local Template = Frames.Page4.Apps.Apps.Template:Clone()

			Template.Parent = Frames.Page4.Apps.Apps
			Template.AppName.Text = AppName
			Template.Icon.Image = Icon
			Template.AppDesc.Text = DescText
			Template.Name = AppName
			Template.StatusImage.Image = "rbxassetid://15106359967"
			Template.Status.Text = "Enabled"
			Template.Visible = true

			Template:SetAttribute("TechName", TechName)

			ConnectionsTable[AppName] = Template.Toggle.MouseButton1Click:Connect(function()
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

		for i, v in script.Parent.Parent.Parent.Parent.Apps.MainFrame:GetChildren() do
			if not table.find({ "AHome", "Template", "UIGridLayout" }, v.Name) then
				NewAppCard(v.Title.Text, v.Icon.Image, v.Name, v.Desc.Text)
			end
		end

		for i, App in Env.EditModeApps do
			if Frames.Page4.Apps.Apps:FindFirstChild(App.DisplayName) then continue end

			NewAppCard(
				App.DisplayName,
				App.Icon,
				App.Name,
				"You don't have the permissions to access this app, so we don't know anything else about it."
			)
		end

		SwapPages(Frames.Loading, Frames.Page4, "rbxassetid://14865439768", false, 4)
	end)

	Frames.Page4.NextPage.MouseButton1Click:Connect(function()
		CanGoBack = false
		-- Start packaging the data
		SwapPages(Frames.Page4, Frames.Loading, "rbxassetid://11102397100", true, 4)

		local Members, AllowedPages = {}, {}

		for i, v in Frames.Page3.Members.Members:GetChildren() do
			if not v:IsA("Frame") then continue end
			if v:GetAttribute("IsTemplate") then continue end

			if v:GetAttribute("TemplateType") == "Group" then
				table.insert(Members, {
					["MemberType"] = "Group",
					["ID"] = v.TextInput.Text or 0,
					["GroupRank"] = v.GroupRankInput.Text or 0,
				})
			else
				table.insert(Members, {
					["MemberType"] = "User",
					["ID"] = v.TextInput.Text or 0,
				})
			end
		end

		for i, v in Frames.Page4.Apps.Apps:GetChildren() do
			if not v:IsA("Frame") then continue end
			if v.Name == "Template" then continue end
			if not v:GetAttribute("Showing") then continue end

			table.insert(AllowedPages, {
				["Name"] = v:GetAttribute("TechName"),
				["DisplayName"] = v.AppName.Text or "Failed to fetch",
				["Icon"] = v.Icon.Image or "rbxassetid://0",
			})
		end

		FinalData = {
			["Name"] = game.ReplicatedStorage.AdministerRemotes.FilterString:InvokeServer(Frames.Page2.TextInput.Text)[2],
			["Protected"] = false, -- may be configurable soon
			["Members"] = Members,
			["PagesCode"] = "/",
			["AllowedPages"] = AllowedPages,

			["IsEditing"] = Env.EditMode,
			["EditingRankID"] = Env.EditModeRank,
		}

		local Result = game.ReplicatedStorage.AdministerRemotes.NewRank:InvokeServer(FinalData)
		if Result["Success"] then
			SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://13531414092", false, 5)
		else
			print(Result)
			SwapPages(Frames.Loading, Frames.Page5, "rbxassetid://13531414092", false, 5)
			Frames.Page5.Header.Text = require(script.Parent.AdminHelperEnv).Strings.FinHeaderError
			Frames.Page5.Body.Text =
				string.format(require(script.Parent.AdminHelperEnv).Strings.FinHeaderError, Result["Message"])
		end
	end)

	Frames.Page5.NextPage.MouseButton1Click:Connect(function()
		SwapPages(Frames.Page5, Frames.Page1, "rbxassetid://18151072839", false, 1)
		Frames.BottomData.RankTitle.Text = "Creating a rank"
		CanGoBack = true
		CanProgress = true
	end)

	Frames.BottomData.Controls.Exit.MouseButton1Click:Connect(function()
		if Env.EditMode == true then
			Env.EditMode = false
			Env.EditModeMembers = {}
			Env.EditModeApps = {}
			Env.EditModeName = ""
			Env.EditModeIsProtected = false
			Env.EditModeRank = 0
		end

		task.delay(1, function()
			if Page == 2 then
				SwapPages(Frames.Page2, Frames.Page1, "rbxassetid://18151072839", 1)
			elseif Page == 3 then
				SwapPages(Frames.Page3, Frames.Page1, "rbxassetid://18151072839", 1)
			elseif Page == 4 then
				SwapPages(Frames.Page4, Frames.Page1, "rbxassetid://18151072839", 1)
			elseif Page == 5 then
				SwapPages(Frames.Page5, Frames.Page1, "rbxassetid://18151072839", 1)
			end
		end)
	end)
end

return Admins
