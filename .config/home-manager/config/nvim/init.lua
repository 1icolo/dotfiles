vim.opt.termguicolors = true   
vim.cmd("colorscheme onedark")
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.autochdir = true   

vim.o.autocomplete = true
vim.o.complete = "o,.,w,b"

vim.o.completeopt = "fuzzy,menuone,noselect,popup"

vim.opt.shortmess:append("c")

vim.diagnostic.config({
virtual_text = true,
signs = true,
update_in_insert = false,
})

vim.api.nvim_create_user_command('Cq', function(opts)
local notes_dir = vim.env.NOTES_DIR or '${notesDir}'
local changelog = notes_dir .. '/CHANGELOG.md'
local project = table.concat(opts.fargs, ' ')
if project == ''' then project = nil end
if project then
  vim.fn.execute(string.format('silent! vimgrep /- \\[ \\].*\\[\\[%s\\]\\]/ %s', project, changelog))
else
  vim.fn.execute(string.format('silent! vimgrep /- \\[ \\]/ %s', changelog))
end
if #vim.fn.getqflist() == 0 then
  print(project and ('No open actionables for ' .. project) or 'No open actionables')
else
  vim.fn.execute('copen')
end
end, { nargs = '*', complete = function()
local notes_dir = vim.env.NOTES_DIR or '${notesDir}'
local lines = vim.fn.readfile(notes_dir .. '/CHANGELOG.md')
local projects, seen = {}, {}
for _, line in ipairs(lines) do
  for p in line:gmatch('%[%[([^%]]+)%]%]') do
    if not seen[p] then seen[p] = true; table.insert(projects, p) end
  end
end
return projects
end })

-- Keymaps
vim.keymap.set('n', '<leader>cq', ':Cq ', { desc = 'Changelog Actionables' })
vim.keymap.set('n', '<leader><leader>', 'sx<Esc>', { desc = 'Mark Checkbox', remap = true })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- LSP
vim.lsp.config('markdown', {
cmd = { 'markdown-oxide' },
filetypes = { 'markdown' },
root_markers = { '.git', '.obsidian', '.moxide.toml' },
capabilities = capabilities,
})
vim.lsp.enable('markdown')

vim.lsp.config('rust', {
cmd = { 'rust-analyzer' },
filetypes = { 'rust' },
root_markers = { '.git', 'Cargo.toml'  },
capabilities = capabilities,
})
vim.lsp.enable('rust')

vim.lsp.config('nix', {
cmd = { 'nil' },
filetypes = { 'nix' },
root_markers = { '.git', 'flake.nix', 'flake.lock' },
capabilities = capabilities,
})
vim.lsp.enable('nix')

vim.lsp.config('lua', {
cmd = { 'luals' },
filetypes = { 'lua' },
root_markers = { '.git', '.lua' },
capabilities = capabilities,
})
vim.lsp.enable('lua')

vim.lsp.config('python', {
cmd = { 'ruff' },
filetypes = { 'python' },
root_markers = { '.git', 'pyproject.toml' },
capabilities = capabilities,
})
vim.lsp.enable('python')

vim.lsp.config('typescript', {
cmd = { 'typescript-language-server' },
filetypes = { 'typescript', 'typescriptreact' },
root_markers = { '.git', '.ts', 'package.json' },
capabilities = capabilities,
})
vim.lsp.enable('typescript')

