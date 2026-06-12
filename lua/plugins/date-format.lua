-- Pick date/datetime format for date(time) under cursor via vim.ui.select

local function parse_datetime(text)
  -- Try datetime with time: YYYY-MM-DD HH:MM:SS or YYYY-MM-DDTHH:MM:SS
  local y, dsep, m, d, H, M, S = text:match(
    "^(%d%d%d%d)([/%.%-])(%d%d)%2(%d%d)[T ](%d%d):(%d%d):(%d%d)$"
  )
  if y then
    return tonumber(y), tonumber(m), tonumber(d), tonumber(H), tonumber(M), tonumber(S)
  end

  -- YYYY-MM-DD HH:MM (no seconds)
  y, dsep, m, d, H, M = text:match("^(%d%d%d%d)([/%.%-])(%d%d)%2(%d%d)[T ](%d%d):(%d%d)$")
  if y then
    return tonumber(y), tonumber(m), tonumber(d), tonumber(H), tonumber(M), nil
  end

  -- DD/MM/YYYY HH:MM:SS
  local a, sep2, b, c, H2, M2, S2 = text:match(
    "^(%d%d)([/%.%-])(%d%d)%2(%d%d%d%d) (%d%d):(%d%d):(%d%d)$"
  )
  if a then
    local na, nb = tonumber(a), tonumber(b)
    local nc = tonumber(c)
    if na > 12 then
      return nc, nb, na, tonumber(H2), tonumber(M2), tonumber(S2)
    end
    if nb > 12 then
      return nc, na, nb, tonumber(H2), tonumber(M2), tonumber(S2)
    end
    return nc, nb, na, tonumber(H2), tonumber(M2), tonumber(S2)
  end

  -- DD/MM/YYYY HH:MM (no seconds)
  local a2, sep3, b2, c2, H3, M3 = text:match(
    "^(%d%d)([/%.%-])(%d%d)%2(%d%d%d%d) (%d%d):(%d%d)$"
  )
  if a2 then
    local na, nb = tonumber(a2), tonumber(b2)
    local nc = tonumber(c2)
    if na > 12 then
      return nc, nb, na, tonumber(H3), tonumber(M3), nil
    end
    if nb > 12 then
      return nc, na, nb, tonumber(H3), tonumber(M3), nil
    end
    return nc, nb, na, tonumber(H3), tonumber(M3), nil
  end

  -- Date only: YYYY-MM-DD
  local y2, sep4, m2, d2 = text:match("^(%d%d%d%d)([/%.%-])(%d%d)%2(%d%d)$")
  if y2 then
    return tonumber(y2), tonumber(m2), tonumber(d2), nil, nil, nil
  end

  -- Date only: DD/MM/YYYY or MM/DD/YYYY
  local a3, sep5, b3, c3 = text:match("^(%d%d)([/%.%-])(%d%d)%2(%d%d%d%d)$")
  if a3 then
    local na, nb, nc = tonumber(a3), tonumber(b3), tonumber(c3)
    if na > 12 then
      return nc, nb, na, nil, nil, nil
    end
    if nb > 12 then
      return nc, na, nb, nil, nil, nil
    end
    return nc, nb, na, nil, nil, nil
  end

  return nil
end

local function is_valid_date(y, m, d)
  if m < 1 or m > 12 or d < 1 or y < 1 then
    return false
  end
  local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  if (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0) then
    days_in_month[2] = 29
  end
  return d <= days_in_month[m]
end

local function has_time(H) return H ~= nil end

local function time_str(H, M, S)
  if S then
    return string.format("%02d:%02d:%02d", H, M, S)
  else
    return string.format("%02d:%02d", H, M)
  end
end

local function build_formats(y, m, d, H, M, S)
  local items = {}

  -- Date-only formats
  local date_fmts = {
    { label = "YYYY-MM-DD", val = string.format("%04d-%02d-%02d", y, m, d) },
    { label = "DD/MM/YYYY", val = string.format("%02d/%02d/%04d", d, m, y) },
    { label = "MM/DD/YYYY", val = string.format("%02d/%02d/%04d", m, d, y) },
    { label = "YYYY/MM/DD", val = string.format("%04d/%02d/%02d", y, m, d) },
    { label = "DD-MM-YYYY", val = string.format("%02d-%02d-%04d", d, m, y) },
  }

  for _, f in ipairs(date_fmts) do
    table.insert(items, { label = f.label .. "  " .. f.val, value = f.val })
  end

  -- Datetime formats (always show — adds time if missing, strips time if date-only chosen)
  local t = has_time(H) and time_str(H, M, S) or "00:00:00"
  local dt_fmts = {
    { label = "YYYY-MM-DD HH:MM:SS", val = string.format("%04d-%02d-%02d", y, m, d) .. " " .. t },
    { label = "YYYY-MM-DDTHH:MM:SS", val = string.format("%04d-%02d-%02d", y, m, d) .. "T" .. t },
    { label = "DD/MM/YYYY HH:MM:SS", val = string.format("%02d/%02d/%04d", d, m, y) .. " " .. t },
    { label = "MM/DD/YYYY HH:MM:SS", val = string.format("%02d/%02d/%04d", m, d, y) .. " " .. t },
  }

  for _, f in ipairs(dt_fmts) do
    table.insert(items, { label = f.label .. "  " .. f.val, value = f.val })
  end

  return items
end

local function pick_date_format()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  -- Match datetime first (longer), then date-only
  local patterns = {
    "%d%d%d%d[/%.%-]%d%d[/%.%-]%d%d[T ]%d%d:%d%d:%d%d",  -- YYYY-MM-DD HH:MM:SS
    "%d%d%d%d[/%.%-]%d%d[/%.%-]%d%d[T ]%d%d:%d%d",        -- YYYY-MM-DD HH:MM
    "%d%d[/%.%-]%d%d[/%.%-]%d%d%d%d %d%d:%d%d:%d%d",      -- DD/MM/YYYY HH:MM:SS
    "%d%d[/%.%-]%d%d[/%.%-]%d%d%d%d %d%d:%d%d",           -- DD/MM/YYYY HH:MM
    "%d%d%d%d[/%.%-]%d%d[/%.%-]%d%d",                      -- YYYY-MM-DD
    "%d%d[/%.%-]%d%d[/%.%-]%d%d%d%d",                      -- DD/MM/YYYY
  }

  for _, pat in ipairs(patterns) do
    local s, e = 1, nil
    while true do
      s, e = line:find(pat, s)
      if not s then break end
      if col >= s and col <= e then
        local date_str = line:sub(s, e)
        local y, m, d, H, M, S = parse_datetime(date_str)
        if y and is_valid_date(y, m, d) then
          local items = build_formats(y, m, d, H, M, S)

          vim.ui.select(items, {
            prompt = "Date format (" .. date_str .. ")",
            format_item = function(item) return item.label end,
          }, function(choice)
            if not choice or choice.value == date_str then return end
            local new_line = line:sub(1, s - 1) .. choice.value .. line:sub(e + 1)
            vim.api.nvim_set_current_line(new_line)
          end)
          return
        end
      end
      s = e + 1
    end
  end

  vim.notify("No date found under cursor", vim.log.levels.WARN)
end

return {
  dir = ".",
  name = "date-format",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("n", "<leader>cd", pick_date_format, { desc = "Change date format" })
  end,
}
