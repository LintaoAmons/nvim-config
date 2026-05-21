return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  ---@module "which-key"
  ---@type wk.Opts
  opts = {
    preset = "helix",
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "toggle" },
      { "<leader>u", group = "ui" },
      { "<leader>w", group = "workspace" },
      { "<leader>q", group = "quit" },
    },
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Local Keymaps" },
  },
}
