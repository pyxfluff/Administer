--// Administer 
--// (pyxfluff + FloofyPlasma) 2024 - 2025
-- stylua: ignore start

local Variables = {}

local Typing = require(script.Parent.Types)
local Root   = script.Parent.Parent.Parent

local Config = require(script.Parent.Configuration)

--// The items below this may be edited if you wish and it will not compromise Administer's security or functionality.
Variables.Config                     = require(script.Parent.Configuration)
Variables.RemotesPath                = game.ReplicatedStorage
Variables.EnableFreeAdmin            = false

Variables.DefaultAppServer           = "https://adm_unstable.notpyx.me"
Variables.ProxyURL                   = "https://rblx.notpyx.me"
Variables.Locales                    = script.Parent.Locales

Variables.Services = setmetatable({}, {
    __index = function(self, Service)
        self[Service] = game:GetService(Service)
        return self[Service]
    end,
})

--// The scheme is `app\widget-title`, anything will work here
--// as long as it exists.
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
	Settings   = Variables.Services.DataStoreService:GetDataStore("Administer_Settings")
}

Variables.Notification = {
    Ding = "",
    Error = ""
}

--// WARNING: EVERYTHING BELOW THIS LINE IS AUTOMATED AND SHOULD NOT BE EDITED.
--// DOING SO WILL BREAK YOUR GAME OR ADMINISTER.
--// IF YOU WANT TO HARDCODE ADMINS, SEE ./Configuration
Variables.DidBootstrap               = false
Variables.WaitForBootstrap           = false
Variables.LogJoins                   = true
Variables.PanelFound                 = Root.Resources:FindFirstChild("AdministerMainPanel")
Variables.Branch                     = nil
Variables.DisableBootstrapProtection = true
Variables.IsFirstBoot                = false

--// Note to self: when adding these, remember to type in the Types file!!
Variables.ModuleSensitivity = {
    AdminRunner  = 3,
    Apps         = 3,
    Utilities    = 2, --// This one is so general purpose it's just safest to mark it as mild
    HTTPRunner   = 2,
    Settings     = 1,
    Frontend     = 1,
    Debugging    = 1
}

-- stylua: ignore end

Variables.Admins = {
	InGame = {},

	OutOfGame = {},

	TotalRunningCount = 0,
}

Variables.InitClock = {
	RealInit = os.clock(),
	TempInit = os.clock(),
}

Variables.DefaultRank = {
	["RankID"] = 0,
	["Name"] = (require(Variables.Locales[Config.Settings.Interface.Language.Value.Default]) :: any)["admin.RankDefault"],
	["Protected"] = false,

	["Members"] = {},
	["Apps"] = {},

	["Modified"] = os.time(),
	["Modifications"] = {},

	["CreatorID"] = 0,
	["AdmRankVersion"] = 2,
}

Variables.DefaultRankData = {
	Count = 1,
	Names = {},
	GroupAdminIDs = {},
	AdminIDs = {},
}

Variables.CurrentBranch = { Name = "" }
Variables.Branches = {
	Internal = {
		ImageID = "rbxassetid://18841275783",
		Name = "Administer Internal",
		IsActive = true,
	},

    QualityAssurance = {
		ImageID = "rbxassetid://76508533583525",
		Name = "Administer QA Release",
		IsActive = false,
	},

    Fresh = {
		ImageID = "rbxassetid://18224047110",
		Name = "Administer (git)",
		IsActive = false,
	},

    Beta = {
		ImageID = "rbxassetid://18770010888",
		Name = "Administer Public Beta",
		IsActive = false,
	},

    Production = {
		ImageID = "rbxassetid://18224047110",
		Name = "Administer",
		IsActive = false,
	},
}

Variables.Panel = {
	Path = Root.Resources.AdministerMainPanel,
}

Variables.CachedLocales = {
	[133017837] = "es-es",
}

Variables.AppServers = Variables.DataStores.AppDB:GetAsync("AppServerList") or {}

Variables.Panel.Spawn = function(Rank, Player)
	local NewPanel = Variables.Panel.Path:Clone()

	NewPanel:SetAttribute("_AdminRank", Rank.Name)
	NewPanel:SetAttribute(
		"_HomeWidgets",
		Variables.Services.HttpService:JSONEncode(
			Variables.DataStores.HomeDS:GetAsync(Player.UserId) or Variables.BaseHomeInfo
		)
	)
	NewPanel:SetAttribute(
		"_InstalledApps",
		Variables.Services.HttpService:JSONEncode((require(script.Parent.Parent.Modules.AppAPI).AllApps) :: any)
	)
	NewPanel:SetAttribute("_CurrentBranch", Variables.Services.HttpService:JSONEncode(Variables.CurrentBranch))

	return NewPanel
end

Variables.Init = function()
	local RF = Instance.new("Folder", Variables.RemotesPath)
	RF.Name = "Administer"
	Variables.RemotesPath = RF

	for Branch, Object in Variables.Branches :: { Typing.AdmBranch } do
		Object["BranchName"] = Branch

		if Object["IsActive"] then Variables.CurrentBranch = Object end
	end

	Variables.InitTimestamp = {
		Time = os.time(),
		Tick = tick(),
	}
end

return Variables
