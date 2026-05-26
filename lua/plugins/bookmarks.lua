return {
  "LintaoAmons/bookmarks.nvim",
  event = "VeryLazy",
  dependencies = {
    { "kkharji/sqlite.lua" },
  },
  config = function()
    require("bookmarks").setup({
      signs = {
        mark = {
          icon = "󰃁",
          color = "red",
          line_bg = "#572626",
        },
      },
      treeview = {
        highlights = {
          active_list = {
            bg = "#A13C3C",
            fg = "#ffffff",
            bold = true,
          },
        },
        active_list_icon = "👀 ",
      },
    })
  end,
  keys = {
    { "mm", "<cmd>BookmarksMark<cr>", desc = "Toggle bookmark" },
    { "mg", "<cmd>BookmarksGotoRecent<cr>", desc = "Go to recent bookmark" },
    { "mo", "<cmd>BookmarksGoto<cr>", desc = "Go to bookmark" },
    { "ma", "<cmd>BookmarksCommands<cr>", desc = "Bookmarks commands" },
    { "ms", "<cmd>BookmarksInfoCurrentBookmark<cr>", desc = "Current bookmark info" },
    { "mj", "<cmd>BookmarksGotoNext<cr>", desc = "Next bookmark" },
    { "mk", "<cmd>BookmarksGotoPrev<cr>", desc = "Prev bookmark" },
    { "mt", "<cmd>BookmarksTree<cr>", desc = "Bookmarks tree" },
  },
}
