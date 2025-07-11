return {
	"nvim-lualine/lualine.nvim",
	opts = {
		options = {
			globalstatus = false,
			theme = "auto",
			laststatus = 2,
			section_separators = "",
			component_separators = "",
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { "filename", "diagnostics" },
			lualine_x = {
				{
					function()
						return require("noice").api.status.command.get()
					end,
					cond = function()
						return package.loaded["noice"] and require("noice").api.status.command.get() ~= ""
					end,
					color = { fg = "#888888" }, -- Optional: customize color
				},
				"filetype",
				require("lualine.components.indent_mode"),
				"lsp_status",
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
	},
}
