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

    local Extra = require("mini.extra")
    Extra.setup()

    -- Keymaps (Telescope-like)
    vim.keymap.set("n", "<Leader>ff", function()
      Pick.builtin.files()
    end, { desc = "Find files" })

    vim.keymap.set("n", "<Leader>fg", function()
      Pick.builtin.pickers.grep_live()
    end, { desc = "Live grep" })

    vim.keymap.set("n", "<Leader>fb", function()
      Pick.builtin.buffers()
    end, { desc = "Find buffers" })

    vim.keymap.set("n", "<Leader>fh", function()
      Pick.builtin.help()
    end, { desc = "Help tags" })
  end,
}
