return {
	GetSetting = function()
		
	end,
	
	Print = function()
		
	end,
	
	IsAdmin = function(self, Player: Player)
		if self.GetSetting("SandboxMode") and game:GetService("RunService"):IsStudio() or game.GameId == 3331848462 then
			return true, "Sandbox mode enabled as per settings", 1, "Admin"
		end

		local RanksIndex = game:GetService("DataStoreService"):GetDataStore("Administer_Admins"):GetAsync("CurrentRanks")

		if table.find({}, Player.UserId) ~= nil then
			return true, "Found in AdminIDs override", 1, "Admin"
		else
			for i, v in {} do
				if Player:IsInGroup(v) then
					return true, "Found in AdminIDs override", 1, "Admin"
				end
			end
		end

		xpcall(function()
			if RanksIndex.AdminIDs[Player.UserID] ~= nil then
				return true, "Added from the rank index.", RanksIndex.AdminIDs[Player.UserId].AdminRankID, RanksIndex.AdminIDs[Player.UserId].AdminRankName
			end
		end, function(er)
			--// Safe to ignore an error
			self.Print(er, "probably safe to ignore but idk!")
		end)

		--if RanksData["IsAdmin"] then
		--	return true, "Data based on settings configured by an admin.", RanksData["RankId"], RanksData["RankName"]
		--end

		for ID, Group in RanksIndex.GroupAdminIDs do
			if not Player:IsInGroup(ID) then continue end

			if Group["RequireRank"] then
				return Player:GetRankInGroup(ID) == Group["RankNumber"], "Data based on group rank", Group["AdminRankID"], Group["AdminRankName"]
			else
				return true, "User is in group", Group["AdminRankID"], Group["AdminRankName"]
			end
		end

		return false, "Player was not in override or any rank", 0, "NonAdmin"
	end,
}