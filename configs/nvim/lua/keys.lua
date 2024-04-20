vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opts = { noremap = true, silent = true }

local ts = require('telescope.builtin')
local ts_fb = require('telescope').extensions.file_browser

local wk = require("which-key")

wk.register({
  f = {
    name = "Files & Finders",
    f = { ts.find_files, "Find files" },
    g = { ts.git_files, "Find git files" },
    s = { ts.live_grep, "Search" },
    b = { ts_fb.file_browser, "File Browser" },
    o = { ts.oldfiles, "Old files / History" },
    t = { require("nvim-tree.api").tree.toggle, "Toggle file tree" }
  }
}, { prefix = "<leader>", silent = true })

wk.register({
  w = {
    name = "Window",
    h = { "<C-w>h", "Move left" },
    j = { "<C-w>j", "Move down" },
    k = { "<C-w>k", "Move up" },
    l = { "<C-w>l", "Move right" },
    v = { "<C-w>v", "Split vertically" },
    s = { "<C-w>s", "Split horizontally" },
    q = { "<C-w>q", "Close window" },
    o = { "<C-w>o", "Close other windows" },
  }
}, { prefix = "<leader>", silent = true })

-- quick window navigation
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', opts)
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', opts)

wk.register({
  n = { "<Cmd>BufferNext<CR>", "Next buffer" },
  m = { "<Cmd>BufferPrevious<CR>", "Prev. buffer"},
  q = { "<Cmd>BufferClose<CR>", "Close buffer" }
}, { prefix = "<leader>", silent = true })

wk.register({
  b = {
    name = "Buffers",
    ["1"] = { "<Cmd>BufferGoto 1<CR>", "Go to buffer 1" },
    ["2"] = { "<Cmd>BufferGoto 2<CR>", "Go to buffer 2" },
    ["3"] = { "<Cmd>BufferGoto 3<CR>", "Go to buffer 3" },
    ["4"] = { "<Cmd>BufferGoto 4<CR>", "Go to buffer 4" },
    ["5"] = { "<Cmd>BufferGoto 5<CR>", "Go to buffer 5" },
    ["6"] = { "<Cmd>BufferGoto 6<CR>", "Go to buffer 6" },
    ["7"] = { "<Cmd>BufferGoto 7<CR>", "Go to buffer 7" },
    ["8"] = { "<Cmd>BufferGoto 8<CR>", "Go to buffer 8" },
    ["9"] = { "<Cmd>BufferGoto 9<CR>", "Go to buffer 9" },
  }
}, { prefix = "<leader>", silent = true })


wk.register({
  z = { require("zen-mode").toggle, "Zen mode" },
  g = { require("neogit").open, "Neogit" },
  t = { function() require("trouble").toggle("workspace_diagnostics") end, "Trouble" },
}, { prefix = "<leader>", silent = true })

wk.register({
  ["ß"] = { "`", "Jump to mark" },
  ["ü"] = { "{", "Left brace" },
  ["+"] = { "}", "Right brace" },
})

vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-N>', opts)

-- keybindings for multi-cursor
vim.g.VM_maps = {
	["Select Cursor Down"] = '<A-j>',
	["Select Cursor Up"] = '<A-k>'
}
