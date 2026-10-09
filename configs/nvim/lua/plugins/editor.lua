return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			bufdelete = { enabled = true },
			dashboard = { enabled = false },
			explorer = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			image = { enabled = true },
			lazygit = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			picker = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			rename = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			zen = { enabled = true },
		},
		keys = {
			{
				"<leader>fw",
				function()
					Snacks.picker.grep_word()
				end,
				mode = { "n", "x" },
				desc = "Grep Word / Selection",
			},
			{
				"<leader>fR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume Last Picker",
			},
			{
				"<leader>f/",
				function()
					Snacks.picker.lines()
				end,
				desc = "Search Buffer Lines",
			},
			{
				"<leader>fk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Find Keymaps",
			},
			{
				"<leader>fn",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			{
				"<leader>xx",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Workspace Diagnostics",
			},
			{
				"<leader>xX",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>xq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>cs",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "Document Symbols",
			},
			{
				"<leader>cS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "Workspace Symbols",
			},
			{
				"<leader>cl",
				function()
					Snacks.picker.lsp_references()
				end,
				desc = "References",
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>fa",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>bb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fs",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File Explorer",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Zen Mode",
			},
			{
				"<leader>cr",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"Q",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bo",
				function()
					Snacks.bufdelete.other()
				end,
				desc = "Delete Other Buffers",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {},
		keys = {
			{
				"]c",
				function()
					require("gitsigns").nav_hunk("next")
				end,
				desc = "Next Hunk",
			},
			{
				"[c",
				function()
					require("gitsigns").nav_hunk("prev")
				end,
				desc = "Prev Hunk",
			},
			{
				"<leader>gp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview Hunk",
			},
			{
				"<leader>gr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset Hunk",
			},
			{
				"<leader>gb",
				function()
					require("gitsigns").blame_line()
				end,
				desc = "Blame Line",
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		event = "BufReadPost",
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next TODO",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Prev TODO",
			},
			{
				"<leader>xt",
				function()
					Snacks.picker.todo_comments()
				end,
				desc = "TODOs",
			},
			{
				"<leader>ft",
				function()
					Snacks.picker.todo_comments()
				end,
				desc = "Find TODOs",
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		-- f opens full Flash search; keep F/t/T/;/, as native character motions.
		opts = { modes = { char = { enabled = false } } },
		keys = {
			{
				"f",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},
	{
		"nvim-mini/mini.ai",
		version = false,
		event = "VeryLazy",
		opts = {
			-- Keep Neovim 0.12's an/in syntax-node selection in Visual mode.
			mappings = { around_next = "", inside_next = "" },
		},
	},
	{
		"nvim-mini/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvim-mini/mini.move",
		version = false,
		event = "VeryLazy",
		opts = {
			mappings = {
				left = "<A-h>",
				right = "<A-l>",
				down = "<A-j>",
				up = "<A-k>",
				line_left = "<A-h>",
				line_right = "<A-l>",
				line_down = "<A-j>",
				line_up = "<A-k>",
			},
		},
	},
	{
		"nvim-mini/mini.tabline",
		version = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvim-mini/mini.icons",
		version = false,
		lazy = true,
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}
