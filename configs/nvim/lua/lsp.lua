-- lsp keybindings
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true, noremap = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(event.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
		bufmap('n', 'gD', vim.lsp.buf.declaration)
		bufmap('n', 'gd', function() require("trouble").toggle("lsp_definitions") end)
		bufmap('n', 'gr', function() require("trouble").toggle("lsp_references") end)
		bufmap('n', 'gi', function() require("trouble").toggle("lsp_implementations") end)
		bufmap('n', 'K', vim.lsp.buf.hover)
		bufmap('n', '<M-k>', vim.lsp.buf.signature_help)
		bufmap('n', '<space>wa', vim.lsp.buf.add_workspace_folder)
		bufmap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder)
		bufmap('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end)
		bufmap('n', '<space>D', vim.lsp.buf.type_definition)
		bufmap('n', '<space>rn', vim.lsp.buf.rename)
		bufmap('n', '<space>ca', vim.lsp.buf.code_action)
		bufmap('n', '<space>f', vim.lsp.buf.format)
	end
})

-- setup mason
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = {
		'rust_analyzer',
		'lua_ls',
		'tsserver',
		'astro',
		'tailwindcss',
		'svelte'
	}
})

-- setup lspconfig + mason
local lspconfig = require("lspconfig")

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason-lspconfig').setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({
			capabilities = lsp_capabilities,
		})
	end,
})


-- setup null-ls
local null_ls = require("null-ls")

null_ls.setup {
	debug = true,
	filetypes = { "svelte" },
	sources = {
		require("null-ls").builtins.formatting.prettier,
		require("null-ls").builtins.code_actions.eslint
	}
}

-- Setup nvim-cmp.
local cmp = require 'cmp'

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
    { name = 'path' },
	})
})
