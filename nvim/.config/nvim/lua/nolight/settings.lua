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
o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent.
o.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for.
o.encoding = "UTF-8" -- Sets the character encoding used inside Vim.
o.ruler = true -- Show the line and column number of the cursor position, separated by a comma.
o.mouse = "a" -- Enable the use of the mouse. "a" you can use on all modes
o.title = true -- When on, the title of the window will be set to the value of 'titlestring'
o.hidden = true -- When on a buffer becomes hidden when it is |abandon|ed
o.ttimeoutlen = 0 -- The time in milliseconds that is waited for a key code or mapped key sequence to complete.
o.wildmenu = true -- When 'wildmenu' is on, command-line completion operates in an enhanced mode.
o.showcmd = true -- Show (partial) command in the last line of the screen. Set this option off if your terminal is slow.
o.showmatch = true -- When a bracket is inserted, briefly jump to the matching one.
o.inccommand = "split" -- When nonempty, shows the effects of :substitute, :smagic, :snomagic and user commands with the :command-preview flag as you type.
o.splitright = true
o.splitbelow = true -- When on, splitting a window will put the new window below the current one
o.termguicolors = true
o.numberwidth = 6

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

map("n", "<ESC>", ":nohlsearch<CR>", { silent = true, desc = "Clear Search Highlight" })
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true, desc = "Clear Search Highlight" })

map("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>", { desc = "Hover Documentation" })
map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
map("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>", { desc = "Go to References" })
map("n", "gt", "<CMD>lua vim.lsp.buf.type_definition()<CR>", { desc = "Go to Type Definition" })
map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to Implementation" })

-- Inline git commands
map("n", "<leader>gd", "<CMD>:Gitsigns preview_hunk_inline<CR>", { desc = "Gitsigns: Preview Hunk Inline" })

map("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true, desc = "Toggle Terminal" })
map("t", "<leader>t", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit Terminal Mode" })
