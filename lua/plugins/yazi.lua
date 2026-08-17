-- Yazi: full-screen modal terminal file manager (vim-motion navigation, bulk
-- rename, shell-out) opened over the current buffer. Complements the snacks
-- sidebar explorer on <leader>e: that stays open as a persistent tree, this is
-- the heavy full-window manager for moving/renaming/deleting files fast.
--
-- Keymap choice -- <leader>E (proposal + alternatives are on the task thread):
-- it pairs with <leader>e (snacks explorer) and follows this config's pervasive
-- "capital = the stronger/alternate form" idiom (cf. cD/cL/gB/sB/uC ...), so the
-- "other, bigger explorer" is literally shift+e. It collides with no leader
-- group prefix (b/c/f/g/s/t/u/w/q) and no existing mapping.
--
-- Requires the `yazi` binary on PATH. Lazy-loaded on its key, so it adds zero
-- startup cost and does not hijack netrw (open_for_directories left false).
return {
  "mikavilpas/yazi.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>E", "<cmd>Yazi<cr>", desc = "File manager (yazi)" },
  },
  opts = {
    open_for_directories = false,
  },
}
