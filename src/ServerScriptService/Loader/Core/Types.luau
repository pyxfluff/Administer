--// pyxfluff 2024

export type IconPack = {
    Meta: {
        Name: string,
        Author: string,
        Type: "full-set" | "partial" | "tweaks",
        AllowThemeDependencies: boolean
    },

    Logos: {
        ["administer-blue"]: string --// Really the only one we require here
    }
}

type Icon = {}

export type Response = {boolean | string}

export type CurrentRanks = {
    Count: number,
    Names: {string},
    GroupAdminIDs: {number},
    AdminIDs: {number}
}

export type AdminRank = {
	Name: string, 
	Protected: boolean, 
	Members: {
		{
			ID: number,
			MemberType: "User" | "Group",
			GroupRank: number?
		}
	}, 
	PagesCode: string, --// TODO: REMOVE
	AllowedApps: {
		SuperAdmin: boolean?,

		["Class"]: { 
			PageLinkID: string,
			Commands: {string}?
		}		
	}, 
	CreationReason: string, 
	ActingUser: number, 

	RankID: number?, 
	IsEdit: boolean?
}

export type AdminCheck = {
    IsAdmin: boolean,
    RankID: number, 

    --// nice to have stuff
    Reason: string?, 
    RankName: string?
}

export type ActionObject = {
    Text: string,
    Icon: string | Icon,
    OnClick: () -> ()
}

return {}
