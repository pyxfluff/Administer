local TB = script.Parent.Searchbar.TextBox
local Open

TB.MouseEnter:Connect(function()
	if Open then return end
	local Tween = game:GetService("TweenService"):Create(script.Parent.UIGridLayout, TweenInfo.new(.15, Enum.EasingStyle.Quart), {CellSize = UDim2.new(.63,0,1,0)})

	Tween:Play()
end)

TB.MouseLeave:Connect(function()
	if Open then return end
	local Tween = game:GetService("TweenService"):Create(script.Parent.UIGridLayout, TweenInfo.new(.15, Enum.EasingStyle.Quart), {CellSize = UDim2.new(.6,0,1,0)})

	Tween:Play()
end)

TB.Focused:Connect(function()
	local Tween = game:GetService("TweenService"):Create(script.Parent.UIGridLayout, TweenInfo.new(.8, Enum.EasingStyle.Elastic), {CellSize = UDim2.new(1,0,1,0)})
	
	Open = true
	Tween:Play()
end)

TB.FocusLost:Connect(function(EnterPressed)
	if EnterPressed then 
		local Plaintext = string.split(TB.Text, " ")[1]
		
		if string.split(TB.Text, ":")[1] == "http" or string.split(TB.Text, ":")[1] == "https" then
			print("-- Installing plugin server... --")
			script.Parent.Searchbar.Popup.Label.Text = "Please wait..."
			
			if string.split(TB.Text, " ")[2] == "--skip" then
				script.Parent.Searchbar.Popup.Label.Text = game.ReplicatedStorage:WaitForChild("AdministerRemotes"):WaitForChild("InstallPluginServer"):InvokeServer(Plaintext)
			else
				print("todo")
				script.Parent.Searchbar.Popup.Label.Text = game.ReplicatedStorage:WaitForChild("AdministerRemotes"):WaitForChild("InstallPluginServer"):InvokeServer(Plaintext)
			end
			
			task.wait(5)
			script.Parent.Searchbar.Label.Text = "Type an ID, name, or marketplace server URL..."
		elseif tonumber(TB.Text) ~= nil then
			print("-- Installing plugin... --")
			script.Parent.Searchbar.Popup.Label.Text = "Please wait..."
			
			if string.split(TB.Text, " ")[2] == "--skip" then
				script.Parent.Searchbar.Popup.Label.Text = game.ReplicatedStorage:WaitForChild("AdministerRemotes"):WaitForChild("InstallPlugin"):InvokeServer(Plaintext)
			else
				print("todo")
				script.Parent.Searchbar.Popup.Label.Text = game.ReplicatedStorage:WaitForChild("AdministerRemotes"):WaitForChild("InstallPlugin"):InvokeServer(Plaintext)
			end
			
			task.wait(5)
			script.Parent.Searchbar.Label.Text = "Type an ID, name, or marketplace server URL..."
		else
			print("-- Searching... --")
		end
		
	end
	local Tween = game:GetService("TweenService"):Create(script.Parent.UIGridLayout, TweenInfo.new(.8, Enum.EasingStyle.Elastic), {CellSize = UDim2.new(.6,0,1,0)})
	
	Open = false
	Tween:Play()
	TB.Text = ""
	Tween = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup, TweenInfo.new(.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1,0,.469,0), Position = UDim2.new(0,0,0,0)})
	local Tween2 = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup.Label, TweenInfo.new(.4, Enum.EasingStyle.Quart), {TextTransparency = 1})
	local Tween3 = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup.Icon, TweenInfo.new(.4, Enum.EasingStyle.Quart), {ImageTransparency = 1})

	Tween:Play()
	Tween2:Play()
	Tween3:Play()
	
end)

TB:GetPropertyChangedSignal("Text"):Connect(function()
	if not Open then return end
	script.Parent.Searchbar.Label.Text = TB.Text
	
	local Tween = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup, TweenInfo.new(.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1,0,1.224,0), Position = UDim2.new(0,0,-.755,0)})
	local Tween2 = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup.Label, TweenInfo.new(.4, Enum.EasingStyle.Quart), {TextTransparency = 0})
	local Tween3 = game:GetService("TweenService"):Create(script.Parent.Searchbar.Popup.Icon, TweenInfo.new(.4, Enum.EasingStyle.Quart), {ImageTransparency = 0})

	Tween:Play()
	Tween2:Play()
	Tween3:Play()
	
	if string.split(TB.Text, ":")[1] == "http" or string.split(TB.Text, ":")[1] == "https" then
		script.Parent.Searchbar.Popup.Label.Text = "Press enter to install this plugin server..."
	elseif tonumber(TB.Text) ~= nil then
		script.Parent.Searchbar.Popup.Label.Text = "Press enter to install this plugin..."
	else
		script.Parent.Searchbar.Popup.Label.Text = "Press enter to search..."
	end
end)