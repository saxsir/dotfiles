-- ======================
-- Auto-pairs (mini.pairs)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    require("mini.pairs").setup({
      mappings = {
        ['`'] = false, -- Disable backtick auto-pairing
      },
    })
  end,
}
