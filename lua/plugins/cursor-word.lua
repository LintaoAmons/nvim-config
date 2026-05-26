-- Automatic highlighting of word under cursor.
return {
  "echasnovski/mini.cursorword",
  version = "*",
  config = function()
    require("mini.cursorword").setup()
  end,
}
