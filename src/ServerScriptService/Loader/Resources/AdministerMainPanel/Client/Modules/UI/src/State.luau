-- Variables
local Root = script.Parent
local Types = require(Root.Types)
local Debugger = require(Root.Parent.roblox_packages.debugger)

local Class = {}
Class.__index = Class

-- Functions

--[=[
	Returns the current value of the object.

	[Open Documentation](https://lumin-org.github.io/ui/api/state/#get)
]=]
function Class.Get(self: Types.State): any
	return self._Value
end

--[=[
	Sets the current value of the object.

	[Open Documentation](https://lumin-org.github.io/ui/api/state/#set)
]=]
function Class.Set<T>(self: Types.State, newValue: T): T
	Debugger.Assert(type(newValue) ~= "table", "InvalidType", "any", "table")

	local OldValue = self._Value

	-- Don't waste resources is new value is the same as old
	if self._Value == newValue then
		return newValue
	end

	self._Value = newValue

	-- Run all listeners when the value is changed
	for _, fn in self._Listeners do
		task.spawn(fn, newValue, OldValue)
	end

	return newValue
end

--[=[
	Listens to changes of state within the object.

	[Open Documentation](https://lumin-org.github.io/ui/api/state/#listen)
]=]
function Class.Listen(self: Types.State, listener: (new: any, old: any) -> ()): () -> ()
	table.insert(self._Listeners, listener) -- Add listener
	return function() -- Disconnect the listener
		local Listener = table.find(self._Listeners, listener)
		if Listener then
			table.remove(self._Listeners, Listener)
		end
	end
end

function Class._Bind(self: Types.State, prop: string, instance: Instance)
	(instance :: any)[prop] = self._Value; -- Set the prop initially to the current value
	(self :: any):Listen(function(newValue)
		(instance :: any)[prop] = newValue -- Change the prop to the new value when the state is changed
	end)
end

--[=[
	Destroys the value object.

	[Open Documentation](https://lumin-org.github.io/ui/api/state/#destroy)
]=]
function Class.Destroy(self: Types.State)
	table.clear(self :: any)
	setmetatable(self :: any, nil)
end

-- Module

--[=[
	Creates a new value/state object that dynamically changes in UI when changed itself.

	[Open Documentation](https://lumin-org.github.io/ui/api/#state)
]=]
return function(initial: any): Types.StateExport
	Debugger.Assert(type(initial) ~= "table", "InvalidType", "any", "table")

	local self = setmetatable({}, Class)

	self._Type = "State"
	self._Value = initial
	self._Listeners = {}

	return self :: any
end
