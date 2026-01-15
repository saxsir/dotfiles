-- ======================
-- Surround operations (mini.surround)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    -- Mappings:
    --   sa - Add surrounding
    --   sd - Delete surrounding
    --   sr - Replace surrounding
    --   sf/sF - Find surrounding
    --   sh - Highlight surrounding
    require('mini.surround').setup()
  end,
}
