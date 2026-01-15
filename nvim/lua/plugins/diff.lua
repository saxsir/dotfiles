-- ======================
-- Diff visualization (mini.diff)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Visualize git changes in sign column
    require('mini.diff').setup({
      view = {
        style = 'sign', -- Show changes in sign column
        signs = {
          add = '▎',
          change = '▎',
          delete = '▎',
        },
      },
      mappings = {
        -- Apply hunks
        apply = 'gh',
        -- Reset hunks
        reset = 'gH',
        -- Navigate hunks
        goto_first = '[H',
        goto_prev = '[h',
        goto_next = ']h',
        goto_last = ']H',
      },
    })
  end,
}
