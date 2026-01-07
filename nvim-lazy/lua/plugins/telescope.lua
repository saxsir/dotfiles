-- Telescope Configuration
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    keys = {
      { "<Leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<Leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<Leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<Leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<Leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<Leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<Leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<Leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<Leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<Leader>gg", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<Leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<Leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<Leader>rg", "<cmd>Telescope grep_string<cr>", desc = "Grep string under cursor" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "%.lock",
        },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-n>"] = "cycle_history_next",
            ["<C-p>"] = "cycle_history_prev",
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
}
