--// pyxfluff 2024

--// Administer

--// Services
local TweenService = game:GetService("TweenService")

local Menus = {
	[1] = {
		["Name"] = "Info",
		["Active"] = true,
		["Button"] = script.Parent.New.AInfoPage,
		["Frame"] = script.Parent.Parent.InfoPage,
		["OnClick"] = function() end,
		["ListIndex"] = 4
	},

	[2] = {
		["Name"] = "Settings",
		["Active"] = false,
		["Button"] = script.Parent.New.BSettings,
		["Frame"] = script.Parent.Parent.Settings,
		["OnClick"] = function() end,
		["ListIndex"] = 6
	},

	[3] = {
		["Name"] = "Apps",
		["Active"] = false,
		["Button"] = script.Parent.New.CApps,
		["Frame"] = script.Parent.Parent.Apps,
		["OnClick"] = function() end,
		["ListIndex"] = 7
	},

	[4] = {
		["Name"] = "Rank Management",
		["Active"] = false,
		["Button"] = script.Parent.New.DAdmins,
		["Frame"] = script.Parent.Parent.Admins,
		["OnClick"] = function() end,
		["ListIndex"] = 8
	},

	[5] = {
		["Name"] = "Administer Log",
		["Active"] = false,
		["Button"] = script.Parent.New.EErrorLog,
		["Frame"] = script.Parent.Parent.ErrorLog,
		["OnClick"] = function() end,
		["ListIndex"] = 9
	},

	[6] = {
		["Name"] = "Marketplace",
		["Active"] = false,
		["Button"] = script.Parent.New.FMarketplace,
		["Frame"] = script.Parent.Parent.Marketplace,
		["OnClick"] = function() end,
		["ListIndex"] = 10
	}
}

for i, Child in script.Parent.New:GetChildren() do
	if not Child:IsA("Frame") or Child.Name == "AASpacer" then
		continue
	end

	Child.Click.MouseButton1Click:Connect(function()
		local ActiveMenu, ActiveMenuIndex, RealIndex = nil, 0, 0
		for i, Menu in Menus do
			if Menu["Active"] then
				ActiveMenu = Menu
				--ActiveMenuIndex = Menu["ListIndex"]
				ActiveMenuIndex = i
			end

			if Menu["Button"] == Child then
				RealIndex = i
			end
		end
		
		ActiveMenu["Active"] = false
		Menus[RealIndex]["Active"] = true

		if Child:FindFirstChild("UIAspectRatioConstraint") then
			task.delay(.45, function() --// wait for our animation
				Child["UIAspectRatioConstraint"].Parent = ActiveMenu["Button"]
			end)
		else
			print("no constraint!!")
			local Constraint = Instance.new("UIAspectRatioConstraint")
			
			Constraint.AspectRatio = 1
			Constraint.Parent = ActiveMenu["Button"]
		end

		local TINfo = TweenInfo.new(.45, Enum.EasingStyle.Quart)
		local ResetTween = TweenService:Create(ActiveMenu["Button"], TINfo, { Size = UDim2.new(0.198, 0, 0.696, 0) })
		local ExpandTween = TweenService:Create(Child, TINfo, { Size = UDim2.new(.438,0,.696,0)}) 

		ResetTween:Play()
		ExpandTween:Play()

		local FrameTween1, FrameTween2
		local TweenDuration = math.abs(ActiveMenuIndex - Menus[RealIndex]["ListIndex"]) * 0.2

		if RealIndex > ActiveMenuIndex then
			FrameTween1 = TweenService:Create(ActiveMenu["Frame"], TweenInfo.new(TweenDuration), { Position = UDim2.new(-.7, 0, .172, 0) })
			Menus[RealIndex]["Frame"].Position = UDim2.new(1.3, 0, .172, 0)
			FrameTween2 = TweenService:Create(Menus[RealIndex]["Frame"], TweenInfo.new(TweenDuration), { Position = UDim2.new(0, 0, .172, 0) })
		else
			FrameTween1 = TweenService:Create(ActiveMenu["Frame"], TweenInfo.new(TweenDuration), { Position = UDim2.new(1.3, 0, .172, 0) })
			Menus[RealIndex]["Frame"].Position = UDim2.new(-.7, 0, .172, 0)
			FrameTween2 = TweenService:Create(Menus[RealIndex]["Frame"], TweenInfo.new(TweenDuration), { Position = UDim2.new(0, 0, .172, 0) })
		end
		
		Menus[RealIndex]["Frame"].Visible = true
		
		FrameTween1:Play()
		FrameTween2:Play()
		Menus[RealIndex]["Active"] = true
		
		FrameTween2.Completed:Wait()
		
		print(ActiveMenuIndex)
		
		Menus[ActiveMenuIndex]["Frame"].Visible = false
	end)
end
