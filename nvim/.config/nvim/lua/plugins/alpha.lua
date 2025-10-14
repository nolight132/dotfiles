return {
	"goolord/alpha-nvim",
	dependencies = {
		"echasnovski/mini.icons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local dashboard = require("alpha.themes.dashboard")

		_Gopts = {
			position = "center",
			hl = "Type",
			wrap = "overflow",
		}

		local function load_header()
			local ok, module = pcall(require, "custom.alpha.bawi")
			if ok and module.header then
				return module.header
			else
				return nil
			end
		end

		local header = load_header()

		dashboard.config.layout[2] = header

		require("alpha").setup(dashboard.config)
		-- require("alpha").setup(require("alpha.themes.theta").config)
	end,
}
