-- ======================
-- Custom Commands
-- ======================

-- Junkfile directory
local junkfile_base = vim.fn.expand("$HOME/src/github.com/saxsir/memo")

-- DailyLog command: Open Daily/YYYY/MM/YYYY-MM-DD.md
vim.api.nvim_create_user_command("DailyLog", function()
  local year = os.date("%Y")
  local month = os.date("%m")
  local filename = os.date("%Y-%m-%d.md")

  -- Create directory structure: Daily/YYYY/MM/
  local daily_dir = junkfile_base .. "/" .. year .. "/" .. month
  vim.fn.mkdir(daily_dir, "p")

  -- Open file in new window if current window has winfixbuf
  local filepath = daily_dir .. "/" .. filename
  local file_exists = vim.fn.filereadable(filepath) == 1

  if vim.wo.winfixbuf then
    vim.cmd("new")
  end
  vim.cmd("edit " .. filepath)

  -- Insert template if file is new
  if not file_exists then
    local template = {
      "# yt",
      "",
      "# yr",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
  end
end, { desc = "Open daily log file" })

-- JunkfileOpen command: Open junkfile with timestamp
vim.api.nvim_create_user_command("JunkfileOpen", function()
  local year = os.date("%Y")
  local month = os.date("%m")
  local timestamp = os.date("%Y-%m-%d-%H%M%S.")
  local ext = vim.fn.input("Extension: ")
  if ext ~= "" then
    local filename = timestamp .. ext
    -- Create directory structure: YYYY/MM/ (same as DailyLog)
    local daily_dir = junkfile_base .. "/" .. year .. "/" .. month
    vim.fn.mkdir(daily_dir, "p")
    local filepath = daily_dir .. "/" .. filename
    -- Open file in new window if current window has winfixbuf
    if vim.wo.winfixbuf then
      vim.cmd("new")
    end
    vim.cmd("edit " .. filepath)
  end
end, { desc = "Open junkfile with timestamp" })
