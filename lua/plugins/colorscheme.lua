return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  ---@type CatppuccinOptions
  opts = {
    flavour = "mocha",
    background = { light = "latte", dark = "mocha" },
    default_integrations = true,
    integrations = {
      blink_cmp = true,
      flash = true,
      gitsigns = true,
      mason = true,
      mini = { enabled = true },
      noice = true,
      snacks = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
