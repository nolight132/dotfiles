return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		config = function()
			require("rose-pine").setup({
				variant = "auto",
				dark_variant = "main",

				enable = {
					terminal = true,
					migrations = true,
				},

				styles = {
					bold = false,
					italic = false,
					transparency = false,
				},

				palette = {
					main = {
						pine = "#c4a7e7",
					},
				},

				highlight_groups = {
					TelescopeBorder = { fg = "muted", bg = "none" },
					TelescopeNormal = { bg = "none" },
					TelescopePromptNormal = { bg = "base" },
					TelescopeResultsNormal = { fg = "subtle", bg = "none" },
					TelescopeSelection = { fg = "text", bg = "base" },
					TelescopeSelectionCaret = { fg = "rose", bg = "rose" },

					Delimiter = { fg = "muted" },
					Punctuation = { fg = "muted" },

					-- Special = { underline = false },
					-- Identifier = { underline = false },
					-- Constant = { underline = false },
				},
			})
		end,
	},
	-- Catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = { --
				light = "latte",
				dark = "mocha",
			},
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				which_key = true,
				-- Add other plugin integrations you use
			},
		},
	},

	-- Gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		name = "gruvbox",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				-- Configure Gruvbox here, e.g.:
				-- transparent_mode = false,
				-- palette_overrides = {},
				-- theme_toggle = "gruvbox_light",
				-- color_overrides = {},
				-- keywords = "bold",
			})
		end,
	},

	-- Other popular themes (uncomment and configure as needed)

	-- Tokyo Night
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		priority = 1000,
		opts = {
			style = "moon", -- storm, moon, night, day
			transparent = false,
			terminal_colors = true,
			-- Configure integrations here as well
		},
	},

	-- Dracula
	{
		"dracula/vim", -- The official Dracula theme
		name = "dracula",
		priority = 1000,
		config = function()
			-- Dracula doesn't have a specific setup function in Lua,
			-- you just set the colorscheme.
			-- This plugin is primarily Vimscript, but works with Neovim.
		end,
	},

	-- Nightfox / Dayfox (a family of themes)
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
		priority = 1000,
		config = function()
			require("nightfox").setup({
				options = {
					-- Enable transparent background
					transparent = false,
					-- Disable italic comments
					italic_comments = true,
					-- Complementary colors
					styles = {
						comments = "italic",
						keywords = "bold",
						types = "italic,bold",
					},
					inverse = {
						match_paren = true,
						visual = true,
						search = true,
					},
					-- Change the main color palette
					colorscheme = "nightfox", -- nordfox, terafox, carbonfox, dawnfox, dayfox, duskfox, nightfox
					-- Enable bold for all highlights
					bold_vert_split = false,
				},
			})
		end,
	},

	-- Kanagawa
	{
		"rebelot/kanagawa.nvim",
		name = "kanagawa",
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				transparent = true,
				compile = true, -- Enable for faster startup
				theme = "wave", -- wave, dragon, lotus
			})
		end,
	},
}
