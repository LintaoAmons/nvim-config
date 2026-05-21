vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt

-- General
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.cmdheight = 0

-- UI
opt.breakindent = true
opt.cursorline = true
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.number = true
opt.relativenumber = true
opt.pumheight = 10
opt.showmode = false
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.termguicolors = true
opt.wrap = false

opt.fillchars = table.concat({
  "eob: ", "fold:╌", "horiz:═", "horizdown:╦", "horizup:╩",
  "vert:║", "verthoriz:╬", "vertleft:╣", "vertright:╠",
}, ",")
opt.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
opt.shortmess:append("aoOWFcC")

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.infercase = true
opt.virtualedit = "block"
opt.formatoptions = "rqnl1j"
opt.iskeyword:append("-")
opt.completeopt = "menuone,noinsert,noselect"
