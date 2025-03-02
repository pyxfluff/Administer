--// Administer (2.0.0)

--// pyxfluff (2024-2025)

local Widgets = {}

local Modules = script.Parent

local Utilities = require(Modules.Utilities)
local Var = require(Modules.Variables)

function Widgets.GetAvailableWidgets(): { Small: { {} }, Large: { {} } }
	local Widgets: { Small: { {} }, Large: { {} } } = { Small = {}, Large = {} }

	for _, Widget in Var.MainFrame:GetChildren() do
		local WidgetFolder: Folder? = Widget:FindFirstChild(".widgets")
		if not WidgetFolder or not WidgetFolder:IsA("Folder") then continue end

		--// TODO (FloofyPlasma): Make this not a pcall...
		xpcall(function()
			local Module: Instance? = WidgetFolder:FindFirstChild(".widgetconfig")
			local Config

			if Module and Module:IsA("ModuleScript") then Config = require(Module) :: any end

			if not Config then
				Utilities.Logging.Error(
					`{Widget.Name}: Invalid Administer Widget folder (missing .widgetconfig, please read the docs!)`
				)
			end

			local SplitGenerator = string.split(Config["_generator"], "-")
			if SplitGenerator[1] ~= "AdministerWidgetConfig" then
				Utilities.Logging.Error(
					`{Widget.Name}: Not a valid Administer widget configuration file (bad .widgetconfig, please read the docs!)`
				)
			end
			if SplitGenerator[2] ~= Var.WidgetConfigIdealVersion then
				Utilities.Logging.Warn(
					`{Widget.Name}: Out of date Widget Config version (current {SplitGenerator[1]} latest: {Var.WidgetConfigIdealVersion}!`
				)
			end

			for _, Widget in Config["Widgets"] do
				if Widget["Type"] == "SMALL_LABEL" then
					table.insert(Widgets["Small"], Widget)
				elseif Widget["Type"] == "LARGE_BOX" then
					table.insert(Widgets["Large"], Widget)
				else
					Utilities.Logging.Error(`{Widget.Name}: Bad widget type (not in predefined list)`)
				end
				Widget["Identifier"] = `{Widget.Name}\\{Widget["Name"]}`
				Widget["AppName"] = Widget.Name
			end
		end, function() end)
	end

	return Widgets
end

function Widgets.Edit(
	ContainingUI --// DO NOT TYPE THIS FOR NOW
): ()
	local Editing = ContainingUI.Editing
	local AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2
	local Selected = ""
	local SelectedTable = {}
	local Tweens: { Tween } = {}

	Editing.Visible = true
	Editing.Preview.Select.Visible = true

	local NewPreviewContent: CanvasGroup = ContainingUI.Content:Clone()

	--// Ensure it's safe
	for _, Item in NewPreviewContent:GetChildren() do
		if
			Item:IsA("LocalScript") or Item:IsA("Script") --// idk why it would be a script but best to check?
		then
			Item:Destroy()
		end
	end

	NewPreviewContent.Parent = Editing:FindFirstChild("Preview")

	--// TODO: Springs
	Tweens = {
		Var.Services.TweenService:Create(Editing.Preview, TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.459, 0, 0.551, 0),
			Position = UDim2.new(0.271, 0, 0.057, 0),
			BackgroundTransparency = 0.4,
		}),
		--Var.Services.TweenService:Create(ContainingUI.Content, TweenInfo.new(AnimSpeed * .8), {GroupTransparency = .9,}),
		Var.Services.TweenService:Create(
			NewPreviewContent,
			TweenInfo.new(AnimSpeed * 0.35),
			{ Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }
		),
		Var.Services.TweenService:Create(Editing.Background, TweenInfo.new(AnimSpeed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.AppName, TweenInfo.new(AnimSpeed), { TextTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.WidgetName, TweenInfo.new(AnimSpeed), { TextTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.Last.ImageLabel, TweenInfo.new(AnimSpeed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(Editing.Next.ImageLabel, TweenInfo.new(AnimSpeed), { ImageTransparency = 0 }),
		Var.Services.TweenService:Create(
			Editing.Preview.DefaultCorner_,
			TweenInfo.new(AnimSpeed),
			{ CornerRadius = UDim.new(0, 18) }
		),
	}

	Editing.AppName.Text = ContainingUI:GetAttribute("AppName")
	Editing.WidgetName.Text = ContainingUI:GetAttribute("InitialWidgetName")

	task.spawn(function()
		Tweens[1]:Play()
		Tweens[2]:Play()
		Tweens[3]:Play()
		Tweens[8]:Play()
		task.wait(AnimSpeed * 0.8)
		for _, Tween in Tweens do
			Tween:Play()
		end
	end)

	local HoverFX = {}
	local ShouldHover = true

	HoverFX[1] = Editing.Preview.Select.MouseEnter:Connect(function()
		if not ShouldHover then return end
		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed * 0.6, Enum.EasingStyle.Quart),
				{ Size = UDim2.new(0.472, 0, 0.614, 0), Position = UDim2.new(0.264, 0, 0.017, 0) }
			)
			:Play()
	end)

	HoverFX[2] = Editing.Preview.Select.MouseLeave:Connect(function()
		if not ShouldHover then return end
		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed * 0.6, Enum.EasingStyle.Quart),
				{ Size = UDim2.new(0.459, 0, 0.551, 0), Position = UDim2.new(0.271, 0, 0.057, 0) }
			)
			:Play()
	end)

	HoverFX["ClickEvent"] = Editing.Preview.Select.MouseButton1Click:Connect(function()
		for _, v in HoverFX do
			v:Disconnect()
		end
		Editing.Preview.Select.Visible = false

		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 0.4

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.264, 0, 0.189, 0) }
			),
			Var.Services.TweenService:Create(Editing.AppName, TweenInfo.new(AnimSpeed), { TextTransparency = 1 }),
			Var.Services.TweenService:Create(Editing.WidgetName, TweenInfo.new(AnimSpeed), { TextTransparency = 1 }),
			Var.Services.TweenService:Create(
				Editing.Last.ImageLabel,
				TweenInfo.new(AnimSpeed),
				{ ImageTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.Next.ImageLabel,
				TweenInfo.new(AnimSpeed),
				{ ImageTransparency = 1 }
			),
		}

		for _, Tween in Tweens do
			Tween:Play()
		end

		Tweens[1].Completed:Wait()
		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 1.2

		Var.Services.TweenService
			:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.043, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }
			)
			:Play()
		Var.Services.TweenService:Create(Editing.Background, TweenInfo.new(AnimSpeed), { ImageTransparency = 1 }):Play()
		Var.Services.TweenService
			:Create(Editing.Preview.DefaultCorner_, TweenInfo.new(AnimSpeed), { CornerRadius = UDim.new(0, 0) })
			:Play()

		task.wait(AnimSpeed)

		if Selected == "" then
			--// just exit
			Utilities.Logging.Print("Exiting because nothing was selected!")
			for _, Element in Editing.Preview:GetChildren() do
				if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then
					Element.Parent = ContainingUI.Content
				end
			end

			Editing.Visible = false
			return
		end

		ContainingUI.SideData.Banner.Text = SelectedTable["Name"]
		ContainingUI.SideData.BannerIcon.Image = SelectedTable["Icon"]
		ContainingUI.Content:ClearAllChildren()

		local _ = Var.Remotes.UpdateHomePage:InvokeServer({
			["EventType"] = "UPDATE",
			["EventID"] = `ChangeWidget-{ContainingUI.Name}`,
			["WidgetID"] = ContainingUI.Name,
			["NewIdentifier"] = Selected,
		})

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then
				Element.Parent = ContainingUI.Content
			end
		end

		Editing.Visible = false
	end)

	--// start finding other widgets to use
	local Widgets = Widgets.GetAvailableWidgets()["Large"]
	local Count = 0 --// 0 by default because ideally they have one already?
	local Buttons = {}

	Buttons[1] = Editing.Next.MouseButton1Click:Connect(function()
		ShouldHover = false
		Count += 1

		if Count > #Widgets then Count = 1 end

		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2
		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.057, 0), GroupTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.81, 0), TextTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(-0.5, 0, 0.647, 0), TextTransparency = 1 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		task.wait(AnimSpeed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element:Destroy() end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(1, 0, 0.075, 0)
		Editing.AppName.Position = UDim2.new(1, 0, 0.81, 0)
		Editing.WidgetName.Position = UDim2.new(1, 0, 0.647, 0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2.45
		SelectedTable = Widget

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.271, 0, 0.057, 0), GroupTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.81, 0), TextTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.647, 0), TextTransparency = 0 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		Tweens[1].Completed:Wait()
		ShouldHover = true
	end)

	Buttons[2] = Editing.Last.MouseButton1Click:Connect(function()
		ShouldHover = false
		Count -= 1

		if Count < 1 then
			Count = 0
			return
		end

		if Count > #Widgets then Count = 1 end

		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2
		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.057, 0), GroupTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.81, 0), TextTransparency = 1 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(1, 0, 0.647, 0), TextTransparency = 1 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		task.wait(AnimSpeed / 3)

		local Widget = Widgets[Count]
		local NewWidgetTemplate = Widget["BaseUIFrame"]:Clone()
		NewWidgetTemplate.Visible = true

		for _, Element in Editing.Preview:GetChildren() do
			if not table.find({ "DefaultCorner_", "Select" }, Element.Name) then Element:Destroy() end
		end

		NewWidgetTemplate.Parent = Editing.Preview
		Selected = Widget["Identifier"]

		Editing.Preview.Position = UDim2.new(-0.7, 0, 0.075, 0)
		Editing.AppName.Position = UDim2.new(-0.7, 0, 0.81, 0)
		Editing.WidgetName.Position = UDim2.new(-0.7, 0, 0.647, 0)
		Editing.WidgetName.Text = Widget["Name"]
		Editing.AppName.Text = Widget["AppName"]
		AnimSpeed = tonumber(Utilities.GetSetting("AnimationSpeed")) :: number * 2.45
		SelectedTable = Widget

		Tweens = {
			Var.Services.TweenService:Create(
				Editing.Preview,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.271, 0, 0.057, 0), GroupTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.AppName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.81, 0), TextTransparency = 0 }
			),
			Var.Services.TweenService:Create(
				Editing.WidgetName,
				TweenInfo.new(AnimSpeed, Enum.EasingStyle.Quart),
				{ Position = UDim2.new(0.04, 0, 0.647, 0), TextTransparency = 0 }
			),
		}
		for _, t in Tweens do
			t:Play()
		end

		Tweens[1].Completed:Wait()
		ShouldHover = true
	end)
end

function Widgets.ActivateWidget(WidgetNumber, WidgetConfig)
    
end

function Widgets.Initialize()
    
end

return Widgets
