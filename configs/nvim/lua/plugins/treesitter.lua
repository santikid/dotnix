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
	"nix",
	"python",
	"regex",
	"rust",
	"scss",
	"svelte",
	"swift",
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
			-- The installer skips existing languages and also installs inherited
			-- queries (ecma, jsx, html_tags), which do not have parser binaries.
			require("nvim-treesitter").install(parsers)
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
