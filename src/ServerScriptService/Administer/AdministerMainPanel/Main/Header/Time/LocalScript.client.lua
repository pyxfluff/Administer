local d = os.date()
local function Date()
	return os.date("%I")..":"..os.date("%M").." "..os.date("%p")..", "..os.date("%A")..", "..os.date("%B").." "..os.date("%d")..", "..os.date("%Y")
end

script.Parent.Text = Date()

while task.wait(60) do
	script.Parent.Text = Date()
end