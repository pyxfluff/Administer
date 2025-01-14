--// darkpixlz 2024

--// Administer

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CommandBar = script.Parent.CommandBar

local Actions = {
	["Moderation+_Ban"] = {
		["ActionName"] = "Ban",
		["Description"] = "Ban a set of users.",
		["FromApp"] = "Configuration",
		["Icon"] = "AppDefaults",
		["Flags"] = {
			{
				["Users"] = {
					["Type"] = "json",
					["Description"] = "A set of users to ban ([1,2,3...])",
					["Required"] = true,
				},
				["Reason"] = {
					["Type"] = "string",
					["Description"] = "The reason for the ban.",
					["Required"] = false,
				},
				["Duration"] = {
					["Type"] = "string",
					["Description"] = "The duration of the ban (1m, 2d, 3w, 4m, 5y...)",
					["Required"] = true,
				},
				["IsGlobal"] = {
					["Type"] = "bool",
					["Description"] = "Uses the Roblox IsGlobal ban API. Defaults to true.",
					["Required"] = false,
				},
				["CanAppeal"] = {
					["Type"] = "bool",
					["Description"] = "Allows this player to appeal their ban in a different game under this place. Must be configured. Defaults to false.",
					["Required"] = false,
				},
			},
		},
	},
	["Administer-Version"] = {
		["ActionName"] = "Check Administer Version",
		["Description"] = "Check Administer's runtime version.",
		["FromApp"] = "AdministerLogo",
		["Icon"] = "AppDefaults",
		["Flags"] = {},
	},
}

local function IndexSearch(Query)
	local Final = { ["_query"] = Query }
	for _, Item in Actions do
		local RealName = string.lower(Item["ActionName"])
		local Find = string.find(RealName, Query)

		if Find then table.insert(Final, Item) end
	end

	return Final
end

UIS.InputBegan:Connect(function(Input, Processed)
	local Anims = {}
	if Processed then return end

	if Input.KeyCode == Enum.KeyCode.Semicolon then
		CommandBar.Label:CaptureFocus()

		Anims = {
			TS:Create(
				CommandBar,
				TweenInfo.new(0.4, Enum.EasingStyle.Cubic),
				{ BackgroundTransparency = 0.25, Position = UDim2.new(0.233, 0, 0.877, 0) }
			),
			TS:Create(CommandBar.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), { ImageTransparency = 0 }),
			TS:Create(CommandBar.Label, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), { TextTransparency = 0 }),
		}
		for i, Anim in Anims do
			Anim:Play()
		end

		task.wait(0.02)
		CommandBar.Label.Text = ""

		local IsAnimating = false
		local ResultsBox = script.Parent.CommandBarOptions
		local CommandCursor = CommandBar.Icon
		local SearchEvent = CommandBar.Label:GetPropertyChangedSignal("Text"):Connect(function()
			task.spawn(function() --// spawn so we can return IfAnimating safely
				if IsAnimating then return end
				IsAnimating = true

				ResultsBox.Position = UDim2.new(0.233, 0, 0.877, 0)
				ResultsBox.Size = UDim2.new(0.534, 0, 0.092, 0)

				Anims = {
					TS:Create(CommandBar, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), { BackgroundTransparency = 1 }),
					TS:Create(ResultsBox, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
						GroupTransparency = 0,
						Size = UDim2.new(0.534, 0, 0.318, 0),
						Position = UDim2.new(0.233, 0, 0.648, 0),
					}),
				}
				for i, Anim in Anims do
					Anim:Play()
				end
			end)

			--// this should be relatively quick assuming we stay in the luau table, so no "Indexing" screen is required
			local SearchResults = IndexSearch(CommandBar.Label.Text)
			local Position = 1

			for i, v in ResultsBox.ScrollingFrame:GetChildren() do
				if v:IsA("Frame") then v:Destroy() end
			end

			for i, Result in SearchResults do
				if typeof(Result) == "string" then continue end
				local SearchObj = ResultsBox.Template:Clone()

				SearchObj.Label.Text = Result["ActionName"]
				SearchObj.AppIcon.Image = script.Parent.Main.Apps.MainFrame[Result["FromApp"]].Icon.Image
				SearchObj.Visible = true
				SearchObj.Parent = ResultsBox.ScrollingFrame
			end

			Anims = { --// child is 2nd here bc of the UIGridLayout
				TS:Create(
					CommandCursor,
					TweenInfo.new(0.4, Enum.EasingStyle.Cubic),
					{ Position = ResultsBox.ScrollingFrame:GetChildren()[2].RunSymbol.Position }
				),
				TS:Create(
					ResultsBox.ScrollingFrame:GetChildren()[2].AppIcon,
					TweenInfo.new(0.4, Enum.EasingStyle.Cubic),
					{ Position = ResultsBox.TemplateWithArrow.AppIcon.Position }
				),
			}
			for i, Anim in Anims do
				Anim:Play()
			end
		end)
	end
end)
