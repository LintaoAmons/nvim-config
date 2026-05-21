return {
  "LintaoAmons/cd-project.nvim",
  init = function()
    require("cd-project").setup({
      projects_config_filepath = vim.fn.stdpath("data") .. "/cd-project.json",
      project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
      projects_picker = "snacks",
      auto_register_project = true,
      format_json = true,
      hooks = {
        {
          trigger_point = "AFTER_CD",
          cd_cmd = "lcd",
          callback = function(_)
            Snacks.picker.smart()
          end,
        },
      },
    })
  end,
  keys = {
    { "<C-q>", "<cmd>CdProject<cr>", mode = { "n", "v" }, desc = "Switch Project" },
  },
}
