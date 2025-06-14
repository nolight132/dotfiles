return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter", -- Lazy load on entering insert mode
	config = function()
		local copilot = require("copilot") -- Assign the copilot module to a local variable

		copilot.setup({
			suggestion = {
				enabled = false,
			},
			panel = {
				enabled = false, -- Disable built-in panel if using copilot-cmp
			},
			filetypes = {
				yaml = false,
				markdown = false,
				help = false,
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
			auth_provider_url = nil,
			copilot_node_command = "node",
			workspace_folders = {},
			copilot_model = "",

			server = {
				type = "nodejs",
				custom_server_filepath = nil,
			},
			server_opts_overrides = {},
		})
	end,
}
