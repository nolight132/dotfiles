-- Undercurl
vim.opt.termguicolors = true
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#e06c75" }) -- Red
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#e5c07b" }) -- Yellow/Orange
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#61afef" }) -- Blue
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#98c379" }) -- Green

local border = "rounded"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
-- Map Neovim's diagnostic severities to your custom highlight groups
vim.diagnostic.config({
	virtual_text = true, -- Show virtual text for diagnostics
	signs = true, -- Show signs in the sign column
	underline = true, -- Enable underline for diagnostics
	update_in_insert = false, -- Don't update diagnostics in insert mode
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
	-- Define the highlight groups for each diagnostic severity
	-- These implicitly use the highlight groups named `DiagnosticUnderlineX`.
	-- You don't need to explicitly link handlers here for the underline
	-- unless you're doing something highly custom. `underline = true`
	-- combined with correctly defined `DiagnosticUnderlineX` highlights is usually enough.
	-- However, keeping the handlers here is harmless if they were there before.
	handlers = {
		["text"] = vim.diagnostic.handlers.virtual_text,
		["signs"] = vim.diagnostic.handlers.signs,
		["underline"] = vim.diagnostic.handlers.underline,
	},
})
