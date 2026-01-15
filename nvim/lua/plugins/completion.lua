-- ======================
-- Completion configuration (mini.completion)
-- ======================
--

return {
  source = "echasnovski/mini.nvim",
  config = function()
    local completion = require("mini.completion")
    completion.setup({
      lsp_completion = {
        source_func = "omnifunc",
        auto_setup = true,
        -- mini.snippets automatically integrates with completion
        -- Snippets will be expanded after selecting completion item
        process_items = function(items, base)
          -- Filter items based on base
          return vim.tbl_filter(function(item)
            return vim.startswith(item.word or item.label, base)
          end, items)
        end,
      },
      window = {
        info = { border = "single" },
        signature = { border = "single" },
      },
    })

    -- Set up omnifunc for LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
      end,
    })
  end,
}
