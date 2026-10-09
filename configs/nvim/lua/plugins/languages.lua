local servers = {
	"lua_ls",
	"pyright",
	"ruff",
	"nixd",
	"sourcekit",
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
			vim.lsp.config("pyright", {
				settings = { pyright = { disableOrganizeImports = true } },
			})
			vim.lsp.enable(servers)
		end,
	},
}
