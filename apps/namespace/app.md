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
    {},  -- For future use
    {
        Icon = "rbxassetid://0000",
        Name = "An Application",
        Frame = script.Parent.UI,
        Tip = "This application does something.",
        HasBG = true,
        BGOverride = "rbxassetid://0000" --// If this is nil, a blurred version of the Icon will be used.
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

For interacting with Administer once an app is created, see [BuiltAPI](./builtapi.md).

## `AppConfig`

::: warning
This feature is not available yet.
:::

Returns some useful information about how Administer sees your app, and whatever you pass through with OnBuild.

Settings may be tweaked based on user input.

::: code-group

```lua [Annotation]
{
    BuildTime:          number,  --// The time it took to extract and run your app
    TempLinkID:         GUID,    --// The ID Administer uses to link your button to the frame.
    PersistentLinkID:   GUID,    --// The ID Administer uses to keep track of permissions (persists through sessions)
    InstalledOn:        number,  --// Install time in Unix
    InstallSource:      string,  --// Install source app server URL
    Settings:           table {  --// The settings for your app, whatever you gave through BuildApp
        IsModified:     boolean, --// Has been modified?
        LastMofidied:   number,  --// Modification time in Unix
        [...]
    }    
}
```

:::

## `Setting`

::: warning
This feature is not available yet.
:::

A standard Administer setting entry, usually part of a larger `Settings` scheme.

::: code-group

```lua [Annotation]
[SettingName: string] = {
    DisplayName:     string                                                               --// Optionally, display a name which is different to SettingName.
    Type:            string "NumberRange" | "Boolean" | "String" | "KeyCode" | "Dropdown" --// The type of setting.
    Description:     string                                                               --// The setting display description.
    RequiresRestart: boolean                                                              --// Requires a restart to take effect? Purely visual.
    Value:           string | number                                                      --// The default value of the setting. Use this to read the edited value too.

    --// Type-dependent values:
    DD_Values:       table                                                                --// The values for use in dropdown tables.
    KC_Permitted:    string                                                               --// The permitted keycode values ("ABCDEFG", "RightShift", "F4", ...)
}
```

:::

