-- Variables
local Root = script.Parent
local Types = require(Root.Types)
local Actions: { [string]: Types.Action } = {}

-- Functions

--[=[
	Creates a new action, which allows for custom modifications to instances.

	[Open Documentation](https://lumin-org.github.io/ui/api/#action)
]=]
local function New(name: string, apply: (Instance) -> ())
	if not Actions[name] then -- Cache the action so a new one is created each time
		Actions[name] = apply
	end
end

return {
	New = New,
	List = Actions,
}
