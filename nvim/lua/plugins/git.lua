-- ======================
-- Git integration (mini.git)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Git command integration
    require('mini.git').setup()

    -- Keymaps for common git operations
    vim.keymap.set('n', '<Leader>gs', function()
      vim.cmd('Git status')
    end, { desc = 'Git status' })

    vim.keymap.set('n', '<Leader>gc', function()
      vim.cmd('Git commit')
    end, { desc = 'Git commit' })

    vim.keymap.set('n', '<Leader>gp', function()
      vim.cmd('Git push')
    end, { desc = 'Git push' })

    vim.keymap.set('n', '<Leader>gl', function()
      vim.cmd('Git log')
    end, { desc = 'Git log' })

    vim.keymap.set('n', '<Leader>gd', function()
      vim.cmd('Git diff')
    end, { desc = 'Git diff' })

    vim.keymap.set('n', '<Leader>gb', function()
      vim.cmd('Git blame')
    end, { desc = 'Git blame' })
  end,
}
