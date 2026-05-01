-- ======================
-- Plugin Management with mini.deps
-- ======================

-- Bootstrap mini.deps
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing [`mini.nvim`](../doc/mini-nvim.qmd#mini.nvim)" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed [`mini.nvim`](../doc/mini-nvim.qmd#mini.nvim)" | redraw')
end
local Deps = require("mini.deps")
Deps.setup({ path = { package = path_package } })

-- Define helpers
local add, now, later = Deps.add, Deps.now, Deps.later

now(function()
  -- Color schema
  vim.o.termguicolors = true
  require('mini.hues').setup({ background = '#19213a', foreground = '#c4c6cd' }) -- blue

  require("mini.icons").setup()
  require("mini.statusline").setup()
end)

now(function()
  local Files = require("mini.files")
  Files.setup({
    windows = {
      max_number = math.huge,
      preview = true,
      width_preview = 80,
    },
    mappings = {
      go_in = "<CR>",
      go_in_plus = "l",
      go_out = "-",
      go_out_plus = "h",
    },
  })

  vim.keymap.set("n", "-", function()
    Files.open(vim.api.nvim_buf_get_name(0))
  end, { desc = "Open mini.files" })
end)

now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify({
    ERROR = { duration = 10000 }
  })
  vim.api.nvim_create_user_command('NotifyHistory', function()
    -- Open in a new split to avoid winfixbuf issues
    vim.cmd('vsplit')
    MiniNotify.show_history()
    -- Press 'q' to delete the history buffer
    vim.keymap.set('n', 'q', '<cmd>bdelete<cr>', { buffer = true })
  end, { desc = 'Show notify history' })
end)

now(function()
  -- nvim-treesister does NOT support lazy loading
  -- https://github.com/nvim-treesitter/nvim-treesitter/blob/de878155ca66c49b027b1380e4e60a6c665b2630/README.md?plain=1#L46
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })
end)

-- Lazy loading
local function load_plugin(file)
  local module = file:match("([^/]+)%.lua$")

  if module == "init" then
    return
  end

  local status, spec = pcall(require, "plugins." .. module)
  if not (status and spec and spec.source) then
    return
  end

  later(function()
    local add_spec = {}
    for k, v in pairs(spec) do
      if k ~= "config" then
        add_spec[k] = v
      end
    end
    add(add_spec)

    if spec.config then
      spec.config()
    end
  end)
end

local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local files = vim.split(vim.fn.glob(plugins_dir .. "/*.lua"), "\n")
for _, file in ipairs(files) do
  if file ~= "" then
    load_plugin(file)
  end
end
