# BuiltAPI

### `BuiltAPI.NewNotification`

::: warning
Some methods are reserved for future use (such as NotificationVisibility).
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
    ["Player"] = game.Players[1],
    ["Body"] = "Hello, world!",
    ["HeaderText"] = "Alert",
    ["Icon"] = "rbxassetid://0000",
    ["OpenDuration"] = 5,
    ["Buttons"] = {
        {
            Text = "Click me",
            Icon = "rbxassetid://0000",
            OnClick = function ()
                print("I got clicked!")
            end
        }
    },
    ["NotificationVisibility"] = "PLAYER",
    ["ShelfVisibility"] = "DO_NOT_DISPLAY",
    ["NotificationPriority"] = "LOW"
})
```

:::

Immediately displays a new notification (or multiple) with the given details.  
If `OpenDuration` is not specified, the close button will be available immediately.  

### `BuiltAPI.AppNotificationBlip`

::: warning
This method is still under development and it is reserved for future use.
:::

Creates a new notification icon on your app's tile. Does not persist over saves.

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
    ["Player"] = game.Players[1],
    ["Body"] = "Hello, world!",
    ["HeaderText"] = "Alert",
    ["Icon"] = "rbxassetid://0000",
    ["OpenDuration"] = 5,
    ["Buttons"] = {
        {
            Text = "Click me",
            Icon = "rbxassetid://0000",
            OnClick = function ()
                print("I got clicked!")
            end
        }
    },
    ["NotificationVisibility"] = "PLAYER",
    ["ShelfVisibility"] = "DO_NOT_DISPLAY",
    ["NotificationPriority"] = "LOW"
})
```

:::

## `BuiltAPI.IsAdmin`

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


## `BuiltAPI.NewRemoteEvent`

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

## `BuiltAPI.NewRemoteFunction`

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
