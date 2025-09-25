return {
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"rust",
					"javascript",
					"typescript",
					"tsx",
					"json",
					"json5",
					"css",
					"scss",
					"html",
					"astro",
					"svelte",
					"lua",
					"regex",
					"bash",
					"markdown",
					"markdown_inline",
				},

				ignore_install = {},

				modules = {},

				auto_install = true,

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = true,

				highlight = {
					-- `false` will disable the whole extension
					enable = true,

					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
}
