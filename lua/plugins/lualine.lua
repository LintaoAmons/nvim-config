return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        "mode",
        {
          function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          icon = "",
        },
      },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          "filename",
          file_status = true,
          path = 1,
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },
      lualine_x = {
        {
          function()
            local mode = vim.fn.mode()
            if mode == "v" or mode == "V" or mode == "\22" then
              local starts = vim.fn.getpos("v")
              local ends = vim.fn.getpos(".")
              local lines = math.abs(ends[2] - starts[2]) + 1
              local chars = 0
              if mode == "V" then
                for i = math.min(starts[2], ends[2]), math.max(starts[2], ends[2]) do
                  chars = chars + #vim.fn.getline(i)
                end
              else
                chars = math.abs(ends[3] - starts[3]) + 1
              end
              return lines .. "L " .. chars .. "C"
            end
            return ""
          end,
          cond = function()
            local mode = vim.fn.mode()
            return mode == "v" or mode == "V" or mode == "\22"
          end,
        },
        {
          function()
            local formatters = require("conform").list_formatters_to_run(0)
            if #formatters == 0 then
              return ""
            end
            local names = {}
            for _, f in ipairs(formatters) do
              table.insert(names, f.name)
            end
            return " " .. table.concat(names, ", ")
          end,
          cond = function()
            return package.loaded["conform"] ~= nil
          end,
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
