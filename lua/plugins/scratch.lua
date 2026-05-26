return {
  "LintaoAmons/scratch.nvim",
  -- dir = "/Volumes/t7ex/Documents/oatnil/scratch.nvim",
  config = function()
    require("scratch").setup({
      file_picker = "snacks",
      filetypes = { "lua", "js", "ts", "go", "py", "sh", "sql", "json", "md", "txt", "http", "html" },
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
  keys = {
    { "<leader>no", "<cmd>Scratch<cr>", desc = "New Scratch File" },
    { "<leader>nO", "<cmd>ScratchOpen<cr>", desc = "Open Scratch File" },
    { "<leader>nf", "<cmd>ScratchOpenFzf<cr>", desc = "Find Scratch File" },
    { "<leader>nN", "<cmd>ScratchWithName<cr>", desc = "New Named Scratch" },
  },
}
