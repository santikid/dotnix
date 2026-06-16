local capabilities = vim.lsp.protocol.make_client_capabilities()
local blink_ok, blink = pcall(require, "blink.cmp")

if blink_ok then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config("*", {
	capabilities = capabilities,
})

local servers = {
	nixd = {
		cmd = { "nixd" },
		filetypes = { "nix" },
		root_markers = { "flake.nix", "default.nix", ".git" },
	},
	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	},
	svelte = {
		cmd = { "svelteserver", "--stdio" },
		filetypes = { "svelte" },
		root_markers = { "svelte.config.js", "svelte.config.cjs", "svelte.config.mjs", "package.json", ".git" },
	},
	eslint = {
		cmd = { "vscode-eslint-language-server", "--stdio" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
		},
		root_markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
		},
		settings = {
			codeActionOnSave = {
				enable = false,
				mode = "all",
			},
			format = false,
			packageManager = "pnpm",
			quiet = false,
			validate = "on",
		},
	},
	oxlint = {
		cmd = { "oxlint", "--lsp" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
		root_markers = {
			".oxlintrc.json",
			".oxlintrc.jsonc",
		},
	},
	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { "package.json", ".git" },
	},
	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { "package.json", ".git" },
	},
	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json", "jsonc" },
		root_markers = { "package.json", ".git" },
	},
}

for name, config in pairs(servers) do
	vim.lsp.config[name] = config
end

vim.lsp.enable(vim.tbl_keys(servers))
