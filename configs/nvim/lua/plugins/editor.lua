return {
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		branch = "dev",
		keys = {
			{
				"<leader>t",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
		},
	},
	"machakann/vim-sandwich",
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						n = {
							["<C-q>"] = "send_to_qflist",
						},
					},
				},
				extensions = {
					file_browser = {
						hijack_netrw = true,
					},
				},
			})

			require("telescope").load_extension("file_browser")
		end,

		keys = {
			{
				"<leader>ff",
				"<cmd>Telescope find_files<cr>",
				"Find Files",
			},
			{
				"<leader>fs",
				"<cmd>Telescope live_grep<cr>",
				"Find Files",
			},
			{
				"<leader>fb",
				"<cmd>Telescope file_browser<cr>",
				"Find Files",
			},
		},
	},
}
