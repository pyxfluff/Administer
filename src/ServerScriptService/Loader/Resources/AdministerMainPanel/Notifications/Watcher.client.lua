script.Parent.ChildAdded:Connect(function(Inst)
	xpcall(function()
		Inst.NotificationContent.Background.LocalScript.Enabled = true
	end, function () end)
end)