-- ======================
-- AI Sidekick (sidekick.nvim)
-- ======================

return {
  source = "folke/sidekick.nvim",
  config = function()
    require("sidekick").setup({
      nes = {
        enabled = true,
      },
      cli = {
        win = {
          layout = "right",
        },
      },
    })

    -- NES: Tab で提案にジャンプ/適用、未表示時は通常の Tab
    vim.keymap.set({ "i", "n" }, "<Tab>", function()
      if not require("sidekick").nes_jump_or_apply() then
        return "<Tab>"
      end
    end, { expr = true, desc = "NES jump/apply or Tab" })

    -- CLI トグル
    vim.keymap.set({ "n", "t", "i", "x" }, "<C-.>", function()
      require("sidekick.cli").toggle()
    end, { desc = "Sidekick Toggle" })

    vim.keymap.set("n", "<Leader>aa", function()
      require("sidekick.cli").toggle()
    end, { desc = "Sidekick Toggle CLI" })

    vim.keymap.set("n", "<Leader>ac", function()
      require("sidekick.cli").toggle({ name = "claude", focus = true })
    end, { desc = "Sidekick Toggle Claude" })

    vim.keymap.set("n", "<Leader>as", function()
      require("sidekick.cli").select()
    end, { desc = "Select CLI tool" })

    vim.keymap.set("n", "<Leader>ad", function()
      require("sidekick.cli").close()
    end, { desc = "Detach CLI session" })

    vim.keymap.set({ "x", "n" }, "<Leader>at", function()
      require("sidekick.cli").send({ msg = "{this}" })
    end, { desc = "Send this" })

    vim.keymap.set("n", "<Leader>af", function()
      require("sidekick.cli").send({ msg = "{file}" })
    end, { desc = "Send file" })

    vim.keymap.set("x", "<Leader>av", function()
      require("sidekick.cli").send({ msg = "{selection}" })
    end, { desc = "Send visual selection" })

    vim.keymap.set({ "n", "x" }, "<Leader>ap", function()
      require("sidekick.cli").prompt()
    end, { desc = "Select prompt" })
  end,
}
