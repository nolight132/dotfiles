return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- insert options
		cmdline = {
			enabled = true,
		},
		messages = {
			enabled = true,
			view = "mini",
			view_error = "mini",
			view_warn = "mini",
		},
		notify = {
			enabled = true,
			view = "mini",
			view_error = "mini",
			view_warn = "mini",
		},
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
}
