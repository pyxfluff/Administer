local neon = require(script.Parent.Parent.Parent.Parent.ButtonAnims:WaitForChild("neon"))
if not game.Lighting:FindFirstChild("PSDoFEffect") then
	local NewEffect = Instance.new("DepthOfFieldEffect")
	NewEffect.FarIntensity = 0
	NewEffect.Name = "PSDoFEffect"
	NewEffect.FocusDistance = 51.6
	NewEffect.InFocusRadius = 50
	NewEffect.NearIntensity = 1
	NewEffect.Parent = game.Lighting
end
neon:BindFrame(script.Parent, {
	Transparency = 0.98;
	BrickColor = BrickColor.new("Institutional white");
})