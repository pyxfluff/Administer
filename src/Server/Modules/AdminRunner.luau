--// Administer
--// (pyxfluff + FloofyPlasma) 2024 - 2025

local AR = { Ranks = {} }

--// Dependencies
local Root = script.Parent
local Config = require(Root.Parent.Core.Configuration)
local Types = require(Root.Parent.Core.Types)
local Util = require(Root.Utilities)
local Var = require(Root.Parent.Core.Variables)

type Response = Types.Response

--// Locals
local LastAdminResult

function AR.Bootstrap(Player: Player, AdminRankID: number): ()
	local Rank = Var.DataStores.AdminsDS:GetAsync(`_Rank{AdminRankID}`)
	local NewPanel = Var.Panel.Spawn(Rank, Player)
	local AllowedPages = {}

	table.insert(Var.Admins.InGame, Player)
	Var.Admins.TotalRunningCount += 1

	if Rank.Apps["SuperAdmin"] == nil then
		for ID, Object in Rank["Apps"]["PageIDs"] do
			AllowedPages[ID] = {
				["Name"] = Object.DisplayName,
				["ButtonName"] = ID,
			}
		end

		for _, v in NewPanel.Main.Apps.MainFrame:GetChildren() do
			if not v:IsA("CanvasGroup") then continue end
			if table.find({ "Home", "Template" }, v.Name) then continue end --// Always allowed

			pcall(function()
				xpcall(function()
					if AllowedPages[v.Name] == nil then
						Util.Logging.Print("Not allowed by rank (i think)")

						for i, Page in NewPanel.Main:GetChildren() do
							if Page:GetAttribute("LinkID") == v:GetAttribute("LinkID") then Page:Destroy() end
						end

						v:Destroy()
					end
				end, function(r)
					Util.Logging.Warn(`Failed performing permission checks on {v.Name}! `)
				end)
			end)
		end
	end

	NewPanel.Parent = Player.PlayerGui

	Util.NewNotification(
		Player :: Player,
		string.format(Util.t(Player, "onboarding.Welcome"), Config.Name, Rank.Name, Util.GetSetting("Keybind")),
		string.format(Util.t(Player, "onboarding.Head"), Config.Name),
		"rbxassetid://16105499426",
		15,
		nil,
		{}
	)
end

function AR.PlayerAdded(Player: Player, ForceAdmin: boolean, IsScan: boolean): Types.Response
	LastAdminResult = Util.IsAdmin(Player)

	Util.Logging.Print("New join:", LastAdminResult)

	if Var.WaitForBootstrap then
		repeat
			task.wait()
		until Var.DidBootstrap
	end

	if IsScan and table.find(Var.Admins.InGame, Player) and not Var.DisableBootstrapProtection then
		return {
			false,
			"This person is already an admin and by default cannot be bootstrapped twice. Change this in the configuration module.",
		}
	end

	task.spawn(function()
		if LastAdminResult.IsAdmin then
			AR.Bootstrap(Player, LastAdminResult["RankID"] :: number)
		elseif
			(Var.Services.RunService:IsStudio() and Util.GetSetting("SandboxMode"))
			or Var.EnableFreeAdmin
			or ForceAdmin
		then
			AR.Bootstrap(Player, 1)
		end
	end)

	return { true, "Done" }
end

function AR.Removing(Player: Player): ()
	if table.find(Var.Admins.InGame, Player) ~= nil then
		table.remove(Var.Admins.InGame, table.find(Var.Admins.InGame, Player))
		table.insert(Var.Admins.OutOfGame, Player)
	end
end

function AR.Scan(ForceAdmin: boolean): ()
	for _, Player: Player in Var.Services.Players:GetPlayers() do
		AR.PlayerAdded(Player, ForceAdmin, true)
	end
end

function AR.Ranks.New(Data: Types.AdminRank): Response
	if Var.DataStores.AdminsDS:GetAsync("HasMigratedToV2") == false then
		return { false, Util.t(nil, "admin.rv2.Migrate") }
	end

	Util.Logging.Print("[-] Making a new admin rank...")
	local Start = os.clock()

	xpcall(function()
		local ShouldStep = false
		local _OldRankData = nil --// TODO: what did this do?
		local NewRank = Var.DefaultRank
		local Info = Var.DataStores.AdminsDS:GetAsync("CurrentRanks") or Var.DefaultRankData

		if not Data.RankID or Data.RankID == 0 then
			Data.RankID = Info.Count
			ShouldStep = true
		end

		if Data.IsEdit then _OldRankData = Var.DataStores.AdminsDS:GetAsync(`_Rank{Data.RankID}`) end

		NewRank.RankID = Data.RankID :: number
		NewRank.Name = Data.Name
		NewRank.Protected = Data.Protected
		NewRank.Modified = os.time()
		NewRank.CreatorID = Data.ActingUser

		NewRank.Members = Data.Members
		NewRank.Apps = Data.AllowedApps

		table.insert(NewRank.Modifications, {
			Reason = Util.t(nil, "admin.rank.created"),
			ActingAdmin = Data.ActingUser,
			Actions = { "created this rank" },
		})

		Var.DataStores.AdminsDS:SetAsync(`_Rank{Data.RankID}`, NewRank)

		for i, v in Data.Members do
			if v.MemberType == "User" then
				if Info.AdminIDs == nil then Info.AdminIDs = {} end

				Info.AdminIDs[v.ID] = {
					UserID = v.ID,
					AdminRankID = Data.RankID,
					AdminRankName = Data.Name,
				}
			else
				Info.GroupAdminIDs[`{v.ID}_{Var.Services.HttpService:GenerateGUID(false)}`] =
					{ --// Identify groups differently because we may have the same group multiple times
						GroupID = v.ID,
						RequireRank = v.GroupRank ~= 0,
						RankNumber = v.GroupRank,
						AdminRankID = Data.RankID,
						AdminRankName = Data.Name,
					}
			end
		end

		if ShouldStep then
			Info.Count = (Data.RankID :: number) + 1
			Info.Names = Info.Names or {}
			table.insert(Info.Names, Data.Name)
		end

		Var.DataStores.AdminsDS:SetAsync("CurrentRanks", {
			Count = Info.Count,
			Names = Info.Names,
			GroupAdminIDs = Info.GroupAdminIDs,
			AdminIDs = Info.AdminIDs,
		})
	end, function(E)
		Util.Logging.Warn(`Failed to create a new admin rank! {E}`)
		return { false, E }
	end)

	xpcall(function()
		Var.Services.MessagingService:PublishAsync("Administer", { ["Action"] = "ForceAdminCheck" })
	end, function(e): Types.Response
		Util.Logging.Warn(`[X] Failed to publish MessagingService action: ForceAdminCheck! {e}`)
		return {
			false,
			Util.t(nil, "admin.rankcreate.MessagingServiceFailed"),
		}
	end)

	Util.Logging.Print(`[✓] Done in {os.clock() - Start}`)
	return { true, `Success in {os.clock() - Start}s!` }
end

function AR.Ranks.GetAll()
	local Current: Types.CurrentRanks = Var.DataStores.AdminsDS:GetAsync("CurrentRanks")
	local Ranks = {}
	local Polls = 0

	--// Load in parallel
	for i = 1, tonumber(Current.Count) :: number do
		task.spawn(function()
			Ranks[i] = Var.DataStores.AdminsDS:GetAsync("_Rank" .. i)
		end)
	end

	repeat
		Polls += 1
		task.wait(0.05)
		Util.Logging.Debug("RANK CHECK", #Ranks / Current["Count"], Ranks, Current, Polls)
	until #Ranks == Current.Count or Polls == 7

	if Polls == 7 then
		Util.Logging.Warn(`Only managed to load {#Ranks / Current.Count}% of ranks, possibly corrupt rank exists!`)
	end

	return Ranks
end

return AR
