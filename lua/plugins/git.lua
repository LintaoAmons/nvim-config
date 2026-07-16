return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (all)" },
    },
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        view = {
          default = { winbar_info = true },
          file_history = { winbar_info = true },
        },
        keymaps = {
          file_panel = {
            { "n", "q", function() vim.cmd("tabclose") end, { desc = "Close diffview" } },
            { "n", "a", actions.toggle_stage_entry, { desc = "Stage/unstage entry" } },
            { "n", "A", actions.stage_all, { desc = "Stage all" } },
            { "n", "d", actions.restore_entry, { desc = "Restore entry" } },
            { "n", "C", function() Snacks.lazygit() end, { desc = "Open lazygit" } },
          },
          file_history_panel = {
            { "n", "q", function() vim.cmd("tabclose") end, { desc = "Close diffview" } },
          },
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 300 },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
    keys = {
      { "gj", function() require("gitsigns").nav_hunk("next", { wrap = true }) vim.cmd("normal! zz") end, desc = "Next Hunk" },
      { "gk", function() require("gitsigns").nav_hunk("prev", { wrap = true }) vim.cmd("normal! zz") end, desc = "Prev Hunk" },
      { "ga", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
      { "<leader>ghs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
      { "<leader>ghr", function() require("gitsigns").reset_hunk() end, desc = "Reset Hunk" },
      { "<leader>ghS", function() require("gitsigns").stage_buffer() end, desc = "Stage Buffer" },
      { "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo Stage Hunk" },
      { "<leader>ghd", function() require("gitsigns").diffthis() end, desc = "Diff This" },
      { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
      { "<leader>ghB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Line Blame" },
      { "<leader>ghp", function() require("gitsigns").preview_hunk_inline() end, desc = "Preview Hunk Inline" },
    },
  },
}
