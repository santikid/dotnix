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
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		config = function()
			require("harpoon"):setup()
		end,
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
					print("! added to harpoon !")
				end,
				"Add to harpoon",
			},
			{
				"<localleader>c",
				function()
					require("harpoon"):list():clear()
					print("! cleared harpoon !")
				end,
				"Go to next harpoon",
			},
			{
				"<localleader>e",
				function()
					require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
				end,
				"Harpoon menu",
			},
			{
				"<localleader>n",
				function()
					require("harpoon"):list():next()
				end,
				"Go to prev. harpoon",
			},
			{
				"<localleader>m",
				function()
					require("harpoon"):list():prev()
				end,
				"Go to next harpoon",
			},
			{
				"<localleader>a",
				function()
					require("harpoon"):list():select(1)
				end,
				"Select harpoon 1",
			},
			{
				"<localleader>s",
				function()
					require("harpoon"):list():select(2)
				end,
				"Select harpoon 2",
			},
			{
				"<localleader>d",
				function()
					require("harpoon"):list():select(3)
				end,
				"Select harpoon 3",
			},
			{
				"<localleader>f",
				function()
					require("harpoon"):list():select(4)
				end,
				"Select harpoon 4",
			},
		},
	},
}
