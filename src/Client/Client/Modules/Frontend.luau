--// Administer (2.0.0)

--// Administer Team (2024-2025)

local Frontend = {}

local Modules = script.Parent
local Libraries = script.Parent.Parent.Libraries

local Utilities = require(Modules.Utilities)
local Var = require(Modules.Variables)

function Frontend.Render() end

function Frontend.CloneElement(Element: GuiObject, Props: {}, OnClone: ((Clone: GuiObject) -> ())?): ()
	local Clone = Element:Clone()

	for Property, Value in Props do
		Clone[Property] = Value
	end

	Clone.Parent = Element.Parent

	if typeof(OnClone) == "nil" then
		return Clone
	else
		return OnClone(Clone)
	end
end

function Frontend.Log(Text, LogLevel)
	--// TODO
	return { MainFrame = {} }
end

function Frontend.Open(): ()
	if not Var.Panel then Var.Panel = Frontend.Render() end
	local AS = tonumber(Utilities.GetSetting("AnimationSpeed"))
	local X: number = 0.85
	local Y: number = 0.7

	Var.MainFrame.Size = UDim2.fromScale(X / 1.5, Y / 1.5)
	Var.MainFrame.GroupTransparency = 0.5

	Var.IsPanelAnimating = true
	Var.MainFrame.Visible = true
	if Utilities.GetSetting("UseAcrylic") then
		Libraries.Neon:BindFrame(Var.Panel.MainFrame, {
			Transparency = 0.95,
			BrickColor = BrickColor.new("Institutional white"),
		})
	end

	if not Var.Mobile then
		Var.MainFrame.Position = UDim2.fromScale(0.5, 1.25)
	else
		Var.MainFrame.Position = UDim2.fromScale(1.25, 0.5)
	end

	local PopupTween = Var.Services.TweenService:Create(
		Var.MainFrame,
		TweenInfo.new(AS, Enum.EasingStyle.Cubic),
		{ Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 }
	)
	PopupTween:Play()
	PopupTween.Completed:Wait()
	Var.Services.TweenService
		:Create(Var.MainFrame, TweenInfo.new(AS, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(X, Y),
		})
		:Play()

	Var.OpenSound:Play()
	task.delay(AS, function()
		Var.IsPanelAnimating = false
	end)
end

function Frontend.Close(Instant: boolean): ()
	if not Instant then Instant = false end --// TODO (FloofyPlasma): Redundant?

	Var.IsPanelAnimating = true

	xpcall(function(...)
		Libraries.Neon:UnbindFrame(Var.MainFrame)
	end, function(a0)
		--// We can ignore this, it probably happened bc a skid is spamming the keybind.
		Var.InitErrored = true
	end)

	local Duration = 0
	if not Instant then Duration = (tonumber(Utilities.GetSetting("AnimationSpeed")) or 1) end

	local X: number = 0.85
	local Y: number = 0.7

	local OT = Var.Services.TweenService:Create(
		Var.MainFrame,
		TweenInfo.new(Duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(X / 1.5, Y / 1.5),
			GroupTransparency = 0.5,
		}
	)

	OT:Play()
	OT.Completed:Wait()

	if not Var.Mobile then
		Var.Services.TweenService
			:Create(
				Var.MainFrame,
				TweenInfo.new(Duration, Enum.EasingStyle.Cubic),
				{ Position = UDim2.fromScale(0.5, 1.5), GroupTransparency = 1 }
			)
			:Play()
	else
		Var.Services.TweenService
			:Create(
				Var.MainFrame,
				TweenInfo.new(Duration, Enum.EasingStyle.Cubic),
				{ Position = UDim2.fromScale(1.5, 0.5), GroupTransparency = 1 }
			)
			:Play()
	end

	task.delay(Duration, function()
		Var.IsPanelAnimating = false
		Var.MainFrame.Visible = false
	end)
end

return Frontend
