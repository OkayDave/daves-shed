-- General sane defaults from .ideavimrc
vim.g.mapleader = " "

local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.number = true
opt.relativenumber = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.timeoutlen = 400

-- Indentation defaults (often expected in modern configs)
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true
opt.smartindent = true

-- Search settings
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
