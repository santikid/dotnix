return { -- colorscheme
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  -- neovim dev
  "folke/neodev.nvim",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true,         -- use a classic bottom cmdline for search
          command_palette = true,       -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,           -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
      })
    end,
  },
  {
    "romgrk/barbar.nvim",
    lazy = false,
    keys = {
      {
        "<leader>n",
        "<Cmd>BufferNext<cr>",
        "Next buffer",
      },
      {
        "<leader>m",
        "<Cmd>BufferPrevious<cr>",
        "Previous buffer",
      },
      {
        "<leader>q",
        "<Cmd>BufferClose<cr>",
        "Close buffer",
      },
      {
        "<leader>1",
        "<Cmd>BufferGoto 1<cr>",
        "Go to buffer 1",
      },
      {
        "<leader>2",
        "<Cmd>BufferGoto 2<cr>",
        "Go to buffer 2",
      },
      {
        "<leader>3",
        "<Cmd>BufferGoto 3<cr>",
        "Go to buffer 3",
      },
      {
        "<leader>4",
        "<Cmd>BufferGoto 4<cr>",
        "Go to buffer 4",
      },
      {
        "<leader>5",
        "<Cmd>BufferGoto 5<cr>",
        "Go to buffer 5",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "kanagawa",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {},
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype", { require("noice").api.statusline.mode.get, cond = require("noice").api.statusline.mode.has, color = { fg = "#ff9e64" } } },
          lualine_y = { "searchcount", "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
      })
    end,
  },
}
