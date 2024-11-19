import { defineConfig } from "vitepress"

export default defineConfig({
    title: "Administer",
    titleTemplate: ":title · Documentation",
    description: "Administer's full documentation. Learn how to make your own app and more.",
    lang: "en-US",
    head: [["link", { rel: "icon", href: "/logo.png" }], ["meta", { name: "darkreader-lock" }]],
    cleanUrls: true,
    themeConfig: {
        logo: "/logo.png",
        nav: [
            { text: "Home", link: "/" },
            { text: "About", link: "/what-is-administer" },
            {
                text: "Application API",
                items: [
                    { text: "Quickstart", link: "/apps/quickstart" },
                    {
                        text: "Namespaces",
                        items: [
                            { text: "App", link: "/apps/namespace/app" },
                            { text: "BuiltAPI", link: "/apps/namespace/builtapi" }
                        ]
                    }
                ]
            }
        ],
        sidebar: [
            {
                text: "Administer",
                items: [
                    { text: "What is Administer?", link: "/what-is-administer" },
                ],
                collapsed: false
            },
            {
                text: "Application API",
                items: [
                    { text: "Quickstart", link: "/apps/quickstart" },
                    {
                        text: "APIs",
                        items: [
                            { text: "App", link: "/apps/namespace/app" },
                            { text: "BuiltAPI", link: "/apps/namespace/builtapi" },
                            { text: ".widgetconfig", link: "/apps/namespace/widgetconfig" },
                            { text: "Settings API", link: "/apps/namespace/settings" }
                        ],
                        collapsed: false
                    }
                ],
                collapsed: false
            }
        ],
        socialLinks: [
            { icon: "github", link: "https://github.com/pyxfluff/administer" },
            { icon: "discord", link: "https://discord.gg/c8dC4k3J5Y" },
            { icon: "bluesky", link: "https://bsky.app/profile/notpyx.me" },
            { icon: { svg: '<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" width="477" height="477" viewBox="0 0 134.86717 134.86723"><g transform="translate(-0.31047259,-0.31047345)"><path transform="matrix(4.2145936,0,0,4.2145936,0.2065483,-3.8001967)" d="M 6.78817,0.975342 3.21606,14.3004 l 9.09084,2.4333 1.1355,-4.2343 16.1457,4.327 2.4366,-9.08756 z M 18.6069,21.448 2.46124,17.1211 0.0246582,26.2119 25.2611,32.9754 28.8332,19.6504 19.7424,17.2138 Z"/></g></svg>' }, link: "/" },
    ]
})
