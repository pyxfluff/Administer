--// pyxfluff 2024

local AR = { Ranks = {} }

--// Dependencies
local Var = require(script.Parent.Parent.Core.Variables)
local Util = require(script.Parent.Utilities)
local Config = require(script.Parent.Parent.Core.Configuration)

--// Locals
local LastAdminResult

function AR.Bootstrap(
	Player:        Player,
	AdminRankID:   number
): ()
	local Rank = Var.DataStores.Var.DataStores.Var.DataStores.AdminsDS:GetAsync(`_Rank{AdminRankID}`)
	local NewPanel = Var.Panel.Spawn(Rank, Player)
	local AllowedPages = {}

	table.insert(Var.Admins.InGame, Player)
	Var.Admins.TotalRunningCount += 1

	for i, v in Rank["AllowedPages"] do
		AllowedPages[v["Name"]] = {
			["Name"] = v["DisplayName"], 
			["ButtonName"] = v["Name"]
		}
	end

	if Rank.PagesCode ~= "*" then
		for _, v in NewPanel.Main.Apps.MainFrame:GetChildren() do
			if not v:IsA("CanvasGroup") then continue end
			if table.find({'Home', 'Template'}, v.Name) then continue end --// Always allowed

			pcall(function()
				xpcall(function()
					if AllowedPages[v.Name] == nil then
						Util.Logging.Print("Not allowed by rank (i think)")

						for i, Page in NewPanel.Main:GetChildren() do
							if Page:GetAttribute("LinkID") == v:GetAttribute("LinkID") then
								Page:Destroy()
							end
						end

						v:Destroy()
					end
				end, function(r)
					Util.Logging.Warn(`Failed performing permission checks on {v.Name}! `)
				end)
			end)
		end
	end

	Util.NewNotification(
		Player, 
		`{Config.Name} loaded! You're a{string.split(string.lower(Rank.RankName), "a")[1] == "" and "n" or ""} {Rank.RankName}. {
		`Press {Util.GetSetting("RequireShift") and "Shift + " or ""}{Util.GetSetting("PanelKeybind")} to enter the panel.`
		}`,
		"Welcome to Administer!", 
		"rbxassetid://16105499426", 15,	nil, {}
	)
end

function AR.PlayerAdded(
	Player:        Player,
	ForceAdmin:    boolean
): {boolean | string}
	LastAdminResult = Util.IsAdmin(Util, Player)
	if Var.LogJoins then
		table.insert(Var.AdminsBootstrapped)
	end

	if Var.WaitForBootstrap then
		repeat task.wait(.1) until Var.DidBootstrap
	end

	task.spawn(function()
		if LastAdminResult.IsAdmin then
			AR.Bootstrap(
				Player,
				LastAdminResult["RankID"]
			)
		elseif (Var.Services.RunService:IsStudio() and Util.GetSetting("SandboxMode")) or Var.EnableFreeAdmin then
			AR.Bootstrap(
				Player,
				1
			)
		end
	end)

	return {true, "Done"}
end

function AR.Removing(
	Player: Player
): ()
	if table.find(Var.Admins.InGame, Player) ~= nil then
		table.remove(Var.Admins.InGame, table.find(Var.Admins.InGame, Player))
		table.insert(Var.Admins.OutOfGame, Player)
	end
end

function AR.Ranks.New(Name, Protected, Members, PagesCode, AllowedPages, Why, ActingUser, RankID, IsEdit)
	if Var.DataStores.Var.DataStores.AdminsDS:GetAsync("HasMigratedToV2") == false then
		return {false, "Sorry, but you may not create new ranks before updating to Ranks V2."}	
	end

	xpcall(function()
		local ShouldStep = false
		local OldRankData = nil
		local Info = Var.DataStores.Var.DataStores.AdminsDS:GetAsync("CurrentRanks") or {
			Count = 1,
			Names = {},
			GroupAdminIDs = {},
			AdminIDs = {}
		}

		if not RankID or RankID == 0 then
			RankID = Info.Count
			ShouldStep = true
		end

		if IsEdit then
			OldRankData = Var.DataStores.Var.DataStores.AdminsDS:GetAsync(`_Rank{RankID}`)
		end

		Var.DataStores.Var.DataStores.AdminsDS:SetAsync(`_Rank{RankID}`, {
			["RankID"] = RankID,
			["RankName"] = Name,
			["Protected"] = Protected,

			["Members"] = Members,
			["PagesCode"] = PagesCode,
			["AllowedPages"] = AllowedPages,

			["ModifiedPretty"] = os.date("%d/%m/%y at %I:%M %p"),
			["ModifiedUnix"] = os.time(),
			["Reason"] = Why,

			["Modifications"] = {
				{
					["Reason"] = "Created this rank.",
					["ActingAdmin"] = ActingUser,
					["Actions"] = {"created this rank"}
				}
			},

			["CreatorID"] = ActingUser,
			["AdmRankVersion"] = 1
		})

		for i, v in Members do
			if v.MemberType == "User" then
				if Info.AdminIDs == nil then
					Info.AdminIDs = {}	
				end

				Info.AdminIDs[v.ID] = {
					UserID = v.ID,
					AdminRankID = RankID,
					AdminRankName = Name
				}
			else
				Info.GroupAdminIDs[`{v.ID}_{math.random(1,50000)}`] = { --// Identify groups differently because we may have the same group multiple times
					GroupID = v.ID,
					RequireRank = v.GroupRank ~= 0,
					RankNumber = v.GroupRank,
					AdminRankID = RankID,
					AdminRankName = Name
				}
			end
		end

		if ShouldStep then
			Info.Count = RankID + 1
			Info.Names = Info.Names or {}
			table.insert(Info.Names, Name)
		end

		Var.DataStores.Var.DataStores.AdminsDS:SetAsync("CurrentRanks", {
			Count = Info.Count,
			Names = Info.Names,
			GroupAdminIDs = Info.GroupAdminIDs,
			AdminIDs = Info.AdminIDs
		})
	end, function(E)
		Util.Logging.Warn(`Failed to create a new admin rank! {E}`)
		return {false, E}
	end)
	
	xpcall(function()
		Var.Services.MessagingService:PublishAsync("Administer", {["Action"] = "ForceAdminCheck"})
	end, function(e)
		return {false, `We made the rank fine, but failed to publish the event to tell other servers to check. Please try freeing up some MessagingService slots (disabling other apps, removing other admin systems, ...). {e}`}
	end)
	
	return {true, `Successfully made a rank!`}
end

function AR.Ranks.GetAll()
	local Count = Var.DataStores.AdminsDS:GetAsync("CurrentRanks")
	local Ranks = {}
	local Polls = 0

	--// Load in parallel
	for i = 1, tonumber(Count["Count"]) do
		task.spawn(function()
			Ranks[i] = Var.DataStores.AdminsDS:GetAsync("_Rank"..i)
		end)
	end

	repeat 
		Polls += 1
		task.wait(.05) 
		-- print("RCHK", #Ranks / Count["Count"], Ranks, Count, Polls) 
	until #Ranks == Count["Count"] or Polls == 7

	if Polls == 7 then
		Util.Logging.Warn(`Only managed to load {#Ranks / Count["Count"]}% of ranks, possibly corrupt rank exists!`)
	end

	return Ranks
end


return AR