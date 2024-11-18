# What is Administer?

## What is it?

Administer is an admin system which takes modularity to a level never seen before. You only keep what you need. Don't need announcements? Get rid of it.
We also have a modern and consistient admin panel which does everything you'll ever need from any panel.

## Donations

**Administer is and will forever be free.** However, development costs money and I have spent over 250+ hours working to make Administer the best it can be. Because of this, we offer Robux donations so you can name your own price for a system which otherwise would likely cost over 20000 Robux to license for your game.

All donations go right back into Administer's development expenses and the team will be eternally grateful for any contributions. 

https://www.roblox.com/games/5121280629/Administer-donations#!/store

## Why Administer?

See our handy comparison chart here. See something missing or incorrect? Let us know.

| Function                                                 | Administer        | HD Admin                                    | BAE *1             | Commander                         | Product: exe.                 | Cmdr                         |
|----------------------------------------------------------|-------------------|--------------------------------------------|--------------------|-----------------------------------|--------------------------------|------------------------------|
| Fully-featured admin panel                               | ✅                | ❔ (doesn't really do anything)             | ✅                 | ✅                                 | ✅                             | ❌                           |
| Easy rank management (in the panel)                      | ✅                | ❌ (can't edit)                             | ❌                 | ❌                                 | ❌               | ❌                           |
| Command bar                                              | ❌ (in progress)  | ✅                                         | ✅                 | ❌                                 | ❌                             | ✅                           |
| Actively maintained                                      | ✅                | ❌                                         | ❌                 | ❌                                 | ✅                             | ✅                           |
| Advanced features (server listing, joining players, etc) | ✅                | ✅ (some)            | ❌                 | ❌                                 | ❌                             | ❔ (if you make it)                           |
| Fully modular (can add/remove core commands)             | ✅                | ❌ (stops you)                              | ❌                 | ❔ (untested)                      | ❌                             | ✅                           |
| Themes                                                   | ❌ (very soon!)   | ❔ (basic colors)                           | ❌                 | ✅                                 | ❌                             | ❌                           |
| Backdoor                                                 | ❌                | ✅                                         | ❌                 | ❌                                 | ✅                             | ❌                           |
| Fully editable source with clean code                    | ✅                | ❌ (it'll stop you)                         | ❌                 | ❌ (source was removed from GH) | ❔ (source is not on GitHub)   | ✅                           |
| Open API for adding functions as if they're official     | ✅                | ❌                                         | ❔ (don't think so) | ❌ (documentation is a dead link)  | ❌                             | ✅  |

<small>

*1 Information on BAE is limited on the forum. I found [a tutorial on how to use it](https://devforum.roblox.com/t/the-ultimate-basic-admin-essentials-guide/3019051?u=pyxfluff) but that's about it. The loader has an update date of 7/2017 so I'm assuming it is not maintained. [The module](https://create.roblox.com/store/asset/563619835/BAE-20-Module) is showing me a 404.

</small>

## Our current library of apps

New apps are added all the time! Check back here or on the Marketplace to see our latest.

### Player Management

Manage your game's players from any server. Send messages, kick, ban, and create warnings from anywhere.

### Announcements

Send announcements globally from any server. Pick specific servers and user IDs to limit who gets the message.

### Team Manager

Manage your game's teams with support for saving.

## Installation

::: danger
Administer will NOT boot without access to Studio APIs and HTTPService!  
**Do NOT report any bugs if you see errors related to API access denied.**

If you are seeing errors about syntax errors or failing modules from Administer's internals, please verify your configuration is still valid Lua syntax.
:::

Administer is ready to go out of the box. Just install it from the Creator Store and place the script in [ServerScriptStorage](https://create.roblox.com/docs/reference/engine/classes/ServerScriptService).
After that, you'll instantly be ready to go and add apps to your heart's content.

The game's owner account/group will automatically be added as an admin.  
You can configure additional admins in the Admins script or in the panel **(recommended)**.

## Contributions

Contributions are more than welcome (i'm just one person!) and will be reviewed shortly. We use Rojo so it's an easy sync (given you have the proper setup).

Feeling nice? Add a feature from [our development priorities](https://trello.com/b/GA5Kc0vB/administer). Want to fix a bug? Just push the fix. 

If you're adding a new feature, you may want to open an issue before coding something. We may deny PRs if it does not contribute to the project in a way an app can't. If you want an app on the main app server please [reach out to me](https://discord.com/users/449950252397494274).

## Credits

Administer is mostly developed with :heart: by [@pyxfluff](https://github.com/pyxfluff). Some apps are by other Administer team members. We also use multiple OSS resources, such as:

- UICons: FlatIcon
- QuickBlur: [@pixe_ated](https://devforum.roblox.com/u/pixe_ated)
- MUI Button Animations: [@Qinrir](https://devforum.roblox.com/u/Qinrir)
- neon: [@fractality](https://devforum.roblox.com/u/fractality)
- Server finder base logic: [@kylerzong](https://devforum.roblox.com/u/kylerzong)
