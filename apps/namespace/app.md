# App

## `App.ActivateUI`

::: warning
This method is meant for internal use only and it is not meant to be used for normal projects. No support will be provided if you have issues with it.
:::

Sets Administer's parent frame for adding buttons and notifications. 

::: code-group

```lua [Annotation]
ActivateUI(UI: Frame): nil
```

```lua [Example]
ActivateUI(script.Parent)
```

:::

Activates the specified Application UI, will create the `AdministerApps` folder if it doesn't exist already.


## `App.Build`

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
        BGOverride = "rbxassetid://0000" --// Note: if this is nil, Icon will be used as an override.
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

For documentation about `BuiltAPI`, see [BuiltAPI](./builtapi.md).
