-- ======================
-- Key Mappings
-- ======================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Reload config
keymap("n", "<C-c><C-e>e", ":edit $MYVIMRC<CR>", opts)
keymap("n", "<C-c><C-e>s", ":source $MYVIMRC<CR>", opts)

-- Center screen when searching
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "*", "*zz", opts)
keymap("n", "#", "#zz", opts)
keymap("n", "g*", "g*zz", opts)
keymap("n", "g#", "g#zz", opts)

-- Escape with jj
keymap("i", "jj", "<ESC>", opts)

-- ; to :
keymap("n", ";", ":", { noremap = true })

-- Window navigation with Ctrl+hjkl
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Expand active file's directory
keymap("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", { noremap = true, expr = true })

-- Clear search highlight
keymap("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move lines up/down
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)
