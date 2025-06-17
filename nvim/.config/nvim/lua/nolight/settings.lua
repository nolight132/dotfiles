local global = vim.g
local o = vim.opt

-- Editor options
o.number = true -- Print the line number in front of each line
o.relativenumber = true -- Show the line number relative to the line with the cursor in front of each line.
o.clipboard = "unnamedplus" -- uses the clipboard register for all operations except yank.
o.syntax = "on" -- When this option is set, the syntax with this name is loaded.
o.autoindent = true -- Copy indent from current line when starting a new line.
o.cursorline = true -- Highlight the screen line of the cursor with CursorLine.
o.expandtab = true -- In Insert mode: Use the appropriate number of spaces to insert a <Tab>.
o.fillchars:append({ eob = " " }) -- Set the fill character for end-of-buffer lines to a space.
o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent.
o.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for.
o.encoding = "UTF-8" -- Sets the character encoding used inside Vim.sett
o.ruler = true -- Show the line and column number of the cursor position, separated by a comma.
o.mouse = "a" -- Enable the use of the mouse. "a" you can use on all modes
o.title = true -- When on, the title of the window will be set to the value of 'titlestring'
o.hidden = true -- When on a buffer becomes hidden when it is |abandon|ed
o.ttimeoutlen = 0 -- The time in milliseconds that is waited for a key code or mapped key sequence to complete.
o.wildmenu = true -- When 'wildmenu' is on, command-line completion operates in an enhanced mode.
o.showcmd = false -- Show (partial) command in the last line of the screen. Set this option off if your terminal is slow.
o.showmatch = true -- When a bracket is inserted, briefly jump to the matching one.
o.inccommand = "split" -- When nonempty, shows the effects of :substitute, :smagic, :snomagic and user commands with the :command-preview flag as you type.
o.splitright = true
o.splitbelow = true -- When on, splitting a window will put the new window below the current one
o.termguicolors = true
o.numberwidth = 6
o.signcolumn = "yes:2"

vim.diagnostic.enable()

vim.api.nvim_create_autocmd({ "CursorHold" }, {
	pattern = "*",
	callback = function()
		for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_config(winid).zindex then
				return
			end
		end
		vim.diagnostic.open_float({
			scope = "cursor",
			focusable = false,
			close_events = {
				"CursorMoved",
				"CursorMovedI",
				"BufHidden",
				"InsertCharPre",
				"WinLeave",
			},
		})
	end,
})
-- Add this line to define your statuscolumn
-- '%s' is for the signcolumn
-- '%l' is for the line number (it automatically handles relative/absolute and aligns)
o.statuscolumn = "%s%l    "

local border = "rounded" -- or "single", "double", "solid", etc.

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

-- Set border for diagnostics (floating window)
vim.diagnostic.config({
	float = { border = border },
})

global.mapleader = " "

local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

-- Exit insert mode
map("i", "jk", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle position=right<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")

map("n", "<leader>w", "<CMD>:w<CR>")
map("n", "<leader>q", "<CMD>:q<CR>")

map("n", "<ESC>", ":nohlsearch<CR>")
map("n", "<leader>h", ":nohlsearch<CR>")

map("n", "K", function()
	local has_lsp, result = pcall(vim.lsp.buf.hover)

	if has_lsp and result then
		-- LSP hover was successful, no need to do anything else as
		-- vim.lsp.buf.hover should handle the display
		return
	end

	-- LSP failed, fallback to diagnostic info
	local has_diagnostic, diagnostic_result = pcall(vim.diagnostic.open_float)

	if has_diagnostic and diagnostic_result then
		-- Diagnostic info displayed successfully
		return
	end
end)
map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>")
map("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>")
map("n", "gt", "<CMD>lua vim.lsp.buf.type_definition()<CR>")
map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>")

-- Inline git commands
map("n", "<leader>gd", "<CMD>:Gitsigns preview_hunk_inline<CR>")
map("n", "<leader>gr", "<CMD>:Gitsigns reset_hunk<CR>")

-- Terminal mode mappings
map("t", "jk", "<C-\\><C-n>")
map("n", "<leader>t", ":ToggleTerm<CR>")

-- Project picker
map("n", "<leader>p", function()
	require("telescope").extensions.project.project({})
end)

-- Tabs
map("n", "<leader>,", "<Cmd>BufferPrevious<CR>")
map("n", "<leader>.", "<Cmd>BufferNext<CR>")
map("n", "<leader>c", "<Cmd>BufferClose<CR>")
map("n", "<leader><", "<Cmd>BufferMovePrevious<CR>")
map("n", "<leadear>>", "<Cmd>BufferMoveNext<CR>")

-- Re-order buffers
map("n", "<leader><", "<Cmd>BufferMovePrevious<CR>")
map("n", "<leader>>", "<Cmd>BufferMoveNext<CR>")

-- Goto buffer in position...
map("n", "<leader>1", "<Cmd>BufferGoto 1<CR>")
map("n", "<leader>2", "<Cmd>BufferGoto 2<CR>")
map("n", "<leader>3", "<Cmd>BufferGoto 3<CR>")
map("n", "<leader>4", "<Cmd>BufferGoto 4<CR>")
map("n", "<leader>5", "<Cmd>BufferGoto 5<CR>")
map("n", "<leader>6", "<Cmd>BufferGoto 6<CR>")
map("n", "<leader>7", "<Cmd>BufferGoto 7<CR>")
map("n", "<leader>8", "<Cmd>BufferGoto 8<CR>")
map("n", "<leader>9", "<Cmd>BufferGoto 9<CR>")
map("n", "<leader>0", "<Cmd>BufferLast<CR>")

-- Pin/unpin buffer
map("n", "<leader>s", "<Cmd>BufferPin<CR>")
