-- ======================
-- Basic Options
-- ======================

local opt = vim.opt

-- Language / Encoding
opt.encoding = "utf-8"
opt.fileformats = { "unix", "mac", "dos" }

-- Input / Indentation
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 2
opt.backspace = { "indent", "eol", "start" }

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99

-- Appearance
opt.laststatus = 2
opt.background = "dark"
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- Backup / Undo
opt.hidden = true
opt.backup = true
opt.backupdir = vim.fn.expand("$HOME/.vimback")
opt.directory = vim.fn.expand("$HOME/.vimtmp")
opt.history = 10000
opt.updatetime = 200
opt.undofile = true
opt.undodir = vim.fn.expand("$HOME/.vimundo")

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Leader key
-- VimScript equivalent: let mapleader = "\<Space>"
local SPACE_KEY = " "
vim.g.mapleader = SPACE_KEY
vim.g.maplocalleader = SPACE_KEY
