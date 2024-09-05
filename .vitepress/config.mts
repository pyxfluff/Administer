import { defineConfig } from "vitepress"

export default defineConfig({
    title: "Administer",
    description: "Administer's official documentation",
    
    themeConfig: {
        nav: [
            { text: "Home", link: "/" },
            { text: "Examples", link: "/markdown-examples" }
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
                    { text: "Detailed API", link: "/apps/detailed" }
                ],
                collapsed: false
            }
        ],
        socialLinks: [
            { icon: "github", link: "https://github.com/pyxfluff/administer" }
        ]
    }
})
