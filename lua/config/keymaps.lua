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

-- Better navigation
map("n", "j", "gj", { desc = "Move down wrapped lines" })
map("n", "k", "gk", { desc = "Move up wrapped lines" })

-- Better paste in visual mode
map("v", "p", "P", { desc = "Paste without overwriting register" })

-- Exit insert mode
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
