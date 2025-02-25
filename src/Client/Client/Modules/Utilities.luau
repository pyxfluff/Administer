local Utilities = {
	Logging = {},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdministerRemotes = ReplicatedStorage:WaitForChild("AdministerRemotes", 10)
--local RequestSettingsRemote = AdministerRemotes:WaitForChild("SettingsRemote", 10):WaitForChild("RequestSettings", 10)
--local Settings = RequestSettingsRemote:InvokeServer()

-- local Frontend = require(script.Parent.Frontend)
-- TODO fix this
local Frontend = { Log = function(...) end }
local Var = require(script.Parent.Variables)

function Utilities.GetSetting(Setting: string): string | boolean | nil
	return ""
	--[[
	local SettingModule = Settings

	if SettingModule == { false } then --// future proof
		error(
			"[Administer] [fault]: Oops, your settings did not authenticate properly. This is probably a bug with the ranking system. Please provide a detailed error report to the pyxfluff."
		)
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
    ]]
end

-- TODO (FloofyPlasma): Find a way to bake this in w/o this nasty loop...
function Utilities.StartSettingsCheck(): ()
	while true do
		task.wait(tonumber(Utilities.GetSetting("SettingsCheckTime")))
		Settings = RequestSettingsRemote:InvokeServer()
	end
end

function Utilities.ShortNumber(Number: number): string
	return math.floor(
		((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3))
			* 10 ^ (tonumber(Utilities.GetSetting("ShortNumberDecimals")) or 2)
	) / 10 ^ (tonumber(Utilities.GetSetting("ShortNumberDecimals")) or 2) .. (({
		"k",
		"M",
		"B",
		"T",
		"Qa",
		"Qn",
		"Sx",
		"Sp",
		"Oc",
		"N",
	})[math.floor(math.log10(Number) / 3)] or "")
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

Utilities.Logging.Print = function(...)
	if Utilities.GetSetting("Verbose") then
		print("[Administer] [log]", ...)
		Frontend.Log("log", ...)
	end
end

Utilities.Logging.Warn = function(...)
	warn("[Administer] [warn]", ...)
	Frontend.Log("wrn", ...)
end

Utilities.Logging.Error = function(message: string)
	Frontend.Log("err", message)
	error(`[Administer] [fault] {message}`)
end

function Utilities.NewNotification(
	AppTitle: string,
	Icon: string,
	Body: string,
	Heading: string,
	Duration: number?,
	Options: { any }?,
	OpenTime: number?
): ()
	local Panel = script.Parent

	Options = Options or {}
	OpenTime = OpenTime or 1.25

	--// TODO (FloofyPlasma): There has got to be a better way of doing this...
	local Placeholder = Instance.new("Frame")
	Placeholder.BackgroundTransparency = 1
	Placeholder.Size = UDim2.fromScale(1.036, 0.142)
	Placeholder.Parent = Panel.Notifications

	local Notification = Panel.Notifications.Template:Clone()
	local NotificationContent = Notification.NotificationContent
	Notification.Visible = true
	Notification.Position = UDim2.fromScale(0, 1.3)
	NotificationContent.Body.Text = Body
	NotificationContent.Header.Title.Text = `<b>{AppTitle}</b> · {Heading}`
	NotificationContent.Header.ImageL.Image = Icon

	--// TODO (FloofyPlasma): Should this be strict typed?
	if Options then
		for _, Object in Options do
			local NewButton = NotificationContent.Buttons.DismissButton:Clone()
			NewButton.Name = Object["Text"]
			NewButton.Title.Text = Object["Text"]
			NewButton.ImageL.Image = Object["Icon"]
			NewButton.MouseButton1Click:Connect(function()
				Object["OnClick"]()
			end)

			NewButton.Parent = NotificationContent.Buttons
		end
	end

	local NewSound = Instance.new("Sound")
	NewSound.SoundId = "rbxassetid://9770089602"
	NewSound.Parent = NotificationContent
	NewSound:Play()

	Notification.Parent = Panel.NotificationsTweening

	local Tweens: { Tween } = {
		Var.Services.TweenService:Create(
			Notification,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = UDim2.fromScale(-0.018, 0.858), --// TODO (FloofyPlasma): Make this a nicer number...
			}
		),
		Var.Services.TweenService:Create(
			NotificationContent,
			TweenInfo.new(OpenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				GroupTransparency = 0,
			}
		),
	}

	for _, Tween: Tween in Tweens do
		Tween:Play()
	end

	Tweens[1].Completed:Wait()
	Placeholder:Destroy()
	Notification.Parent = Panel.Notifications

	local function Close(Instant: boolean): ()
		if not Instant then Instant = false end

		local NotifTween = Var.Services.TweenService:Create(
			NotificationContent,
			TweenInfo.new((Instant and 0 or OpenTime :: number * 0.7), Enum.EasingStyle.Quad),
			{
				Position = UDim2.fromScale(1, 0),
				GroupTransparency = 1,
			}
		)

		NotifTween:Play()
		NotifTween.Completed:Wait()
		Notification:Destroy()
	end

	NotificationContent.Buttons.DismissButton.MouseButton1Click:Connect(Close)
	task.delay(Duration, Close, false)
end

function Utilities.CreateReflection(Image: string): EditableImage
	--// TODO: I hate this code can we fix it pls
	local RealEI = Var.Services.AssetService:CreateEditableImageAsync(Content.fromUri(Image))
	local Resized = Vector2.new(RealEI.Size.X, RealEI.Size.Y)

	local px = RealEI:ReadPixelsBuffer(Vector2.zero, Resized)
	local rpx = {}

	for i = 1, Resized.X * Resized.Y * 4 do
		table.insert(rpx, buffer.readu8(px, i - 1))
	end

	local npx = {}

	for Chunk = 0, (Resized.X * Resized.Y - 1) do
		local Index = Resized.Y * 4 - (Chunk % Resized.Y) * 4 + math.floor(Chunk / Resized.Y) * Resized.Y * 4 - 3
		table.move(rpx, Chunk * 4 + 1, Chunk * 4 + 4, Index, npx)
	end

	local FinalBuffer = buffer.create(Resized.X * Resized.Y * 4)

	for i = 1, #npx do
		buffer.writeu8(FinalBuffer, i - 1, npx[i])
	end

	RealEI:WritePixelsBuffer(Vector2.zero, Resized, FinalBuffer)

	return RealEI
end

return Utilities
