-- Variables
local Packages = script.Parent.roblox_packages
local Types = require(script.Types)
local Debugger = require(Packages.debugger)

-- Types
export type Action = Types.Action
export type State = Types.State
export type Spring = Types.Spring
export type Computed = Types.Computed
export type Animatable = Types.Animatable

-- Module
Debugger.SetMetadata({
	PackageURL = "https://github.com/lumin-org/ui",
	PackageName = "UI",
})

return table.freeze({
	New = require(script.New),
	Update = require(script.Update),
	State = require(script.State),
	Computed = require(script.Computed),
	Spring = require(script.Spring),
	Action = require(script.Action).New,
	Event = require(script.Event),
	Changed = require(script.Change),
	Tags = require(script.Tags),
	Clean = require(script.Clean),
})
