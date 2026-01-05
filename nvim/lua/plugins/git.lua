-- Git plugins
return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous hunk" })

        -- Actions
        map("n", "<Leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<Leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<Leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage hunk" })
        map("v", "<Leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset hunk" })
        map("n", "<Leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<Leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
        map("n", "<Leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<Leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<Leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame line" })
        map("n", "<Leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
        map("n", "<Leader>hd", gs.diffthis, { desc = "Diff this" })
        map("n", "<Leader>hD", function()
          gs.diffthis("~")
        end, { desc = "Diff this ~" })
        map("n", "<Leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
      end,
    },
  },

  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<Leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },
}
