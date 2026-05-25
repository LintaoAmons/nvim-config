return {
  "LintaoAmons/scratch.nvim",
  -- dir = "/Volumes/t7ex/Documents/oatnil/scratch.nvim",
  config = function()
    require("scratch").setup({
      filetype_details = {
        go = {
          subdir = true,
          filename = "main",
          content = { "package main", "", "func main() {", "  ", "}" },
          cursor = {
            location = { 4, 2 },
            insert_mode = true,
          },
        },
      },
      hooks = {},
    })
  end,
  event = "VeryLazy",
}
