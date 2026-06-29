return { -- colorscheme
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("kanagawa").setup({
				theme = "wave",
				background = {
					dark = "wave",
					light = "lotus",
				},
				colors = {
					theme = {
						wave = {
							ui = {
								bg = "#111318",
								bg_gutter = "#111318",
								bg_m3 = "#111318",
								bg_m2 = "#171a21",
								bg_m1 = "#1b2029",
								bg_p1 = "#222734",
								bg_p2 = "#2d3443",
								special = "#7dd3fc",
							},
						},
					},
				},
				overrides = function()
					return {
						Normal = { bg = "#111318", fg = "#f4f7fb" },
						NormalFloat = { bg = "#1b2029" },
						FloatBorder = { bg = "#1b2029", fg = "#667085" },
						SignColumn = { bg = "#111318" },
						LineNr = { bg = "#111318", fg = "#667085" },
						CursorLineNr = { bg = "#111318", fg = "#7dd3fc", bold = true },
						Visual = { bg = "#2d3443" },
						Pmenu = { bg = "#1b2029", fg = "#f4f7fb" },
						PmenuSel = { bg = "#7dd3fc", fg = "#071118", bold = true },
						Search = { bg = "#f6c177", fg = "#111318" },
						IncSearch = { bg = "#ff7b8a", fg = "#111318" },
					}
				end,
			})
			vim.cmd.colorscheme("kanagawa-wave")
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
