return {
	{
		"folke/which-key.nvim",
		lazy = false,
		config = function()
			local wk = require("which-key")
			wk.register({
				["ß"] = { "`", "Jump to mark" },
				["ü"] = { "{", "Left brace" },
				["+"] = { "}", "Right brace" },
			})
		end,
	},
}
