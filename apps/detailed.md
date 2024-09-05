# Detailed Application Documentation

## App

### `App.ActivateUI`

::: warning
This method is meant for internal use only. No support will be provided if you have issues with it.
:::

```lua
ActivateUI(UI: Frame): nil
```

Activates the specified Application UI, will create the `AdministerApps` folder if it doesn't exist already.


### `App.Build`
```lua
Build(OnBuild: Function, AppConfig: Table, AppButton: Table): nil
```

Build the specified app using the given `AppConfig`, will run `OnBuild` after building as follows:
```lua
local function OnBuild(AppConfig, BuiltAPI)
    -- AppConfig will be the same as you specified in `App.Build`
end
```

For documentation about `BuiltAPI`, see [BuiltAPI](#builtapi).

## BuiltAPI

### `BuiltAPI.NewNotification`

::: warning
This method is still under development.
:::

```lua
NewNotification(Admin: Player, Body: string, Heading: string, Icon: string?, Duration: number?, Options: Table?, OpenTime: int?): nil
```

Immediately displays a new notification with the given details.  

If `Duration` is not specified, the close button will be available immediately.  
If `OpenTime` is not specified, it will default to 1.25.

---

Syntax for the `Options` parameter:
```lua
{
    {
        Text = "Click me",
        Icon = "rbxassetid://0000",
        OnClick = function ()
            print("I got clicked!")
        end
    }
}
```

### `BuiltAPI.AppNotificationBlip`

::: warning
This method is still under development.
:::

```lua
AppNotificationBlip(Player: Player, Count: int): nil | Table
```

### `BuiltAPI.IsAdmin`

```lua
IsAdmin(Player: Player): Table
```

Check if the given player is an administrator, returns a `Table`: 
```lua
{
    false,                          -- Is Admin?
    "Found in AdminIDS override",   -- Reasoning
    1,                              -- Rank ID (0 if not applicable)
    "NonAdmin"                      -- Rank Name (generic "NonAdmin" or "Admin" if not applicable)
}
```

### `BuiltAPI.NewRemoteEvent`

```lua
NewRemoteEvent(Name: string, OnServerEvent: Function, ...): RemoteEvent
```

Creates a new [`RemoteEvent`](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) with the given name, callback, and additional arguments.
If an event with the given name already exists, the existing event will be returned without `OnServerEvent` being attached.

If the provided `OnServerEvent` is not a function, it will be ignored.  
Any additional arguments will be passed along to the internal `:Connect` call.

### `BuiltAPI.NewRemoteFunction`

```lua
NewRemoteFunction(Name: string, OnServerInvoke: Function): RemoteFunction
```

Creates a new [`RemoteFunction`](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) with the given name and callback.
If an event with the given name already exists, the existing event will be returned without `OnServerInvoke` being attached.

If the provided `OnServerInvoke` is not a function, it will be ignored.
