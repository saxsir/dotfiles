-- ======================
-- Claude Code Neovim integration
-- ======================

return {
  source = "coder/claudecode.nvim",
  config = function()
    require("claudecode").setup({
      terminal_cmd = vim.env.CLAUDE_PATH or vim.fn.expand("~/.claude/local/claude"),
      terminal = {
        split_width_percentage = 0.4,
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<Leader>l", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code" })
    vim.keymap.set("v", "<Leader>l", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
    vim.keymap.set("t", "<Esc><Esc>", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code" })
    vim.keymap.set("n", "<Leader>la", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" })
    vim.keymap.set("n", "<Leader>ld", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" })
  end,
}
