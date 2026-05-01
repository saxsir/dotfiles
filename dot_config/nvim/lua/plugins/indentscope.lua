-- ======================
-- Indent scope visualization (mini.indentscope)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Visualize indent scope for better code readability
    require('mini.indentscope').setup({
      draw = {
        delay = 0,
        animation = require('mini.indentscope').gen_animation.none(),
      },
      symbol = "│",
    })
  end,
}
