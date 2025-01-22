--// Administer
--// (pyxfluff + FloofyPlasma) 2024 - 2025

export type IconPack = {
	Meta: {
		Name: string,
		Author: string,
		Type: "full-set" | "partial" | "tweaks",
		AllowThemeDependencies: boolean,
	},

	Logos: { Icon },
}

type Icon = {}
type AppID = string

export type Response = { boolean | string }

export type CurrentRanks = {
	Count: number,
	Names: { string },
	GroupAdminIDs: { number },
	AdminIDs: { number },
}

export type AdminRank = {
	Name: string,
	Protected: boolean,
	Members: {
		{
			ID: number,
			MemberType: "User" | "Group",
			GroupRank: number?,
		}
	},

	AllowedApps: {
		SuperAdmin: boolean?,

		[AppID]: {
			Added: number,
			PageIDs: { string },
			CommandIDs: { string },
		},
	},

	CreationReason: string,
	ActingUser: number,

	RankID: number?,
	IsEdit: boolean?,
}

export type AdminCheck = {
	IsAdmin: boolean,
	RankID: number,

	--// nice to have stuff
	Reason: string?,
	RankName: string?,
}

export type ActionObject = {
	Text: string,
	Icon: string | Icon,
	OnClick: () -> (),
}

export type AdmBranch = {
	ImageID: string,
	Name: string,
	IsActive: boolean,
}

type Version = string
type Branch = "LIVE" | "BETA" | "CANARY" | "INTERNAL" | "GIT"
type AdministerDistributors = { "git" | "roblox" | "pesde" | "aos" }
type BranchList = { "LIVE" | "BETA" | "CANARY" | "INTERNAL" | "GIT" }

export type PythonVersionInfo = {
	provided_information: {
		branch: BranchList,
		version: string,
		outdated: boolean,

		can_update_to: {
			branch: Branch,
			name: string,
		},

		featureset: {
			apps: {
				can_download: boolean,
				can_install_new: boolean,
				can_access_marketplace: boolean,
			},

			administer: {
				can_auto_update: boolean,
				can_report_version: boolean,
			},

			misc: {
				supports_ranks: { string },
			},
		},
	},

	versions: {
		[Version]: {
			latest: boolean,
			available_to: BranchList,
			distributed_via: AdministerDistributors,
			released: number,
			hash: string,

			logs: { string },
		},
	},
}

export type HomeWidgetInfo = {
	_version: string,
	Widget1: string,
	Widget2: string,
	TextWidgets: { string },
}

export type SettingResponse = boolean | string | number | EnumItem | { Value: EnumItem, String: string }

return {}
