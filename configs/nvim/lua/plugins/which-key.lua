return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>f", group = "find" },
				{ "<leader>s", group = "split" },
				{ "<leader>c", group = "code" },
				{ "<leader>g", group = "git" },
				{ "<leader>x", group = "diagnostics" },
			},
		},
	},
}
