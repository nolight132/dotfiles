return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			-- These are the configurations for the built-in pickers
			defaults = {
				file_ignore_patterns = { ".git/" },
			},
			pickers = {
				find_files = {
					hidden = true,
				},
				live_grep = {
					hidden = false,
				},
			},
			extensions = {
				project = {
					hidden_files = true, -- Show hidden projects
					-- Command to find projects in hidden directories
					find_command = { "fd", "--type", "d", "--hidden", "--glob", ".git" },
					-- Add the paths where you store your projects
					base_dirs = {
						"/Users/pavelolizko/Documents/Code/personal",
						"/Users/pavelolizko/Documents/Code/external",
						"/Users/pavelolizko/Documents/Code/uni",
						"/Users/pavelolizko/Documents/Code/work",
					},
				},
			},
		})

		telescope.load_extension("project")

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope git_status<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope git commits<cr>", { desc = "Find todos" })
	end,
}
