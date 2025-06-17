return {
	"yetone/avante.nvim",
	-- This plugin provides advanced features for development, such as AI assistance and file selection tools.
	-- The "VeryLazy" event ensures that the plugin is only loaded during lazy initialization.
	event = "VeryLazy",
	version = false, -- Never set this value to "*" to avoid unintended updates.
	opts = {
		provider = "copilot", -- Specifies the AI provider for assistance.
		mappings = {
			ask = "<leader>ua", -- ask
			edit = "<leader>ue", -- edit
			refresh = "<leader>ur", -- refresh
		},
	},
	-- If you want to build from source, execute `make BUILD_FROM_SOURCE=true`.
	build = "make", -- Default build command for Unix-based systems.
	-- Use the following command for Windows:
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
	dependencies = {
		-- Core dependencies:
		"nvim-treesitter/nvim-treesitter", -- Syntax highlighting and parsing.
		"nvim-lua/plenary.nvim", -- Utility functions.
		"MunifTanjim/nui.nvim", -- Basic UI components.

		-- Optional dependencies:
		"echasnovski/mini.pick", -- Required for the "mini.pick" file selector provider.
		"nvim-telescope/telescope.nvim", -- Used for file selection with "telescope".
		"hrsh7th/nvim-cmp", -- Autocompletion for Avante commands and mentions.
		"ibhagwan/fzf-lua", -- Enables file selection using "fzf".
		"stevearc/dressing.nvim", -- Enhances input dialogs with "dressing".
		"folke/snacks.nvim", -- Provides input methods using "snacks".
		"nvim-tree/nvim-web-devicons", -- Icon support (alternative: "mini.icons").
		"zbirenbaum/copilot.lua", -- Required for "copilot" provider integration.

		-- Plugin for image pasting:
		{
			"HakonHarnes/img-clip.nvim", -- Enables clipboard-based image handling.
			event = "VeryLazy", -- Lazy load on specific events.
			opts = {
				default = {
					embed_image_as_base64 = false, -- Prevent embedding images as base64.
					prompt_for_file_name = false, -- Avoid prompts for file names.
					drag_and_drop = {
						insert_mode = true, -- Allow drag-and-drop in insert mode.
					},
					use_absolute_path = true, -- Necessary for Windows users.
				},
			},
		},
		-- Markdown rendering plugin:
		{
			"MeanderingProgrammer/render-markdown.nvim", -- Adds rendering support for markdown and Avante files.
			opts = {
				file_types = { "markdown", "Avante" }, -- Defines supported file types.
			},
			ft = { "markdown", "Avante" }, -- File types for lazy loading.
		},
	},
}
