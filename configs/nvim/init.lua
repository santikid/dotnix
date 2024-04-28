local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.opt.clipboard = "unnamed";
vim.opt.tabstop = 2;
vim.opt.softtabstop = 2;

vim.g.mapleader = " ";

require("lazy").setup({ spec = { { import = "plugins" } } });
require("autocmds");
