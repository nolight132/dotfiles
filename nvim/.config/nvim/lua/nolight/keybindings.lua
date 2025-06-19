local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

local global = vim.g

global.mapleader = " "

-- Quit insert mode
map("i", "jk", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle reveal right<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")

map("n", "<leader>w", "<CMD>:w<CR>")
map("n", "<leader>q", "<CMD>:q<CR>")

map("n", "<ESC>", ":nohlsearch<CR>")
map("n", "<leader>h", ":nohlsearch<CR>")

map("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>")
map("n", "ge", vim.diagnostic.open_float)
map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>")
map("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>")
-- map("n", "gt", "<CMD>lua vim.lsp.buf.type_definition()<CR>")
map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>")

-- Inline git commands
map("n", "<leader>gd", "<CMD>:Gitsigns preview_hunk_inline<CR>")
map("n", "<leader>gr", "<CMD>:Gitsigns reset_hunk<CR>")

-- Writer mode
map("n", "<leader>wm", "<CMD>:Gitsigns toggle_signs<CR><CMD>:NoNeckPain<CR>")

-- Terminal mode mappings
map("t", "jk", "<C-\\><C-n>")
map("n", "<leader>t", ":ToggleTerm<CR>")

-- Project picker
map("n", "<leader>p", function()
	require("telescope").extensions.project.project({})
end)

-- CMP (autocomplete)
map("n", "<leader>u", function()
	vim.g.autocomplete = not vim.g.autocomplete
end)

-- Tabs
map("n", "<leader>,", "<Cmd>BufferPrevious<CR>")
map("n", "<leader>.", "<Cmd>BufferNext<CR>")
map("n", "<leader>c", "<Cmd>BufferClose<CR>")
map("n", "<leader><", "<Cmd>BufferMovePrevious<CR>")
map("n", "<leadea>>", "<Cmd>BufferMoveNext<CR>")

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

-- NoNeckPain (center buffer)
map("n", "<leader>z", "<Cmd>NoNeckPain<CR>")
