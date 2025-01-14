local theme = {}
--[[

REQUIRED INFO

]]

theme.Author = "DarkPixlz"
theme.Name = "Example Theme"
theme.Description = "An example theme to help you make PS themes."
theme.IconGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(0.25098, 0.513725, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.12549, 0.137255, 0.156863)),
})
-- MUST KEEP THE LAST COLORPOINT

--[[

THEME CONFIG

]]
theme.BackgroundColor = Color3.fromRGB(32, 35, 40)

theme.AccentColor = Color3.new(1, 1, 1)
theme.IsAccentGradient = true -- if so, last one will be ignored and set to white
theme.AccentGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(0.25098, 0.513725, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.607843, 0.784314, 1)),
})
theme.BorderSize = 1 --In Pixels
theme.UseTextSizeConstraints = false
theme.UseTextScaled = false
--theme.FontSize = 12 --Ignored if the previous 2 are true. Noticed this may be a bad idea? Idk with some changes it coud work
theme.UseMaterialUIAnimations = false -- Ripple effect
theme.Animations = true -- This is up to the user, but the theme can set a default.
theme.ScreenLoadingTime = 0.4
theme.HeaderImage = "rbxassetid://8862497707"
theme.HeaderText = "PreloadService"
theme.ListColor1 = Color3.new(0.0784314, 0.0784314, 0.0784314)
theme.ListColor2 = Color3.new(0.0352941, 0.0352941, 0.0352941)
theme.MainFont = Enum.Font.Gotham
theme.AllOtherText = Enum.Font.Gotham
theme.IsHeadersBold = true
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
	[1] = {
		Icon = "rbxassetid://123",
		IconName = "Edit",
		-- Will replace the edit pen with 123
	},
	[2] = {
		Icon = "rbxassetid://456",
		IconName = "Spinner",
		-- Will replace the loading spinner with 456
	},
}
theme.RudeMode = true -- This was for a meme, idk if it should stick around?
theme.MarkAsDarkUI = false -- Mark as dark mode
theme.UseCorners = true -- Whether or not to use corner rounding
theme.TextInterfaceBorderRadius = 8 -- TextBoxes, TextButtons, TextLabels, etc
theme.OtherBorderRadius = 18 -- Frames, anything else really. ScrollingFrames require a bit more work, as they dont support UICorners.

theme.PreloadServiceCollaborationWordmark = nil -- If set, the theme will display "PreloadService x STRING" with the logo centered, x is a lighter font.

theme.SpinnerCompleteTime = 0.4 -- How long it takes the loading spinner to complete one rotation.

return theme
