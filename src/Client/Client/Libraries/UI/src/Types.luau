export type Animatable =
	boolean
	| number
	| CFrame
	| Vector3
	| Vector2
	| UDim2
	| UDim
	| Color3
	| ColorSequence
	| NumberSequence
	| NumberRange

export type Action = (instance: Instance, ...any) -> ()

export type Constructor<T, U> = {
	_Type: string,
	_Bind: (self: T, prop: string, instance: Instance) -> (),
	Get: (self: T) -> U,
	Destroy: (self: T) -> (),
}

export type StateExport = {
	Set: (self: StateExport, value: any) -> State,
	Listen: (self: StateExport, listener: (new: any, old: any) -> ()) -> () -> (),
} & Constructor<StateExport, any>

export type State = typeof(setmetatable(
	{} :: {
		_Type: "State",
		_Value: any,
		_Listeners: { (newValue: any, oldValue: any) -> () },
	},
	{} :: { __index: StateExport }
))

export type SpringExport = {
	Stop: (self: SpringExport) -> (),
} & Constructor<SpringExport, Animatable>

export type Spring = typeof(setmetatable(
	{} :: {
		_Type: "Spring",
		_Goal: StateExport,
		_Damping: number,
		_Frequency: number,
		_Instances: { Instance },
	},
	{} :: { __index: SpringExport }
))

export type ComputedExport = Constructor<ComputedExport, any>

export type Computed = typeof(setmetatable(
	{} :: {
		_Type: "Computed",
		_Processor: (use: (value: State | any) -> ()) -> (),
		_Value: any,
		_Dependencies: { State | Spring },
		_Instances: { [string]: Instance }?,
	},
	{} :: { __index: ComputedExport }
))

return {}
