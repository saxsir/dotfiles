-- ======================
-- Snippet support (mini.snippets + friendly-snippets)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  depends = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local snippets = require('mini.snippets')

    -- Path to friendly-snippets installed via mini.deps
    local snippets_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/friendly-snippets"

    snippets.setup({
      snippets = {
        -- Load snippets from friendly-snippets
        snippets.gen_loader.from_file(snippets_path),
        snippets.gen_loader.from_lang(),
      },
    })
  end,
}
