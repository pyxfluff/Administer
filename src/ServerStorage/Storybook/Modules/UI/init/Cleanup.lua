-- Variables
local Root = script.Parent
local Action = require(Root.Action)
local Types = require(Root.Types)
local Debugger = require(Root.Parent.roblox_packages.debugger)

-- Functions

local function Helper(instance: any)
	if instance.Destroy then
		instance:Destroy()
	elseif instance.Disconnect then
		instance:Disconnect()
	else
		Debugger.Fatal("CleanUpNotAllowed")
	end
end

-- Module

--[=[
	Cleans and removes the items provided to they key when the parent instance is destroyed.

	[Open Documentation](https://lumin-org.github.io/ui/api/keys/#clean)
]=]
return function(values: { any }): Types.Action
	return Action(function(instance: Instance)
		Debugger.Assert(type(values) == "table", "InvalidType", "table", type(values))
		instance.Destroying:Once(function()
			for _, value in values do
				Helper(value)
			end
		end)
	end)
end
