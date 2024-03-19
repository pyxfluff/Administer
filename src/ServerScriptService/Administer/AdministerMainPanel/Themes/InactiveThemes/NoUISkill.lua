local theme = {}
--[[

REQUIRED INFO

]]

theme.Author = "DarkPixlz"
theme.Name = "Bad UI Theme"
theme.Description = "lol"
theme.IconGradient = ColorSequence.new(
	ColorSequenceKeypoint.new(0, Color3.new(1, 0.137255, 0.984314)),
	ColorSequenceKeypoint.new(1, Color3.new(0.12549, 0.137255, 0.156863))
)

--[[

THEME CONFIG

]]
theme.BackgroundColor = Color3.fromRGB(255, 255, 255)
theme.AccentColor = Color3.new(0.839216, 0.839216, 0.839216)
theme.IsAccentGradient = false -- if so, last one will be ignored and set to white
theme.AccentGradient = ColorSequence.new(
	ColorSequenceKeypoint.new(0, Color3.new(0.25098, 0.513725, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.607843, 0.784314, 1))
)
theme.BorderSize = 1 --In Pixels
theme.UseTextSizeConstraints = false
theme.UseTextScaled = true
--theme.FontSize = 12 --Ignored if the previous 2 are true. Noticed this may be a bad idea? Idk with some changes it coud work
theme.UseMaterialUIAnimations = false -- Ripple effect
theme.Animations = false -- This is up to the user, but the theme can set a default.
theme.ScreenLoadingTime = 3
theme.HeaderImage = "rbxassetid://0"
theme.HeaderText = "pre load serivce"
theme.ListColor1 = Color3.new(0.901961, 0.168627, 0.968627)
theme.ListColor2 = Color3.new(0.160784, 1, 0.0666667)
theme.MainFont = Enum.Font.SourceSans
theme.AllOtherText = Enum.Font.SourceSans
theme.IsHeadersBold = false
theme.BoldFont = Enum.FontWeight.Bold -- Use either SemiBold, Bold, or Heavy
theme.MenuIcons = {
	Home = "",
	Players = "",
	History = "",
	LoadingTimes = "",
	Modules = "",
	Info = "",
	-- Does NOT contain custom icons via plugins. Those can still be overridden by names.
}
theme.Icons = {
	-- The rest of the icons, based off name.
}
theme.RudeMode = true -- This was for a meme, idk if it should stick around?
theme.MarkAsDarkUI = false -- Mark as dark mode
theme.UseCorners = false -- Whether or not to use corner rounding
theme.TextInterfaceBorderRadius = 8 -- TextBoxes, TextButtons, TextLabels, etc
theme.OtherBorderRadius = 18 -- Frames, anything else really. ScrollingFrames require a bit more work, as they dont support UICorners.
theme.PreloadServiceCollaborationWordmark = nil -- If set, the theme will display "PreloadService x STRING" with the logo centered, x is a lighter font. 
theme.SpinnerCompleteTime = 15 -- How long it takes the loading spinner to complete one rotation.



return theme
