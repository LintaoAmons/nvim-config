local map = vim.keymap.set

-- General
map("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit all" })
map("n", "<leader>nl", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation
map({ "n", "v", "i" }, "<C-h>", "<C-w>h", { desc = "Go to left window" })
map({ "n", "v", "i" }, "<C-l>", "<C-w>l", { desc = "Go to right window" })
map({ "n", "v", "i" }, "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map({ "n", "v", "i" }, "<C-k>", "<C-w>k", { desc = "Go to upper window" })

-- Window splits
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>wl", "<cmd>rightbelow vsplit<cr>", { desc = "Split vertical right" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })
map("n", "<leader>wp", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
end, { desc = "Open buffer in new tab" })

-- Close window
map({ "n", "i" }, "<C-e>", function()
  local ok = pcall(vim.cmd, "close")
  if not ok then vim.cmd("hide") end
end, { desc = "Close/hide window" })

-- Window resize
map("n", "<C-M-l>", "<cmd>vertical resize +5<cr>", { desc = "Increase width" })
map("n", "<C-M-h>", "<cmd>vertical resize -5<cr>", { desc = "Decrease width" })
map("n", "<C-M-j>", "<cmd>resize -5<cr>", { desc = "Decrease height" })
map("n", "<C-M-k>", "<cmd>resize +5<cr>", { desc = "Increase height" })

-- Go to containing method/function definition
map("n", "gm", function()
  local node = vim.treesitter.get_node({ ignore_injections = false })
  if not node then
    vim.notify("Treesitter not available", vim.log.levels.WARN)
    return
  end
  local function_types = {
    "function_declaration", "method_declaration", "function_definition",
    "func_literal", "arrow_function", "function_expression",
    "method_definition", "function_item", "closure_expression",
  }
  local lookup = {}
  for _, t in ipairs(function_types) do lookup[t] = true end
  while node do
    if lookup[node:type()] then
      local row, col = node:start()
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
      return
    end
    node = node:parent()
  end
  vim.notify("No containing function found", vim.log.levels.WARN)
end, { desc = "Go to containing method/function" })

-- Better navigation
map("n", "j", "gj", { desc = "Move down wrapped lines" })
map("n", "k", "gk", { desc = "Move up wrapped lines" })

-- Better paste in visual mode
map("v", "p", "P", { desc = "Paste without overwriting register" })

-- Remove comments from selected lines
map("v", "<leader>cR", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then start_line, end_line = end_line, start_line end

  local buf = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf)
  if not parser then
    vim.notify("Treesitter not available", vim.log.levels.WARN)
    return
  end
  parser:parse()

  -- Collect comment nodes that overlap the selected range (0-indexed)
  local comments = {}
  parser:for_each_tree(function(tree, lang_tree)
    local query_ok, query = pcall(vim.treesitter.query.parse, lang_tree:lang(), "((comment) @c)")
    if not query_ok then return end
    for _, node in query:iter_captures(tree:root(), buf, start_line - 1, end_line) do
      local sr, sc, er, ec = node:range()
      table.insert(comments, { sr = sr, sc = sc, er = er, ec = ec })
    end
  end)

  if #comments == 0 then
    vim.notify("No comments found in selection", vim.log.levels.INFO)
    return
  end

  -- Sort bottom-to-top, right-to-left so removals don't shift positions
  table.sort(comments, function(a, b)
    if a.sr ~= b.sr then return a.sr > b.sr end
    return a.sc > b.sc
  end)

  -- Deduplicate (same node can appear from multiple trees)
  local seen = {}
  local unique = {}
  for _, c in ipairs(comments) do
    local key = c.sr .. ":" .. c.sc .. ":" .. c.er .. ":" .. c.ec
    if not seen[key] then
      seen[key] = true
      table.insert(unique, c)
    end
  end

  for _, c in ipairs(unique) do
    local line_text = vim.api.nvim_buf_get_lines(buf, c.sr, c.sr + 1, false)[1] or ""
    local before = line_text:sub(1, c.sc)
    -- If the line is only whitespace before the comment, remove the whole line
    if before:match("^%s*$") and c.sc == 0 or before:match("^%s+$") then
      -- Remove entire lines covered by this comment
      vim.api.nvim_buf_set_lines(buf, c.sr, c.er + 1, false, {})
    else
      -- Inline comment: remove from comment start to end, trim trailing whitespace
      local new_line = before:gsub("%s+$", "")
      if c.er == c.sr then
        vim.api.nvim_buf_set_lines(buf, c.sr, c.sr + 1, false, { new_line })
      else
        -- Multi-line inline comment (rare): remove the comment span
        local last_line = vim.api.nvim_buf_get_lines(buf, c.er, c.er + 1, false)[1] or ""
        local after = last_line:sub(c.ec + 1)
        vim.api.nvim_buf_set_lines(buf, c.sr, c.er + 1, false, { new_line .. after })
      end
    end
  end

  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
  vim.notify("Removed " .. #unique .. " comment(s)", vim.log.levels.INFO)
end, { desc = "Remove comments in selection" })

-- Send to terminal
local function send_to_terminal(text)
  local terms = Snacks.terminal.list()
  local term = terms[1]
  if not term then
    term = Snacks.terminal.open()
  end
  local job_id = vim.b[term.buf].terminal_job_id
  if job_id then
    vim.fn.chansend(job_id, text .. "\n")
  end
end

map("n", "<leader>ts", function()
  send_to_terminal(vim.api.nvim_get_current_line())
end, { desc = "Send line to terminal" })

map("v", "<leader>ts", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then start_line, end_line = end_line, start_line end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
  send_to_terminal(table.concat(lines, "\n"))
end, { desc = "Send selection to terminal" })

-- Terminal mode
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
map("t", "<C-n>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", function() Snacks.terminal.toggle() end, { desc = "Toggle terminal" })

-- Exit insert mode
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Duplicate the visual selection in place.
--
-- One rule covers all three visual modes: the copy is pasted at the END of the
-- selection, so it always lands immediately alongside the original, whichever
-- way the selection extends -- V below the last line, v right after the last
-- character, <C-v> just right of the block (Vim pads short lines itself).
-- Blockwise has to paste from the block's FIRST line at its right edge, since
-- `> is the bottom-right corner and pasting there would stack the copy below
-- the block instead of beside it.
--
-- 'clipboard' is unnamedplus (options.lua), so a bare `y` would wipe the system
-- clipboard. Everything goes through register z, and z plus the unnamed register
-- are restored afterwards. The paste is one buffer change, so a single `u`
-- reverts the whole duplication.
--
-- The new copy is left selected in the same visual mode (via the `[ / `] marks
-- the paste sets), so pressing the key again duplicates that copy: 1, 2, 3...
-- A count pastes that many copies, matching plain `3p`.
local function duplicate_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then return end

  local count = vim.v.count1
  local reg_z = vim.fn.getreginfo("z")
  local reg_unnamed = vim.fn.getreginfo('"')

  vim.cmd('normal! "zy')

  if mode == "\22" then
    -- Vim orders '< and '> by line, not by column, so a block dragged up-and-right
    -- leaves the RIGHT edge on '<. Take the max of the two to find it either way,
    -- clamped to the top line since the cursor can't sit in virtual space here.
    local line = vim.fn.line("'<")
    local right = math.max(vim.fn.col("'<"), vim.fn.col("'>"))
    local col = math.min(right, #vim.fn.getline(line) + 1)
    vim.api.nvim_win_set_cursor(0, { line, math.max(col - 1, 0) })
  else
    vim.cmd("normal! `>")
  end
  vim.cmd('normal! "z' .. count .. "p")

  vim.fn.setreg("z", reg_z)
  -- The unnamed register is a pointer (getreginfo reports points_to), and "zy
  -- re-points it at z. Writing the old contents back into whatever it pointed at
  -- restores both the contents and the pointer; setreg('"', ...) would not, it
  -- would just overwrite z again.
  vim.fn.setreg(reg_unnamed.points_to or '"', reg_unnamed)

  vim.cmd("normal! `[" .. mode .. "`]")
end

map("x", "<M-d>", duplicate_selection, { desc = "Duplicate selection" })
