import { defineConfig } from "vitepress"

export default defineConfig({
    title: "Administer",
    titleTemplate: ":title · Documentation",
    description: "Administer's official documentation",
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
                            { text: ".widgetconfig", link: "/apps/namespace/widgetconfig" }
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
            { icon: { svg: '<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" width="477" height="477" viewBox="0 0 134.86717 134.86723"><g transform="translate(-0.31047259,-0.31047345)"><path transform="matrix(4.2145936,0,0,4.2145936,0.2065483,-3.8001967)" d="M 6.78817,0.975342 3.21606,14.3004 l 9.09084,2.4333 1.1355,-4.2343 16.1457,4.327 2.4366,-9.08756 z M 18.6069,21.448 2.46124,17.1211 0.0246582,26.2119 25.2611,32.9754 28.8332,19.6504 19.7424,17.2138 Z"/></g></svg>' }, link: "/" },
            { icon: { svg: '<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Capa_1" x="0px" y="0px" viewBox="0 0 24 24" style="enable-background:new 0 0 24 24;" xml:space="preserve" width="512" height="512"><path id="Logo_00000038394049246713568260000012923108920998390947_" d="M21.543,7.104c0.014,0.211,0.014,0.423,0.014,0.636  c0,6.507-4.954,14.01-14.01,14.01v-0.004C4.872,21.75,2.252,20.984,0,19.539c0.389,0.047,0.78,0.07,1.172,0.071  c2.218,0.002,4.372-0.742,6.115-2.112c-2.107-0.04-3.955-1.414-4.6-3.42c0.738,0.142,1.498,0.113,2.223-0.084  c-2.298-0.464-3.95-2.483-3.95-4.827c0-0.021,0-0.042,0-0.062c0.685,0.382,1.451,0.593,2.235,0.616  C1.031,8.276,0.363,5.398,1.67,3.148c2.5,3.076,6.189,4.946,10.148,5.145c-0.397-1.71,0.146-3.502,1.424-4.705  c1.983-1.865,5.102-1.769,6.967,0.214c1.103-0.217,2.16-0.622,3.127-1.195c-0.368,1.14-1.137,2.108-2.165,2.724  C22.148,5.214,23.101,4.953,24,4.555C23.339,5.544,22.507,6.407,21.543,7.104z"/></svg>' }, link: "https://twitter.com/pyxfluff"}
        ]
    }
})
