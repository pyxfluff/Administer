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

return Admins
