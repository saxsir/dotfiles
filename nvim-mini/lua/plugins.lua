-- ======================
-- Plugin Management with mini.deps
-- ======================

-- Bootstrap mini.deps
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing mini.nvim..." | redraw')
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  })
  vim.cmd("packadd mini.nvim | helptags ALL")
end

local deps = require("mini.deps")
deps.setup({ path = { package = path_package } })

local add, now, later = deps.add, deps.now, deps.later

-- Immediate loading (now)
now(function()
  -- Colorscheme
  add("folke/tokyonight.nvim")
  require("tokyonight").setup({ style = "night" })
  vim.cmd.colorscheme("tokyonight")
end)

now(function()
  -- mini.files
  require("mini.files").setup({
    mappings = {
      go_in = "<CR>",
      go_in_plus = "l",
      go_out = "-",
      go_out_plus = "h",
    },
  })
  vim.keymap.set("n", "-", function()
    require("mini.files").open(vim.api.nvim_buf_get_name(0))
  end, { desc = "Open mini.files" })
end)

-- Deferred loading (later)
later(function()
  -- Treesitter
  add({
    source = "nvim-treesitter/nvim-treesitter",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash", "go", "javascript", "json", "lua",
      "markdown", "python", "typescript", "vim", "vimdoc", "yaml",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

later(function()
  -- LSP
  add("neovim/nvim-lspconfig")
  add("williamboman/mason.nvim")
  add("williamboman/mason-lspconfig.nvim")

  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "gopls", "ts_ls", "pyright" },
    automatic_installation = true,
  })

  -- LSP keymaps
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      local opts = { buffer = ev.buf, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<Leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
  })

  -- Setup LSP servers
  local lspconfig = require("lspconfig")
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  })
  lspconfig.gopls.setup({})
  lspconfig.ts_ls.setup({})
  lspconfig.pyright.setup({})
end)

later(function()
  -- Completion
  add("hrsh7th/nvim-cmp")
  add("hrsh7th/cmp-nvim-lsp")
  add("hrsh7th/cmp-buffer")
  add("hrsh7th/cmp-path")

  local cmp = require("cmp")
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "path" },
    }, {
      { name = "buffer" },
    }),
  })
end)

later(function()
  -- Telescope
  add("nvim-lua/plenary.nvim")
  add("nvim-telescope/telescope.nvim")

  require("telescope").setup({
    defaults = {
      file_ignore_patterns = { "node_modules", ".git/" },
    },
  })

  vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<cr>")
  vim.keymap.set("n", "<Leader>fg", "<cmd>Telescope live_grep<cr>")
  vim.keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<cr>")
  vim.keymap.set("n", "<Leader>fh", "<cmd>Telescope help_tags<cr>")
end)
