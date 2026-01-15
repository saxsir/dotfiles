-- ======================
-- Cursor word highlight (mini.cursorword)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Highlight word under cursor for better code readability
    require('mini.cursorword').setup({
      delay = 100,
    })
  end,
}
