local map = vim.keymap.set

-- General
map("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit all" })
map("n", "<leader>nl", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Better navigation
map("n", "j", "gj", { desc = "Move down wrapped lines" })
map("n", "k", "gk", { desc = "Move up wrapped lines" })

-- Better paste in visual mode
map("v", "p", "P", { desc = "Paste without overwriting register" })

-- Exit insert mode
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
