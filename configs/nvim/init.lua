-- install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  "folke/zen-mode.nvim",
  "nvim-lua/plenary.nvim",

  -- Colorscheme
  'rebelot/kanagawa.nvim',

  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',

  'machakann/vim-sandwich',

  {
    'NeogitOrg/neogit',
    dependencies = 'nvim-lua/plenary.nvim'
  },

  -- devicons are needed by barbar & lualine, ...
  'nvim-tree/nvim-web-devicons',

  'nvim-tree/nvim-tree.lua',

  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
  },

  -- tab bar
  'romgrk/barbar.nvim',

  -- status line
  'nvim-lualine/lualine.nvim',

  -- fzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim'
  },
  "nvim-telescope/telescope-file-browser.nvim",

  'nvim-treesitter/nvim-treesitter',
  'nvim-treesitter/nvim-treesitter-context',

  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
  },
  "saadparwaiz1/cmp_luasnip",

  'nvimtools/none-ls.nvim',

  'github/copilot.vim',

  {
    "akinsho/toggleterm.nvim",
    version = '*'
  },

  "mg979/vim-visual-multi",

  -- lazy.nvim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },

  "folke/neodev.nvim",
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.integrations.treesitter"] = {},
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp"
            }
          },
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.export"] = {},
          ["core.export.markdown"] = {},
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/Notes",
              },
            },
          },
        },
      }
    end,
  },
})

require('settings')
require('plugins-config')
require('lsp')
require('keys')
