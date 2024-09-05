# Detailed Application Documentation

## App

### `App.ActivateUI`

::: warning
This method is meant for internal use only. No support will be provided if you have issues with it.
:::

::: code-group

```lua [Annotation]
ActivateUI(UI: Frame): nil
```

```lua [Example]
ActivateUI(script.Parent.NewUI)
```

:::

Activates the specified Application UI, will create the `AdministerApps` folder if it doesn't exist already.


### `App.Build`

::: code-group

```lua [Annotation]
Build(OnBuild: Function, AppConfig: Table, AppButton: Table): nil
```

```lua [Example]
Build(
    function (AppConfig, BuiltAPI)
        print(AppConfig, BuiltAPI)
    end,
    {},  -- For future release
    {
        Icon = "rbxassetid://0000",
        Name = "An Application",
        Frame = script.Parent.UI,
        Tip = "This application does something.",
        HasBG = true,
        BGOverride = "rbxassetid://0000"
    }
)
```

:::

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

::: code-group

```lua [Annotation]
NewNotification(
    Notifications: Table {
        Player: Player,
        Body: string,
        HeaderText: string,
        Icon: string?,
        OpenDuration: number?,
        Buttons: Table?,
        NotificationVisibility: "PLAYER" | "ALL_ADMINS",
        ShelfVisibility: "FOR_TARGET" | "ALL_ADMINS" | "DO_NOT_DISPLAY",
        NotificationPriority: "CRITICAL" | "NORMAL" | "LOW"
    }
): nil
```

```lua [Example]
NewNotification({
    game.Players[1],
    "Hello, world!",
    "Alert",
    "rbxassetid://0000",
    5,
    {
        {
            Text = "Click me",
            Icon = "rbxassetid://0000",
            OnClick = function ()
                print("I got clicked!")
            end
        }
    },
    "PLAYER",
    "DO_NOT_DISPLAY",
    "LOW"
})
```

:::

Immediately displays a new notification (or multiple) with the given details.  
If `OpenDuration` is not specified, the close button will be available immediately.  

### `BuiltAPI.AppNotificationBlip`

::: warning
This method is still under development.
:::

### `BuiltAPI.IsAdmin`

::: code-group

```lua [Annotation]
IsAdmin(Player: Player, GroupsList: Table{Number}?): Table
```

```lua [Response]
{
    false,                          -- Is Admin?
    "Found in AdminIDS override",   -- Reasoning
    1,                              -- Rank ID (0 if not applicable)
    "NonAdmin"                      -- Rank Name (generic "NonAdmin" or "Admin" if not applicable)
}
```

:::

::: warning
`GroupsList` exists only as a workaround for a missing Roblox API.  
If you provide a non-admin only group, anyone in it will have full admin access!
:::


### `BuiltAPI.NewRemoteEvent`

::: code-group

```lua [Annotation]
NewRemoteEvent(Name: string, OnServerEvent: Function, ...): RemoteEvent
```

```lua [Example]
NewRemoteEvent(
    "SendMessage",
    function (player, message)
        print(`Message from {player.Name}: {message}`)
    end
)
```

:::

Creates a new [`RemoteEvent`](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) with the given name, callback, and additional arguments.
If an event with the given name already exists, the existing event will be returned without `OnServerEvent` being attached.

If the provided `OnServerEvent` is not a function, it will be ignored.  
Any additional arguments will be passed along to the internal `:Connect` call.

### `BuiltAPI.NewRemoteFunction`

::: code-group

```lua [Annotation]
NewRemoteFunction(Name: string, OnServerInvoke: Function): RemoteFunction
```

```lua [Example]
NewRemoteFunction(
    "GetUselessNumber",
    function (player) return 6 end
)
```

:::

Creates a new [`RemoteFunction`](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) with the given name and callback.
If an event with the given name already exists, the existing event will be returned without `OnServerInvoke` being attached.

If the provided `OnServerInvoke` is not a function, it will be ignored.
