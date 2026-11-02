local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Start Treesitter highlighting when a parser is available",
	callback = function(event)
		local filetype = vim.bo[event.buf].filetype
		if vim.bo[event.buf].buftype ~= "" or filetype == "bigfile" then
			return
		end
		local lang = vim.treesitter.language.get_lang(filetype)
		if lang then
			-- Uninstalled parsers should not prevent opening a file.
			pcall(vim.treesitter.start, event.buf, lang)
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	desc = "LSP actions",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == "ruff" then
			-- Pyright owns Python hover/type information; Ruff owns lint actions.
			client.server_capabilities.hoverProvider = false
		end

		local function bufmap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
		end

		bufmap("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
		bufmap("n", "gd", function()
			Snacks.picker.lsp_definitions()
		end, "Go to Definition")
		bufmap("n", "grr", function()
			Snacks.picker.lsp_references()
		end, "References")
		bufmap("n", "gi", function()
			Snacks.picker.lsp_implementations()
		end, "Go to Implementation")
		bufmap("n", "K", vim.lsp.buf.hover, "Hover Documentation")
		bufmap("n", "<leader>ck", vim.lsp.buf.signature_help, "Signature Help")
		bufmap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
		bufmap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
		bufmap("n", "<leader>wl", function()
			vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "List Workspace Folders")
		bufmap("n", "<leader>D", function()
			Snacks.picker.lsp_type_definitions()
		end, "Go to Type Definition")
		bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
		bufmap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	end,
})
