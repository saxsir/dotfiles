-- ======================
-- Git integration (mini.git)
-- ======================

return {
  source = "echasnovski/mini.nvim",
  config = function()
    -- Git command integration
    require('mini.git').setup()

    -- Keymaps for common git operations
    vim.keymap.set('n', '<Leader>gs', function()
      vim.cmd('Git status')
    end, { desc = 'Git status' })

    vim.keymap.set('n', '<Leader>gc', function()
      vim.cmd('Git commit')
    end, { desc = 'Git commit' })

    vim.keymap.set('n', '<Leader>gp', function()
      vim.cmd('Git push')
    end, { desc = 'Git push' })

    vim.keymap.set('n', '<Leader>gl', function()
      vim.cmd('Git log')
    end, { desc = 'Git log' })

    vim.keymap.set('n', '<Leader>gd', function()
      vim.cmd('Git diff')
    end, { desc = 'Git diff' })

    vim.keymap.set('n', '<Leader>gb', function()
      vim.cmd('Git blame -- %')
    end, { desc = 'Git blame' })

    -- Helper: Open PR for a commit hash using gh command
    local function open_pr_for_commit(hash)
      if not hash or #hash < 7 then
        vim.notify('No valid commit hash found', vim.log.levels.WARN)
        return
      end

      vim.fn.jobstart(
        { 'gh', 'pr', 'list', '--search', hash, '--state', 'merged', '--json', 'url', '--jq', '.[0].url' },
        {
          stdout_buffered = true,
          on_stdout = function(_, data)
            local url = data[1]
            if url and url ~= '' then
              vim.fn.jobstart({ 'open', url })
              vim.notify('Opening PR: ' .. url, vim.log.levels.INFO)
            else
              vim.notify('No PR found for commit ' .. hash, vim.log.levels.WARN)
            end
          end,
        }
      )
    end

    -- Setup keymaps for git buffers
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'git',
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)

        -- Blame buffer: Enter to show commit details
        if bufname:match('blame') then
          vim.keymap.set('n', '<CR>', function()
            local line = vim.api.nvim_get_current_line()
            local hash = line:match('^(%x+)')
            if hash and #hash >= 7 then
              vim.cmd('Git show ' .. hash)
            end
          end, { buffer = args.buf, desc = 'Show commit details' })
        end

        -- All git buffers: gP to open related PR in browser
        vim.keymap.set('n', 'gP', function()
          -- Try to get hash from first line (commit show format: "commit <hash>")
          local first_line = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ''
          local hash = first_line:match('^commit (%x+)')

          -- Fallback: try current line (blame format)
          if not hash then
            local current_line = vim.api.nvim_get_current_line()
            hash = current_line:match('^(%x+)')
          end

          open_pr_for_commit(hash)
        end, { buffer = args.buf, desc = 'Open PR for commit' })
      end,
    })

    -- Inline blame at cursor (virtual text)
    vim.keymap.set('n', '<Leader>gB', function()
      MiniGit.show_at_cursor()
    end, { desc = 'Git blame at cursor (inline)' })
  end,
}
