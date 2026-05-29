vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set nowrap")
vim.g.mapleader = " "
vim.nowrap = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Set ctlr-v to visual block mode 
vim.keymap.set("n", "<C-v>", "<C-v>", {noremap = true, silent = true})
