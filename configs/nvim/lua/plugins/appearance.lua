return { -- colorscheme
	{
		"loctvl842/monokai-pro.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("monokai-pro").setup({ filter = "spectrum" })
			vim.cmd.colorscheme("monokai-pro")
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = false,
				},
			})
		end,
	},
	{
		"nvim-mini/mini.statusline",
		version = false,
		config = function()
			local sl = require("mini.statusline")
			sl.setup({
				use_icons = true,
				content = {
					active = function()
						local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
						local git = sl.section_git({ trunc_width = 40 })
						local diff = sl.section_diff({ trunc_width = 75 })
						local diag = sl.section_diagnostics({ trunc_width = 75 })
						local filename = sl.section_filename({ trunc_width = 140 })
						local filetype = sl.section_fileinfo({ trunc_width = 120 })
						local location = sl.section_location({ trunc_width = 75 })
						local search = sl.section_searchcount({ trunc_width = 75 })

						return sl.combine_groups({
							{ hl = mode_hl, strings = { mode } },
							{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diag } },
							"%<",
							{ hl = "MiniStatuslineFilename", strings = { filename } },
							"%=",
							{ hl = "MiniStatuslineFileinfo", strings = { filetype } },
							{ hl = mode_hl, strings = { search, location } },
						})
					end,
				},
			})
		end,
	},
}
