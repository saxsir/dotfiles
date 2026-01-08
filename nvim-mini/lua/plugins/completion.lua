-- ======================
-- Completion configuration (mini.completion)
-- ======================

return {
    source = "echasnovski/mini.nvim",
    config = function()
        require("mini.completion").setup({
            lsp_completion = {
                source_func = "omnifunc",
                auto_setup = true,
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
