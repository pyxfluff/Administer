# Application Quickstart

Creating an Administer app is about as easy as it can get.

<div class = "tip custom-block" style = "padding-top: 8px">

Need the full documentation? Skip to the [Detailed Documentation](./namespace/app.md).

</div>

## Ideal structure

The recommended structure for an Administer application is like so:
```
Main Module (ModuleScript)/
├─ Content (Folder)/
│  ├─ Main (ServerScript)
```

Inside the Main Module, you should return a Table with both an `OnDownload` and `Init` method, like so:
```lua
return {
    Init = function ()
        script.Test.Parent = game.ServerScriptService.Administer.Apps
        return "Example Application", "An Administer test application.", "v1"
    end,
    OnDownload = function ()
        print("App was pulled!")
    end,
}
```

## Example application

Before you can create an app, you'll need an app configuration:
```lua
local AppConfig = {
    -- This is reserved for future releases
}
```

Afterwards, you should [build your application](./namespace/app.md#app-build) like so:
```lua
App.Build(
    function (config, built)
        print("This is our app config:", config)
        print("This is the Built API:", built)
    end,
    AppConfig,
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
