import { defineConfig } from "vitepress"

export default defineConfig({
    title: "Administer",
    titleTemplate: ":title · Administer",
    description: "Administer's official documentation",
    lang: "en-US",
    head: [["link", { rel: "icon", href: "/logo.png" }], ["meta", { name: "darkreader-lock" }]],
    cleanUrls: true,
    themeConfig: {
        logo: "/logo.png",
        nav: [
            { text: "Home", link: "/" },
            { text: "Application API", link: "/apps/quickstart" }
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
                        text: "Namespaces",
                        items: [
                            { text: "App", link: "/apps/namespace/app" },
                            { text: "BuiltAPI", link: "/apps/namespace/builtapi" }
                        ],
                        collapsed: false
                    }
                ],
                collapsed: false
            }
        ],
        socialLinks: [
            { icon: "github", link: "https://github.com/pyxfluff/administer" }
        ]
    }
})
