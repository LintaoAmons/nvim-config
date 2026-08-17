-- Winbar breadcrumb showing the cursor's position in the code hierarchy
-- (file path > symbol > symbol ...). Answers "which treesitter/LSP scope is
-- my cursor in right now" -- the piece lualine's statusline never showed.
--
-- Why dropbar over nvim-navic: dropbar is self-contained. It attaches its own
-- winbar and pulls the hierarchy from a source chain, so it needs zero edits to
-- lualine (globalstatus statusline stays as-is) and zero LSP on_attach wiring.
-- Its source order is LSP symbols first, then a native treesitter source as
-- fallback -- so buffers without an LSP still get the treesitter node hierarchy
-- master asked for. It reads via core `vim.treesitter`, so it is independent of
-- the nvim-treesitter `main`-branch rewrite used in plugins/treesitter.lua.
--
-- Lazy-loaded on buffer read so it never touches startup time.
return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- Keep only path/LSP/treesitter sources; treesitter is the fallback that
    -- guarantees a breadcrumb even when no language server is attached.
    sources = {
      terminal = { name = "" },
    },
  },
}
