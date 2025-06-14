return {
	"zaldih/themery.nvim",
	lazy = false,
	config = function()
		require("themery").setup({
			themes = { "rose-pine", "catppuccin", "gruvbox", "kanagawa", "dracula", "nightfox", "tokyonight" },
			livePreview = true,
		})
	end,
}
