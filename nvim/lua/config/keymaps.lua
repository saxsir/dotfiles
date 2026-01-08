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

-- Terminal mode navigation
-- Exit terminal mode and move to window directly (instead of Esc then Ctrl+hjkl)
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Exit terminal and move left" })
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Exit terminal and move down" })
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Exit terminal and move up" })
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Exit terminal and move right" })

-- Exit terminal mode and return to previous window with Esc
-- Useful for quickly toggling between editor and terminal (e.g., Claude Code)
keymap("t", "<Esc>", "<C-\\><C-n><C-w>p", { desc = "Exit terminal and return to previous window" })
