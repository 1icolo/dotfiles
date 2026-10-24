local M = {}

vim.opt.termguicolors = false
-- vim.cmd("colorscheme onedark")
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.autochdir = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- vim.opt.autocomplete = true
vim.opt.complete = "o,.,w,b"

vim.opt.completeopt = "fuzzy,menuone,noselect,popup"

vim.opt.shortmess:append("c")

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

return M
