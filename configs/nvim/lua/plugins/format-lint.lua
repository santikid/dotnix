local function format()
	require("conform").format({ async = true })
end

return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{ "<leader>j", format, mode = { "n", "x" }, desc = "Format Buffer / Selection" },
			{ "<leader>cf", format, mode = { "n", "x" }, desc = "Format Buffer / Selection" },
			{
				"<leader>cF",
				function()
					vim.b.disable_autoformat = not vim.b.disable_autoformat
					vim.notify("Format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
				end,
				desc = "Toggle Buffer Format on Save",
			},
		},
		opts = {
			default_format_opts = { lsp_format = "fallback" },
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "alejandra" },
				python = { "ruff_format" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				javascript = { "oxfmt" },
				javascriptreact = { "oxfmt" },
				typescript = { "oxfmt" },
				typescriptreact = { "oxfmt" },
				json = { "oxfmt" },
				jsonc = { "oxfmt" },
				json5 = { "oxfmt" },
				yaml = { "oxfmt" },
				toml = { "oxfmt" },
				html = { "oxfmt" },
				css = { "oxfmt" },
				scss = { "oxfmt" },
				less = { "oxfmt" },
				vue = { "oxfmt" },
				markdown = { "oxfmt" },
				["markdown.mdx"] = { "oxfmt" },
				graphql = { "oxfmt" },
				-- Use each project's Prettier and framework plugin configuration.
				-- Oxfmt does not load arbitrary Prettier plugins.
				svelte = { "prettier" },
				astro = { "prettier" },
			},
			format_on_save = function(bufnr)
				if
					vim.b[bufnr].disable_autoformat
					or vim.bo[bufnr].buftype ~= ""
					or vim.bo[bufnr].filetype == "bigfile"
				then
					return
				end
				return { timeout_ms = 1000 }
			end,
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
