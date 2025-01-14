local neon =
	require(game.Players.LocalPlayer.PlayerGui:FindFirstChild("AdministerMainPanel").ButtonAnims:WaitForChild("neon"))
neon:BindFrame(script.Parent, {
	Transparency = 0.98,
	BrickColor = BrickColor.new("Institutional white"),
})

script.Parent.Parent.Parent.Destroying:Connect(function()
	neon:UnbindFrame(script.Parent)
end)
