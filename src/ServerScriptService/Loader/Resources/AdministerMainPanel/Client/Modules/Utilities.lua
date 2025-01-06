local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdministerRemotes = ReplicatedStorage:WaitForChild("AdministerRemotes", 10)
local RequestSettingsRemote = AdministerRemotes:WaitForChild("SettingsRemote", 10):WaitForChild("RequestSettings", 10)
local Settings = RequestSettingsRemote:InvokeServer()

local Utilities = {
	Logging = {}
}

function Utilities.GetSetting(Setting: string): (string <Setting | NotFound> | boolean | nil)
	local SettingModule = Settings
	
	if SettingModule == {false} then --// future proof
		error("[Administer] [fault]: Oops, your settings did not authenticate properly. This is probably a bug with the ranking system. Please provide a detailed error report to the Administer team.")
	end
	
	--// TODO (FloofyPlasma): Find a better way to handle this...
	for _, v in SettingModule do
		local Success, Result = pcall(function() 
			if v["Name"] == Setting then
				return v["Value"]
			else
				return "CONT" --// send continue signal
			end	
		end)
		
		if not Success then
			return `Corrupted setting (No "Name") .. {Result}`
		elseif Result == "CONT" then
			continue
		else
			return Result
		end
	end
	
	return "Not found"
end

-- TODO (FloofyPlasma): Find a way to bake this in w/o this nasty loop...
function Utilities.StartSettingsCheck(): ()
	while true do
		task.wait(tonumber(Utilities.GetSetting("SettingsCheckTime")))
		Settings = RequestSettingsRemote:InvokeServer()
	end
end

function Utilities.ShortNumber(Number: number): string
	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (tonumber(Utilities.GetSetting("ShortNumberDecimals")) or 2)) / 10 ^ (tonumber(Utilities.GetSetting("ShortNumberDecimals")) or 2)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

--// TODO (FloofyPlasma): Optimize...
function Utilities.FormatRelativeTime(Unix: number): string
	local TimeDifference = os.time() - (Unix ~= nil and Unix or 0)

	if TimeDifference < 60 then
		return "Just Now"
	elseif TimeDifference < 3600 then
		local Minutes = math.floor(TimeDifference / 60)
		return `{Minutes} {Minutes == 1 and "minute" or "minutes"} ago`
	elseif TimeDifference < 86400 then
		local Hours = math.floor(TimeDifference / 3600)
		return `{Hours} {Hours == 1 and "hour" or "hours"} ago`
	elseif TimeDifference < 604800 then
		local Days = math.floor(TimeDifference / 86400)
		return `{Days} {Days == 1 and "day" or "days"} ago`
	elseif TimeDifference < 31536000 then
		local Weeks = math.floor(TimeDifference / 604800)
		return `{Weeks} {Weeks == 1 and "week" or "weeks"} ago`
	else
		local Years = math.floor(TimeDifference / 31536000)
		return `{Years} {Years == 1 and "years" or "years"} ago`
	end
end

Utilities.Logging.Print = function(Message)
	if Utilities.GetSetting("Verbose") then
		print(`[Administer] [log] {Message}`)
		Log(str, "")
	end
end


return Utilities