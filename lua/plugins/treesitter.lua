-- Languages to keep installed. Explicit install replaces master's
-- `ensure_installed`; the `main` branch has no ensure_installed option.
-- `helm` is the go-template dialect, paired with the `helm` filetype set in
-- plugins/lsp.lua. Its injections.scm injects `yaml` into the text between
-- template actions, so the manifest keeps YAML highlighting while `{{- if }}`
-- gets template highlighting -- which is why `yaml` must stay installed too.
--
-- `gotmpl` is here for its QUERIES, not its parser: helm's highlights.scm and
-- injections.scm both open with `; inherits: gotmpl`, and nvim-treesitter only
-- copies queries/<lang>/ into site/queries for parsers it installs. Drop gotmpl
-- and the inherit silently resolves to nothing -- `{{-`, `}}`, `if`, `end`,
-- `range` lose their highlights while `.Values`/`toYaml` keep theirs, which
-- looks like a half-broken theme rather than a missing parser.
local ensure = {
  "bash", "css", "dockerfile", "go", "gomod", "gosum",
  "gotmpl", "helm", "html", "java", "javascript", "json", "lua", "markdown",
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
