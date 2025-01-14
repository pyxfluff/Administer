--// pyxfluff 2024

--// Administer

--// Services
local TweenService = game:GetService("TweenService")

--// Variables
local MPRealThread = nil

--// Helpers
local function MPThread()
	local Button = script.Parent.New.FMarketplace
	local IsTyping = false
	local Strings = {
		"Find an app",
		"Install by ID",
		"Install an app server",
		"Click to search",
	}

	Button.Input.Focused:Connect(function()
		IsTyping = true
	end)

	Button.Input.FocusLost:Connect(function(WasEnter)
		IsTyping = false

		if WasEnter then
		end
	end)

	task.delay(0.5, function()
		Button.HeaderLabel.TextTransparency = 1
		Button.Input.Visible = true

		task.wait(3)

		while not IsTyping do
			local t = game:GetService("TweenService"):Create(Button.Input, TweenInfo.new(2), { TextTransparency = 1 })
			t:Play()
			t.Completed:Wait()

			Button.Input.PlaceholderText = Strings[math.random(1, #Strings)]
			task.wait(0.5)

			t = game:GetService("TweenService"):Create(Button.Input, TweenInfo.new(2), { TextTransparency = 0 })
			t:Play()
			t.Completed:Wait()

			task.wait(7)
		end
	end)
end

local Menus = {
	[1] = {
		["Name"] = "Information",
		["Active"] = true,
		["Button"] = script.Parent.New.AInfoPage,
		["Frame"] = script.Parent.Parent.InfoPage,
		["OnClick"] = function() end,
		["Deselect"] = function() end,
		["ListIndex"] = 4,
	},

	[2] = {
		["Name"] = "Settings",
		["Active"] = false,
		["Button"] = script.Parent.New.BSettings,
		["Frame"] = script.Parent.Parent.Settings,
		["OnClick"] = function() end,
		["Deselect"] = function() end,
		["ListIndex"] = 6,
	},

	[3] = {
		["Name"] = "Apps",
		["Active"] = false,
		["Button"] = script.Parent.New.CApps,
		["Frame"] = script.Parent.Parent.Apps,
		["OnClick"] = function() end,
		["Deselect"] = function() end,
		["ListIndex"] = 7,
	},

	[4] = {
		["Name"] = "Ranks",
		["Active"] = false,
		["Button"] = script.Parent.New.DAdmins,
		["Frame"] = script.Parent.Parent.Admins,
		["OnClick"] = function() end,
		["Deselect"] = function() end,
		["ListIndex"] = 8,
	},

	[5] = {
		["Name"] = "Administer Log",
		["Active"] = false,
		["Button"] = script.Parent.New.EErrorLog,
		["Frame"] = script.Parent.Parent.ErrorLog,
		["OnClick"] = function() end,
		["Deselect"] = function() end,
		["ListIndex"] = 9,
	},

	[6] = {
		["Name"] = "Marketplace",
		["Active"] = false,
		["Button"] = script.Parent.New.FMarketplace,
		["Frame"] = script.Parent.Parent.Marketplace,
		["OnClick"] = function()
			MPRealThread = task.spawn(MPThread)
		end,
		["Deselect"] = function()
			task.cancel(MPRealThread)
			script.Parent.New.FMarketplace.Input.Visible = false
		end,
		["ListIndex"] = 10,
	},
}

local MaxTweenDuration = 0.9

for i, Child in script.Parent.New:GetChildren() do
	if not Child:IsA("Frame") or Child.Name == "AASpacer" then continue end

	Child.Click.MouseButton1Click:Connect(function()
		local ActiveMenu, ActiveMenuIndex, RealIndex = nil, 0, 0
		local TINfo = TweenInfo.new(0.45, Enum.EasingStyle.Quart)

		for i, Menu in Menus do
			if Menu["Active"] then
				ActiveMenu = Menu
				ActiveMenuIndex = i
			end

			if Menu["Button"] == Child then RealIndex = i end
		end

		ActiveMenu["Active"] = false
		Menus[RealIndex]["Active"] = true

		if ActiveMenu == Menus[RealIndex] then return end

		local ActiveButton = ActiveMenu["Button"]

		local AButtonIconTween = TweenService:Create(ActiveButton.ImageLabel, TINfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.6, 0, 0.6, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		})
		local AButtonTextTween = TweenService:Create(ActiveButton.HeaderLabel, TINfo, { TextTransparency = 1 })

		AButtonIconTween:Play()
		AButtonTextTween:Play()

		task.spawn(function()
			AButtonTextTween.Completed:Wait()
			ActiveButton.HeaderLabel:Destroy()
		end)

		local Text = ActiveButton.HeaderLabel:Clone()

		Text.Parent = Child
		Text.Text = Menus[RealIndex]["Name"]

		local ButtonIconTween = TweenService:Create(Menus[RealIndex]["Button"].ImageLabel, TINfo, {
			Position = UDim2.new(0, 0, 0.219, 0),
			Size = UDim2.new(0.197, 0, 0.563, 0),
			AnchorPoint = Vector2.new(0, 0),
		})
		local ButtonTextTween = TweenService:Create(Text, TINfo, { TextTransparency = 0 })

		ButtonIconTween:Play()
		ButtonTextTween:Play()

		--if Child:FindFirstChild("UIAspectRatioConstraint") then
		--	task.delay(.45, function()
		--		Child["UIAspectRatioConstraint"].Parent = ActiveMenu["Button"]
		--	end)
		--else
		task.delay(0.45, function()
			local Constraint = Instance.new("UIAspectRatioConstraint")
			Constraint.AspectRatio = 1
			Constraint.Parent = ActiveMenu["Button"]
		end)
		--end

		local ResetTween = TweenService:Create(ActiveMenu["Button"], TINfo, { Size = UDim2.new(0.087, 0, 0.696, 0) })
		local ExpandTween = TweenService:Create(Child, TINfo, { Size = UDim2.new(0.438, 0, 0.696, 0) })

		ResetTween:Play()
		ExpandTween:Play()
		Child.UIAspectRatioConstraint:Destroy()

		local FrameTween1, FrameTween2
		local TweenDuration =
			math.min(math.abs(ActiveMenuIndex - Menus[RealIndex]["ListIndex"]) * 0.3, MaxTweenDuration)

		if RealIndex > ActiveMenuIndex then
			FrameTween1 = TweenService:Create(
				ActiveMenu["Frame"],
				TweenInfo.new(TweenDuration),
				{ Position = UDim2.new(-1, 0, 0.172, 0) }
			)
			Menus[RealIndex]["Frame"].Position = UDim2.new(1.3, 0, 0.172, 0)
			FrameTween2 = TweenService:Create(
				Menus[RealIndex]["Frame"],
				TweenInfo.new(TweenDuration),
				{ Position = UDim2.new(0, 0, 0.172, 0) }
			)
		else
			FrameTween1 = TweenService:Create(
				ActiveMenu["Frame"],
				TweenInfo.new(TweenDuration),
				{ Position = UDim2.new(1.3, 0, 0.172, 0) }
			)
			Menus[RealIndex]["Frame"].Position = UDim2.new(-0.7, 0, 0.172, 0)
			FrameTween2 = TweenService:Create(
				Menus[RealIndex]["Frame"],
				TweenInfo.new(TweenDuration),
				{ Position = UDim2.new(0, 0, 0.172, 0) }
			)
		end

		Menus[RealIndex]["Frame"].Visible = true

		FrameTween1:Play()
		FrameTween2:Play()
		Menus[RealIndex]["Active"] = true
		Menus[RealIndex].OnClick()

		FrameTween2.Completed:Wait()

		Menus[ActiveMenuIndex]["Frame"].Visible = false
		Menus[ActiveMenuIndex].Deselect()
	end)
end
