--// pyxfluff 2024
local Variables = {}

Variables.Config = require(script.Parent.Configuration)
Variables.InGameAdmins = {"_AdminBypass"}
Variables.DidBootstrap = false
Variables.AdminsBootstrapped = {}
Variables.WaitForBootstrap = false
Variables.LogJoins = true
Variables.PanelFound = script.Parent.Parent.Resources:FindFirstChild("AdministerMainPanel")
Variables.Branch = nil
Variables.RemotesPath = game.ReplicatedStorage

Variables.Services = {
	ContentProvider      = game:GetService("ContentProvider"),
	MarketplaceService   = game:GetService("MarketplaceService"),
	ReplicatedStorage    = game:GetService("ReplicatedStorage"),
	DataStoreService     = game:GetService("DataStoreService"),
	HttpService          = game:GetService("HttpService"),
	TextService          = game:GetService("TextService"),
	TweenService         = game:GetService("TweenService"),
	GroupService         = game:GetService("GroupService"),
	MessagingService     = game:GetService("MessagingService"),
	Players              = game:GetService("Players"),
	RunService           = game:GetService("RunService")
}

Variables.Admins = {
	InGame = {
		
	},
	OutOfGame = {
		
	},
	
	TotalRunningCount = 0
}

Variables.InitClock = {
	RealInit = tick(),
	TempInit = tick()
}

Variables.Branches = {
	["Interal"] = {
		["ImageID"] = "rbxassetid://18841275783",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer Internal",
		["IsActive"] = false
	},

	["QA"] = {
		["ImageID"] = "rbxassetid://76508533583525",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer QA",
		["IsActive"] = false
	},

	["Canary"] = {
		["ImageID"] = "rbxassetid://18841275783",
		["UpdateLog"] = 18841988915,
		["Name"] = "Administer Canary",
		["IsActive"] = false
	},

	["Beta"] = {
		["ImageID"] = "rbxassetid://18770010888",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer Beta",
		["IsActive"] = false
	},

	["Live"] = {
		["ImageID"] = "rbxassetid://18224047110",
		["UpdateLog"] = 18336751142,
		["Name"] = "Administer",
		["IsActive"] = true
	},
}

Variables.BaseHomeInfo = {
	["_version"] = 1,
	["Widget1"] = "administer\\welcome",
	["Widget2"] = "administer\\unselected",
	["TextWidgets"] = {
		"administer\\version-label",
		"administer\\server-uptime"
	}
}

Variables.DataStores = {
	AdminsDS   = Variables.Services.DataStoreService:GetDataStore("Administer_Admins"),
	HomeDS     = Variables.Services.DataStoreService:GetDataStore("Administer_HomeStore"),
	AppDB      = Variables.Services.DataStoreService:GetDataStore("Administer_AppData"),
}

Variables.Panel = {
	Path = script.Parent.Parent.Resources.AdministerMainPanel,
}

Variables.Panel.Spawn = function(Rank, Player)
	local NewPanel = Variables.Panel.Path:Clone()
	
	NewPanel:SetAttribute("_AdminRank", Rank.RankName)
	NewPanel:SetAttribute("_SandboxModeEnabled", false) --// I think this is useless atm? 
	NewPanel:SetAttribute("_HomeWidgets", Variables.Services.HttpService:JSONEncode(Variables.DataStores.HomeDS:GetAsync(Player.UserId) or Variables.BaseHomeInfo))
	NewPanel:SetAttribute("_InstalledApps", Variables.Services.HttpService:JSONEncode(require(script.AppAPI).AllApps))
	NewPanel:SetAttribute("_CurrentBranch", Variables.Services.HttpService:JSONEncode(Variables.CurrentBranch))
	
	return NewPanel
end

Variables.Init = function()
	local RF = Instance.new("Folder", Variables.RemotesPath)
	Variables.Name = "Administer"
	Variables.RemotesPath = RF
	
	for Branch, Object in Variables.Branches do
		if Object["IsActive"] then
			Variables.CurrentBranch = Object
			Variables.CurrentBranch["BranchName"] = Branch
		end
	end

end

return Variables