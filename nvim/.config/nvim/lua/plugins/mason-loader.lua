return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				automatic_installation = true,
				automatic_enable = true,
				ensure_installed = {
					"cssls",
					"biome",
					"html",
					"jsonls",
					"tailwindcss",
					"prettier",
					"biome",
					"stylelua",
					"clangd",
					"ruff",
					"pyright",
				},
			})
		end,
	},
}
