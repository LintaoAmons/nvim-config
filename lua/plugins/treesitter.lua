return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- master branch for Neovim 0.11 compatibility
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    opts = {
      ensure_installed = {
        "bash", "css", "dockerfile", "go", "gomod", "gosum",
        "html", "javascript", "json", "lua", "markdown",
        "markdown_inline", "python", "regex", "ruby",
        "terraform", "toml", "tsx", "typescript", "vim",
        "vimdoc", "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 3,
      multiline_threshold = 20,
      mode = "cursor",
    },
  },
}
