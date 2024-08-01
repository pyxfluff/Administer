--/ Administer

--// PyxFluff 2022-2024

local function PlaySFX()
	script.Sound:Play()
end

local last = "InfoPage"

for i, v in ipairs(script.Parent.buttons:GetChildren()) do
	local frame = string.sub(v.Name, 2,100)
	if not v:IsA("ImageLabel") then continue end
	
	v.TextButton.MouseButton1Click:Connect(function()
		if script.Parent.Parent:FindFirstChild(frame) then
			script.Parent.Parent.Parent.Animation.Position = UDim2.new(0,0,0,0)
			script.Parent.Parent.Parent.Animation:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			
			PlaySFX()
			
			script.Parent.Parent[tostring(last)].Visible = false
			last = frame
			task.wait(.2)
			script.Parent.Parent[frame].Visible = true
			
			if frame == "Settings" then
				for i, v in ipairs(script.Parent.Parent.Settings.Page:GetChildren()) do
					if not v:IsA("Frame") then continue end
					
					v.BackgroundTransparency = 0
					if v:FindFirstChild("Description") then
						v.Description.TextTransparency = 0
					end
					v.SettingName.TextTransparency = 0
					v.Action.BackgroundTransparency = 0
					v.Action.TextTransparency = 0
				end
				
			elseif frame == "ErrorLog" then
				for i, v in ipairs(script.Parent.Parent.ErrorLog.ScrollingFrame:GetChildren()) do
					if not v:IsA("Frame") then continue end

					v.BackgroundTransparency = 0
					v.ImageLabel.ImageTransparency = 0
					v.Text.TextTransparency = 0
					v.Timestamp.TextTransparency = 0
				end
			
			end
			
			script.Parent.Parent.Parent.Animation:TweenSizeAndPosition(UDim2.new(0,0,1,0), UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			script.Parent.Parent.Parent.Animation.Position = UDim2.new(0,0,0,0)
		else
			warn(`{frame} not found! this is an issue on administer's end, report it.`)
		end
	end)
end