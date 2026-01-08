-- ======================
-- Neovim configuration file (mini.nvim edition)
-- @author saxsir (https://github.com/saxsir)
-- ======================

-- Initialization
pcall(function()
	vim.loader.enable()
end)

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")

-- Load plugins
require("plugins")
