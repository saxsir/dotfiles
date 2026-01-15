-- ======================
-- LSP configuration
-- ======================

return {
  source = "neovim/nvim-lspconfig",
  depends = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "gopls", "ts_ls" },
      automatic_installation = true,
      handlers = {
        -- Default handler for all servers
        function(server_name)
          vim.lsp.config(server_name, {})
        end,
        -- Custom handler for lua_ls
        ["lua_ls"] = function()
          vim.lsp.config("lua_ls", {
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                -- Match StyLua default format settings
                format = {
                  defaultConfig = {
                    indent_style = "tab",
                    indent_size = "4",
                  },
                },
              },
            },
          })
        end,
      },
    })

    -- LSP keymaps (auto-attached when LSP starts)
    -- Note: gd, gr, gi are handled by mini.pick for preview-based navigation
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<Leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      end,
    })

    -- Auto-format on save for Lua files
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.lua",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
