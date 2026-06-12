-- Debug CTE: visually select CTE blocks, generate a runnable query
vim.keymap.set("v", "<localleader>cd", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, "\n")

  -- Find the last CTE name: matches "name AS" (case-insensitive)
  local last_cte
  for name in text:gmatch("([%w_]+)%s+[Aa][Ss]%s*%(") do
    last_cte = name
  end

  if not last_cte then
    vim.notify("No CTE found in selection", vim.log.levels.WARN)
    return
  end

  -- Ensure text starts with WITH
  local trimmed = text:gsub("^%s+", "")
  if not trimmed:match("^[Ww][Ii][Tt][Hh]%s") then
    text = "WITH " .. text
  end

  -- Remove trailing comma after the last CTE's closing paren
  text = text:gsub(",%s*$", "")

  local query = text .. "\nSELECT * FROM " .. last_cte .. ";\n"

  -- Copy to clipboard
  vim.fn.setreg("+", query)
  vim.notify("CTE debug query copied to clipboard", vim.log.levels.INFO)

  -- Open in a new split buffer
  vim.cmd("belowright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "sql"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(query, "\n"))
end, { buffer = true, desc = "Debug CTE selection" })
