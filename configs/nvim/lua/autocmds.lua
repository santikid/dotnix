vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true, noremap = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(event.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
		bufmap("n", "gD", vim.lsp.buf.declaration)
		bufmap("n", "gd", function()
			require("trouble").toggle("lsp_definitions")
		end)
		bufmap("n", "gr", function()
			require("trouble").toggle("lsp_references")
		end)
		bufmap("n", "gi", function()
			require("trouble").toggle("lsp_implementations")
		end)
		bufmap("n", "K", vim.lsp.buf.hover)
		bufmap("n", "<M-k>", vim.lsp.buf.signature_help)
		bufmap("n", "<space>wa", vim.lsp.buf.add_workspace_folder)
		bufmap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder)
		bufmap("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end)
		bufmap("n", "<space>D", vim.lsp.buf.type_definition)
		bufmap("n", "<space>rn", vim.lsp.buf.rename)
		bufmap("n", "<space>ca", vim.lsp.buf.code_action)
		-- replaced by format-lint/space j
		--bufmap("n", "<space>f", vim.lsp.buf.format)
	end,
})
