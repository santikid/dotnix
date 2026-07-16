local servers = {
	"nixd",
	"ts_ls",
	"svelte",
	"eslint",
	"oxlint",
	"html",
	"cssls",
	"jsonls",
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})
			vim.lsp.enable(servers)
		end,
	},
}
