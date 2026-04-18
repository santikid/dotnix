return {
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("minuet").setup({
				virtualtext = {
					auto_trigger_ft = { "*" },
					keymap = {
						accept = "<Tab>",
						accept_line = "<A-a>",
						dismiss = "<A-e>",
					},
				},
				provider = "openai_compatible",
				throttle = 1000,
				debounce = 400,
				provider_options = {
					openai_compatible = {
						api_key = function()
							return os.getenv("OPENROUTER_API_KEY")
						end,
						end_point = "https://openrouter.ai/api/v1/chat/completions",
						model = "qwen/qwen3-coder",
						optional = {
							max_tokens = 128,
							top_p = 0.9,
						},
					},
				},
			})
		end,
	},
}
