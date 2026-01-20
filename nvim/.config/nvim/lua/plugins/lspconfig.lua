return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "folke/neodev.nvim", opts = {} },
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		-- Format on save logic
		local on_attach = function(client, bufnr)
			if client.server_capabilities.documentFormattingProvider then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = vim.api.nvim_create_augroup("Format", { clear = true }),
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ bufnr = bufnr })
					end,
				})
			end
		end

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim", "require" } },
					workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					telemetry = { enable = false },
				},
			},
		})
		vim.lsp.enable("lua_ls")

		local servers = {
			"cssls",
			"tailwindcss",
			"html",
			"jsonls",
			"biome",
			"pyright",
			"gdscript",
			"ts_ls",
			"ruff",
		}

		for _, server_name in ipairs(servers) do
			vim.lsp.config(server_name, {
				on_attach = on_attach,
				capabilities = capabilities,
			})
			vim.lsp.enable(server_name)
		end
	end,
}
