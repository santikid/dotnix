require("nvim-autopairs").setup {}
require('nvim-ts-autotag').setup()

require("toggleterm").setup {}

require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "rust", "javascript", "typescript", "tsx", "json", "json5", "css", "scss", "html", "astro", "svelte", "lua", "regex", "bash", "markdown", "markdown_inline" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    additional_vim_regex_highlighting = false,
  },
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'kanagawa',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'fern' }
}

require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["<C-q>"] = "send_to_qflist",
      }
    }
  },
  extensions = {
    file_browser = {
      hijack_netrw = true,
    },
  },
}

require("telescope").load_extension "file_browser"

require('neogit').setup {}

require('neodev').setup {}

require('nvim-tree').setup {
  disable_netrw = false,
  hijack_netrw = false,
}

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
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
