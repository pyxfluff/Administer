--// pyxfluff 2024

local AR = {}

--// Dependencies
local Var = require(script.Parent.Parent.Core.Variables)
local Util = require(script.Parent.Utilities)
local Config = require(script.Parent.Parent.Core.Configuration)

--// Locals
local LastAdminResult

function AR.Bootstrap(
	Player:        Player,
	AdminRankID:   number
): ScreenGui
	local Rank = Var.DataStores.AdminsDS:GetAsync(`_Rank{AdminRankID}`)
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

			local Success, Error = pcall(function()
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
): nil
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
): nil
	if table.find(Var.Admins.InGame, Player) ~= nil then
		table.remove(Var.Admins.InGame, table.find(Var.Admins.InGame, Player))
		table.insert(Var.Admins.OutOfGame, Player)
	end
end

return AR