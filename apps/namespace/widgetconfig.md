# WidgetConfig

Creating a widget is easy and will automatically hook into your existing app.

## Setup

To set up your widgets, make sure to have EXACTLY this scheme (or else it either won't get seen by the client or will be deemed invalid):
```
App frame (the one being sent to the client by your App.Build())/
├─ .widgets (Folder)/
│  ├─ .widgetconfig (ModuleScript)
│  ├─ Widget frames (Frame/CanvasGroup)
```

After you have that, you can set up your widgets for client use.

### _generator 

A simple string to specify what your widgets are made for. For now, you can have something like this:

```lua
["_generator"] = "AdministerWidgetConfig-1.0",
```

If you would like to add extra metadata, this is the place. Just make sure to add an extra slash.

::: code-group

```lua [Template]
["_generator"] = "AdministerWidgetConfig-WIDGET_CONFIG_VERS-EXTRA_META",
```

```lua [Example]
["_generator"] = "AdministerWidgetConfig-1.0-Made by @pyxfluff (2024)",
```

:::

### Common values

**Name**: The name that displays on the top of the widget.

**Icon**: The icon to display next to the widget. Putting your app icon here is a good idea.

**CanDiscover**: Whether or not the client will display this in discovery menus. If false, it will not appear otherwise.

**Type**: What the widget is displayed as (`LARGE_BOX` or `SMALL_LABEL_`.)

### SMALL_LABEL

::: warning
This is reserved for a future update. It's best practice to add it, but the client has no way of adding it to their home menu at the moment.
:::

A small label on the homepage.

**RenderFrequency**: How often to update your text.

**DefautltValue**: What to display when `OnRender` has not been called, usually on the homepage selector.

**OnRender**: Returns the content displayed on the widget. MUST return a value or else the call will fail.

::: code-group

```lua [Type annotations]
{
    Type = "SMALL_LABEL",
	RenderFrequency: number,

	DefaultValue: string,
	Name: string,
	Icon: string,

	OnRender: FunctionType
}
```

```lua [Example]
local PassedSeconds = 0

--// ...

{
	["Type"] = "SMALL_LABEL",
	["RenderFrequency"] = 1,

	["DefaultValue"] = "123",
	["Name"] = "Seconds passed since Administer launched",
	["Icon"] = "rbxassetid://000",

	["OnRender"] = function(Player)
		PassedSeconds += 1

        return PassedSeconds
	end
}
```

:::

### LARGE_BOX

A large box on the homescreen.

**BaseUIFrame**: The frame to display within the box. The frame is given corners via a CanvasGroup container.

**OnRender**: A function called one time, when it is initialized. It's best to register events here. 

::: code-group

```lua [Type annotations]
{
    Type = "LARGE_BOX",

	Name: string,
	Icon: string,
	BaseUIFrame: Frame | CanvasGroup,

	OnRender: FunctionType | <Player, UIFrame>
}
```

```lua [Example]
{
	["Type"] = "LARGE_BOX",

	["Name"] = "Example frame",
	["Icon"] = "rbxassetid://000",
    ["BaseUIFrame"] = script.Parent.ExampleFrame
    ["CanDiscover"] = false

	["OnRender"] = function(Player)
        --// ...
	end,
}
```

:::

## Extra goodies, unfinished!

### Command

Command for the command bar.

::: warning
This is reserved for a future update. The API is complete and will probably be changed before launch. It cannot be accessed no matter what.
:::


```lua [Example]
["Moderation+_Ban"] = {
			["ActionName"] = "Ban",
			["Description"] = "Ban a set of users.",
			["FromApp"] = "Configuration",
			["Icon"] = "AppDefaults",
			["Flags"] = {
				{
					["Users"] = {
						["Type"] = "set",
						["Description"] = "A set of users to ban ([1,2,3...])",
						["Required"] = true
					},
					["Reason"] = {
						["Type"] = "string",
						["Description"] = "The reason for the ban.",
						["Required"] = false
					},
					["IsGlobal"] = {
						["Type"] = "bool",
						["Description"] = "Uses the Roblox IsGlobal ban API. Defaults to true.",
						["Required"] = false
					},
				}
			}
		},
```