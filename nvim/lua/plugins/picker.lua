-- ======================
-- Fuzzy finder (mini.pick + mini.extra)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    local Pick = require("mini.pick")
    Pick.setup({
      options = {
        use_cache = true,
      },
      window = {
        config = {
          border = "single",
        },
      },
    })

    -- Keymaps (Telescope-like)
    vim.keymap.set("n", "<Leader>ff", function()
      Pick.builtin.files()
    end, { desc = "Find files" })

    vim.keymap.set("n", "<Leader>fg", function()
      Pick.builtin.grep_live()
    end, { desc = "Live grep" })

    vim.keymap.set("n", "<Leader>fb", function()
      Pick.builtin.buffers()
    end, { desc = "Find buffers" })

    vim.keymap.set("n", "<Leader>fh", function()
      Pick.builtin.help()
    end, { desc = "Help tags" })

    local Extra = require("mini.extra")
    Extra.setup()

    -- Recent files (from mini.extra)
    vim.keymap.set("n", "<Leader>fr", function()
      Extra.pickers.oldfiles()
    end, { desc = "Recent files" })

    -- LSP pickers with preview (smart definition jump)
    vim.keymap.set('n', 'gd', function()
      -- Check the number of definition results
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
        if err or not result or vim.tbl_isempty(result) then
          vim.notify('No definition found', vim.log.levels.INFO)
          return
        end

        -- Normalize result (can be Location or Location[])
        local locations = vim.tbl_islist(result) and result or { result }

        if #locations == 1 then
          -- Single result: jump directly
          vim.lsp.util.jump_to_location(locations[1], 'utf-8')
        else
          -- Multiple results: show picker
          Extra.pickers.lsp({ scope = 'definition' })
        end
      end)
    end, { desc = 'LSP Definition' })

    vim.keymap.set('n', 'gr', function()
      Extra.pickers.lsp({ scope = 'references' })
    end, { desc = 'LSP References' })

    vim.keymap.set('n', 'gi', function()
      Extra.pickers.lsp({ scope = 'implementation' })
    end, { desc = 'LSP Implementation' })

    vim.keymap.set('n', '<Leader>ss', function()
      Extra.pickers.lsp({ scope = 'document_symbol' })
    end, { desc = 'Document Symbols' })

    vim.keymap.set('n', '<Leader>ws', function()
      Extra.pickers.lsp({ scope = 'workspace_symbol' })
    end, { desc = 'Workspace Symbols' })
  end,
}
