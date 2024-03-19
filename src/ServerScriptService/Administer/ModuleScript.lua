export type PluginButton<AdministerPluginButton> = {
	Title: string,
	Body: string,
	Image: string?,
	Buttons: {
		ButtonOne: {
			Label: string,
			Action: Function
		},
		ButtonTwo: {
			Label: string,
			Action: Function
		}
	},
	OnDismiss: Function?
}

