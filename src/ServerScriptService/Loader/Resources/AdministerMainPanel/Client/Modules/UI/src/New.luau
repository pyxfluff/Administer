-- Variables
local Root = script.Parent
local Apply = require(Root.Apply)
local Debugger = require(Root.Parent.roblox_packages.debugger)
local Defaults = require(Root.Defaults)

-- Module

--[=[
	Creates a new instance with the provided properties.

	[Open Documentation](https://lumin-org.github.io/ui/api/#new)
]=]
return function(class: string)
	Debugger.Assert(type(class) == "string", "InvalidType", class, "invalid")
	return function(props: { any }): Instance
		local Success, New = pcall(Instance.new, class)

		if Success then
			-- Apply default properties
			if Defaults[class] then
				for prop, value in Defaults[class] do
					(New :: any)[prop] = value
				end
			end

			if props then
				for prop, value in props :: any do
					if prop == "Parent" then
						continue
					end
					Apply(New, prop, value)
				end

				if (props :: any).Parent then
					New.Parent = (props :: any).Parent
				end
			end
		else
			Debugger.Fatal("InvalidClass", class)
		end

		return New
	end
end
