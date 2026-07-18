return {
  "LintaoAmons/context-menu.nvim",
  event = "VeryLazy",
  config = function()
    require("context-menu").setup({
      picker = "menu", -- right-click style float; use "vim-ui" for vim.ui.select
      modules = { "git" },
    })
    require("context-menu").add_items({
      {
        order = 1,
        name = "Code Action",
        not_ft = { "markdown", "toggleterm", "http", "DiffviewFiles" },
        action = function()
          vim.lsp.buf.code_action()
        end,
      },
      {
        name = "Copy Line Reference",
        action = function()
          local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
          if git_dir ~= "" then
            local root = vim.fn.fnamemodify(git_dir, ":p:h:h")
            local rel = string.sub(vim.fn.expand("%:p"), #root + 2)
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            local ref = rel .. ":" .. line .. ":" .. col
            vim.fn.setreg("+", ref)
            vim.notify("Copied: " .. ref)
          else
            vim.notify("No git repository found", vim.log.levels.WARN)
          end
        end,
      },
      {
        name = "Copy",
        items = {
          {
            name = "Buffer Name",
            action = function()
              local name = vim.fn.expand("%:p:t")
              vim.fn.setreg("+", name)
              vim.notify("Copied: " .. name)
            end,
          },
          {
            name = "Absolute Path",
            action = function()
              local path = vim.fn.expand("%:p")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
          {
            name = "Relative Path",
            action = function()
              local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
          {
            name = "Directory Path",
            action = function()
              local path = vim.fn.expand("%:p:h")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
        },
      },
    })
  end,
  keys = {
    { "<M-l>", function() require("context-menu").open() end, mode = { "v", "n" }, desc = "Context Menu" },
    { "<C-g>", function() require("context-menu").open() end, mode = { "v", "n" }, desc = "Context Menu" },
  },
}
