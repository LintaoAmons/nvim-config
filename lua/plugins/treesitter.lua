-- Languages to keep installed. Explicit install replaces master's
-- `ensure_installed`; the `main` branch has no ensure_installed option.
local ensure = {
  "bash", "css", "dockerfile", "go", "gomod", "gosum",
  "html", "java", "javascript", "json", "lua", "markdown",
  "markdown_inline", "python", "regex", "ruby",
  "terraform", "toml", "tsx", "typescript", "vim",
  "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- rewrite branch; requires Neovim 0.12+
    lazy = false, -- main does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(ensure)

      -- Enable highlighting + indentation per buffer. On `main`, highlight
      -- is `vim.treesitter.start()` and indent is the plugin's indentexpr
      -- (experimental) — both replace the old `highlight`/`indent` opts.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "tsx", "jsx", "markdown", "xml" },
    opts = {},
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
