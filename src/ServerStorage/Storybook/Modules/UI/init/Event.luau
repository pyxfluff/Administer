-- Variables
local Root = script.Parent
local Action = require(Root.Action)
local Debugger = require(Root.Parent.roblox_packages.debugger)
local Types = require(Root.Types)

-- Functions
local function Find(instance: Instance, property: string)
	return (instance :: any)[property]
end

-- Module

--[=[
	Connects a callback to an event on the instance.

	[Open Documentation](https://lumin-org.github.io/ui/api/keys/#event)
]=]
return function(event: string, callback: (...any) -> ()): Types.Action
	return Action(function(instance: Instance)
		local Success, Event = pcall(Find, instance :: any, event :: any) -- Ensure event exists
		if not Success or type(callback) ~= "function" then Debugger.Fatal("InvalidPropOrEvent", event) end
		Event:Connect(callback)
	end)
end
