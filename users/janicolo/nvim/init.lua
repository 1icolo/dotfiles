package.path = package.path .. ';' .. vim.fn.stdpath("config") .. '/lua/?.lua'

-- Settings
require('settings')

-- LSP
require('lsp')

--- Functions

require('notes')