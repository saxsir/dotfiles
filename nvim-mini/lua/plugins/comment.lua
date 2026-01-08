-- ======================
-- Comment toggle (mini.comment)
-- ======================

return {
    source = "echasnovski/mini.nvim",
    config = function()
        require("mini.comment").setup()
    end,
}
