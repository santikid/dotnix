local set = vim.opt
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.relativenumber = true
set.expandtab = true

-- fold with treesitter 
set.foldmethod = "expr"
set.foldexpr = "nvim_treesitter#foldexpr()"
set.foldlevelstart = 99

vim.cmd 'colorscheme kanagawa'

set.mouse = "a"
set.clipboard = "unnamed"

vim.cmd([[
set guifont=JetBrainsMono\ Nerd\ Font:h13
]])

