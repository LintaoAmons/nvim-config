# nvim-config

Lintao's personal [Neovim](https://neovim.io/) configuration.

- Repository: <https://github.com/LintaoAmons/nvim-config>
- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim), bootstrapped in `init.lua`
- LSP is wired with the native `vim.lsp.config()` / `vim.lsp.enable()` API — `lua/plugins/lsp.lua` calls it the "native Neovim 0.11+ approach"

## Guides

- [Git](git.html) — every git key, picker and menu entry in this config, each
  with a `file:line`, split into *written here* / *plugin default* / *no working
  entry point*.

> **The rest of this page is still an inventory**, not documentation: below is
> only what can be read straight out of the repository.

## Repository layout

```
.
├── init.lua              # entry point: loads config.*, bootstraps lazy.nvim
├── lazy-lock.json        # lazy.nvim lockfile (pinned plugin revisions)
├── lua/
│   ├── config/           # options.lua, keymaps.lua, autocmds.lua
│   └── plugins/          # one file per plugin / plugin group
├── ftplugin/             # per-filetype settings (sql.lua)
└── tool-config/          # external tool configs (.sqruff)
```

## Plugins (38)

Counted from `lazy-lock.json` — 38 locked entries. This is the resolved
set, so it includes `lazy.nvim` itself and dependencies that are not declared
directly.

- `blink.cmp`
- `bookmarks.nvim`
- `catppuccin`
- `cd-project.nvim`
- `conform.nvim`
- `context-menu.nvim`
- `csvview.nvim`
- `diffview-plus.nvim`
- `dropbar.nvim`
- `flash.nvim`
- `friendly-snippets`
- `gitsigns.nvim`
- `kanagawa.nvim`
- `lazy.nvim`
- `lazydev.nvim`
- `lualine.nvim`
- `luvit-meta`
- `mason-lspconfig.nvim`
- `mason-tool-installer.nvim`
- `mason.nvim`
- `mini.cursorword`
- `mini.pairs`
- `nvim-lspconfig`
- `nvim-surround`
- `nvim-treesitter`
- `nvim-treesitter-context`
- `nvim-ts-autotag`
- `nvim-ufo`
- `nvim-web-devicons`
- `plenary.nvim`
- `promise-async`
- `SchemaStore.nvim`
- `scratch.nvim`
- `sidekick.nvim`
- `snacks.nvim`
- `sqlite.lua`
- `which-key.nvim`
- `yazi.nvim`

## Plugin spec files (24)

Counted from `lua/plugins/` — 24 `.lua` files (`init.lua` there is an empty `return {}`).

```
lua/plugins/autosave.lua
lua/plugins/blink.lua
lua/plugins/bookmarks.lua
lua/plugins/cd-project.lua
lua/plugins/colorscheme.lua
lua/plugins/conform.lua
lua/plugins/context-menu.lua
lua/plugins/csvview.lua
lua/plugins/cursor-word.lua
lua/plugins/date-format.lua
lua/plugins/dropbar.lua
lua/plugins/flash.lua
lua/plugins/fold.lua
lua/plugins/git.lua
lua/plugins/init.lua
lua/plugins/lsp.lua
lua/plugins/lualine.lua
lua/plugins/mini.lua
lua/plugins/scratch.lua
lua/plugins/sidekick.lua
lua/plugins/snacks.lua
lua/plugins/treesitter.lua
lua/plugins/which-key.lua
lua/plugins/yazi.lua
```

## LSP servers (12)

Counted from `ensure_installed` in the `mason-lspconfig.nvim` spec in `lua/plugins/lsp.lua` — 12 servers, auto-installed via Mason.

```
lua_ls, vtsls, gopls, pyright, jsonls, yamlls, helm_ls, bashls, html, cssls, tailwindcss, terraformls
```

## Formatters / tools (9)

Counted from `ensure_installed` in the `mason-tool-installer.nvim` spec in `lua/plugins/lsp.lua` — 9 entries.

```
goimports, gofumpt, prettierd, prettier, stylua, ruff, shfmt, jq, sqruff
```
