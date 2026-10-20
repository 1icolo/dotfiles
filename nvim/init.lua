vim.opt.termguicolors = false
-- vim.cmd("colorscheme onedark")
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.autochdir = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.autocomplete = true
vim.opt.complete = "o,.,w,b"

vim.opt.completeopt = "fuzzy,menuone,noselect,popup"

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
	if project == '' then project = nil end
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
end, {
	nargs = '*',
	complete = function()
		local notes_dir = vim.env.NOTES_DIR or '${notesDir}'
		local lines = vim.fn.readfile(notes_dir .. '/CHANGELOG.md')
		local projects, seen = {}, {}
		for _, line in ipairs(lines) do
			for p in line:gmatch('%[%[([^%]]+)%]%]') do
				if not seen[p] then
					seen[p] = true; table.insert(projects, p)
				end
			end
		end
		return projects
	end
})

-- Keymaps
vim.keymap.set('n', '<leader>cq', ':Cq ', { desc = 'Changelog Actionables' })
vim.keymap.set('n', '<leader><leader>', 'sx<Esc>', { desc = 'Mark Checkbox', remap = true })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- LSP
vim.lsp.config('*', {
	capabilities = capabilities,
	root_markers = { '.git' },
})

vim.lsp.config('markdown_oxide', {
	cmd = { 'markdown-oxide' },
	filetypes = { 'markdown' },
})

vim.lsp.config('rust_analyzer', {
	cmd = { 'rust-analyzer' },
	filetypes = { 'rust' },
	root_markers = { 'Cargo.toml' }
})

vim.lsp.config('nil_ls', {
	cmd = { 'nil' },
	filetypes = { 'nix' },
	root_markers = { 'flake.nix', 'flake.lock' }
})

vim.lsp.config('nixd', {
	cmd = { 'nixd' },
	filetypes = { 'nix' }
})

vim.lsp.config('lua_ls', {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' }
})

vim.lsp.config('ruff', {
	cmd = { 'ruff' },
	filetypes = { 'python' },
	root_markers = { 'pyproject.toml' }
})

vim.lsp.config('ts_ls', {
	cmd = { 'typescript-language-server', '--stdio' },
	filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
	root_markers = { 'package.json', 'tsconfig.json' }
})

vim.lsp.config('terraformls', {
	cmd = { 'terraform-ls', 'serve' },
	filetypes = { 'terraform', 'hcl' }
})

vim.lsp.config('tailwindcss', {
	cmd = { 'tailwindcss-language-server', '--stdio' },
	filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact' }
})

vim.lsp.enable({
	'markdown_oxide',
	'rust_analyzer',
	'nil_ls',
	'nixd',
	'lua_ls',
	'ruff',
	'ts_ls',
	'terraformls',
	'tailwindcss'
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if client:supports_method('textDocument/implementation') then
			-- Create a keymap for vim.lsp.buf.implementation ...
		end

		-- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
		if client:supports_method('textDocument/completion') then
			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
			-- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
			-- client.server_capabilities.completionProvider.triggerCharacters = chars
			--

			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		-- Auto-format ("lint") on save.
		-- Usually not needed if server supports "textDocument/willSaveWaitUntil".
		if not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end
	end,
})
