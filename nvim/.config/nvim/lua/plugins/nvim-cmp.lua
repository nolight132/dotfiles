return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		-- Required sources for nvim-cmp:
		"hrsh7th/cmp-nvim-lsp", -- LSP source (for language server suggestions)
		"hrsh7th/cmp-buffer", -- Buffer source (for words in current/other buffers)
		"hrsh7th/cmp-path", -- Path source (for file path completion)
		"saadparwaiz1/cmp_luasnip", -- Luasnip source (for snippet completion)
		"L3MON4D3/LuaSnip",
		"onsails/lspkind.nvim",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")
		local kind_icons = {
			Text = "",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰇽",
			Variable = "󰂡",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜢",
			Unit = "",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "󰅲",
		}
		cmp.setup({
			-- Completion menu settings
			enabled = function()
				if vim.g.autocomplete == nil then
					vim.g.autocomplete = true
				end
				return vim.g.autocomplete
			end,

			completion = {
				completeopt = "menu,menuone,noselect", -- How the completion menu behaves
			},

			-- Mapping (keybindings)
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
				["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),

				-- Crucial Tab mapping:
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						-- If completion menu is visible, accept the selected item
						cmp.confirm({ select = true })
					elseif luasnip.expand_or_jumpable() then
						-- If there's an expandable snippet or a jumpable placeholder
						luasnip.expand_or_jump()
					else
						-- No completion or snippet, so fallback to default Neovim Tab behavior (indentation)
						fallback()
					end
				end, { "i", "s" }), -- Apply in Insert ('i') and Snippet ('s') modes

				-- Optional Shift+Tab for reverse cycling or snippet navigation
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						-- Select previous item in completion menu
						cmp.select({ behavior = cmp.SelectBehavior.Select, direction = cmp.Direction.Prev })
					elseif luasnip.locally_jumpable(-1) then
						-- Jump to previous snippet placeholder
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),

			-- Sources: Order matters! CMP tries sources in the order they are listed.
			-- Common order: LSP, snippets, buffer, path.
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- Language Server Protocol (LSP)
				{ name = "luasnip" }, -- Snippets
				{ name = "buffer" }, -- Words from current and other open buffers
				{ name = "path" }, -- File paths
				{ name = "copilot" }, -- Add this if you're using zbirenbaum/copilot.lua and copilot-cmp
			}),

			-- Formatting: How completion items look
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)

					-- Check if the source is Copilot and customize the icon for 'ai' suggestions
					if entry.source.name == "copilot" then
						vim_item.kind = ""
						vim_item.menu = " Copilot"
					end

					-- Split the kind and format it
					local strings = vim.split(kind.kind, "%s", { trimempty = true })
					kind.kind = " " .. (strings[1] or "") .. " "
					kind.menu = "    (" .. (strings[2] or "") .. ")"

					return kind
				end,
			},
			-- Customization for window (completion menu)
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})

		-- Optional: Set up LuaSnip for common filetypes if you haven't done so elsewhere
		luasnip.setup({
			history = true,
			update_events = "textchanged",
			-- Add more luasnip configuration here if needed
		})

		-- You might also want to load some default snippets
		-- require('luasnip.loaders.from_vscode').lazy_load()
	end,
}
