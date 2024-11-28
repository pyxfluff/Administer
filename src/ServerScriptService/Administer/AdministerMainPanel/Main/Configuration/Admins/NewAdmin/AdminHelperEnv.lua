return {
	EditMode = false,
	MaxPeople = 50,
	
	EditModeMembers = {},
	EditModeApps = {},
	EditModeName = "",
	EditModeIsProtected = false,
	EditModeRank = 0,
	
	Strings = {
		["_locale"] = "en_US",
		
		["WelcHeaderNew"] = "Welcome to the Rank Creator",
		["WelcHeaderEdit"] = "Edit %s...",
		
		["WelcBodyNew"] = "The Rank Creator allows you to create new admin ranks and specify their permitted apps and users. New users you add will be given access to Administer instantly even if already in-game.\n\nYou'll only be able to add apps which you personally have access to. Only people with the permission will be able to enabled the option to permit all apps.",
		["WelcBodyEdit"] = "Any changes you make here will be saved to the index and will be logged to the rank to ensure safety of your game.\n\nPlease note the same rules apply with all access. Protected ranks may not be edited directly via UI.",
		
		["FilterStepHead"] = "Name",
		["FilterStepBody"] = "Pick this rank's name. Some apps will display it to the public so it'll be filtered.",
		
		["MembersStepHead"] = "Members",
		["MembersStepBody"] = "Choose who will be able to access Administer under this rank.",
		
		["AppsStepHead"] = "Apps",
		["AppsStepBody"] = "Choose the apps this rank will be able to use. You can't pick any apps you don't have yourself.",
		
		["FinBodyNew"] = "Great! Your rank has been successfully created.\n\Anybody you just added will be given the panel instantly. No need to do anything from here.\n\nIf you would like to edit this rank in the future, come back to this page at any time and click the settings icon next to the name of the rank you just created.",
		["FinBodyEdit"] = "Done! This rank has been edited with your requested changes.\n\nNew members will get the panel and removed ones will lose it. No need to do anything else.",
		
		["FinBodyNewError"] = "Something unexpected happened, and the server code didn't handle it right. This is either a misconfiguration or Administer issue. Do your part and report it if you didn't cause it.\n\n%s",
		["FinBodyEditError"] = "Looks like we can't process your edit right now, sorry about that. This may be due to unexpected permissions or another error. Here's the support error for reporting:\n\n%s",
		
		["FinHeaderError"] = "Oops, that's not right.",
		["FinHeaderSucc"] = "All done!" ,
		
		["NavBarProgress"] = "Step %s/%s",
		["NavBarHeaderNewUnconf"] = "Creating a rank...",
		["NavBarHeaderNewNamed"] = "Creating %s...",
		
		["CannotGoBack"] = "You can't do that right now.",
		
		["RanksV2MigrationNudgeHdr"] = "Rank Deprecation Warning",
		["RanksV2MigrationNudgeBody"] = "Your game is currently using an old version of Administer ranks and it will need to update. By clicking yes, all ranks will be removed and you will need to remake them. This process may only be done in Studio to ensure you don't get locked out of Administer when the process is complete."
	}
}

