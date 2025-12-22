return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
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
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
		keys = {
			-- no idea where this would go otherwise, snacks probably makes some sense
			{
				"<C-h>",
				"<C-w>h",
				desc = "Switch left",
			},
			{
				"<C-l>",
				"<C-w>l",
				desc = "Switch right",
			},
			{
				"<C-j>",
				"<C-w>j",
				desc = "Switch down",
			},
			{
				"<C-k>",
				"<C-w>k",
				desc = "Switch up",
			},
			{
				"<leader>sv",
				"<C-w>v",
				desc = "Split vertical",
			},
			{
				"<leader>sh",
				"<C-w>s",
				desc = "Split horizontal",
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Commands",
			},
			{
				"<leader>fa",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>b",
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
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Diagnostics (Trouble) in current buffer",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle<cr>",
				desc = " (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "QF-list (Trouble)",
			},
		},
	},
	"machakann/vim-sandwich",
}
