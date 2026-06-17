local function push_unnamed_to_system_clipboard()
	local contents = vim.fn.getreg('"', 1, true)
	local regtype = vim.fn.getregtype('"')

	if #contents == 0 then
		vim.notify("Unnamed register is empty", vim.log.levels.WARN)
		return
	end

	vim.fn.setreg("+", contents, regtype)
	vim.notify("Copied unnamed register to system clipboard")
end

local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "Switch left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch up" })

map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

map({ "n", "x" }, "<leader>y", '"+y', {
	desc = "Yank to system clipboard",
})

map("n", "<leader>Y", push_unnamed_to_system_clipboard, {
	desc = "Copy unnamed register to system clipboard",
})
