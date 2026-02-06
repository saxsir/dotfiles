-- ======================
-- Better Escape (jj to ESC without timeout delay)
-- ======================

return {
    source = "max397574/better-escape.nvim",
    config = function()
        require("better_escape").setup()
    end,
}
