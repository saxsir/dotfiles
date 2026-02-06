-- ======================
-- GitHub Copilot
-- ======================

return {
  source = "github/copilot.vim",
  config = function()
    -- <Tab> は sidekick.nvim の NES や他プラグインと競合するため無効化し、<C-y> に移行
    vim.g.copilot_no_tab_map = true

    -- <C-y> で Copilot の提案を受け入れる
    vim.api.nvim_set_keymap('i', '<C-y>', 'copilot#Accept("<CR>")', {
      expr = true,
      silent = true,
      replace_keycodes = false,
    })

    -- ファイルタイプごとの有効化設定
    vim.g.copilot_filetypes = {
      ['*'] = true,
      ['markdown'] = false,
      ['help'] = false,
    }
  end,
}
