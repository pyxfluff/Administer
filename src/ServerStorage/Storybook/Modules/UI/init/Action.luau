-- Variables
local Root = script.Parent
local Types = require(Root.Types)

-- Functions

--[=[
	Creates a new action, which allows for custom modifications to instances.

	[Open Documentation](https://lumin-org.github.io/ui/api/#action)
]=]
return function(apply: (Instance) -> ()): Types.Action
	return apply
end
