local parsers = {
	"astro",
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"json5",
	"lua",
	"markdown",
	"markdown_inline",
	"regex",
	"rust",
	"scss",
	"svelte",
	"tsx",
	"typescript",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local installed = require("nvim-treesitter.config").get_installed()
			local missing = vim.tbl_filter(function(parser)
				return not vim.list_contains(installed, parser)
			end, parsers)

			if #missing > 0 then
				require("nvim-treesitter").install(missing)
			end
		end,
	},
	{
		"nvim-mini/mini.pairs",
		version = false,
		event = "InsertEnter",
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
}
