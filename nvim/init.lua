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

-- vim.opt.autocomplete = true
vim.opt.complete = "o,.,w,b"

vim.opt.completeopt = "fuzzy,menuone,noselect,popup"

vim.opt.shortmess:append("c")

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
})

-- Keymaps
vim.keymap.set('n', '<leader>cq', ':Cq ', { desc = 'Changelog Actionables' })
vim.keymap.set('n', '<leader>nn', ':Note ', { desc = 'Open A Note' })
vim.keymap.set('n', '<leader><leader>',
    function()
        local l = vim.api.nvim_get_current_line(); local c = vim.api.nvim_win_get_cursor(0)[2] + 1; if l:sub(1, c - 1):match '%[' and l:sub(c):match '%]' then
            vim.api.nvim_set_current_line(l:sub(1, c - 1) .. (l:sub(c, c) == 'x' and ' ' or 'x') .. l:sub(c + 1))
        end
    end, { desc = "Mark a Checkbox" })

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

--- Functions

vim.api.nvim_create_user_command('Note', function(opts)
    local notes_dir = vim.env.NOTES_DIR or '${notes_dir}'

    local args = vim.split(opts.args, '%s+')
    local title = args[1] or ''
    local note_type = args[2] or 'note'
    local date = vim.trim(vim.fn.system("date +\\%Y-\\%m-\\%d"))
    local timestamp = vim.trim(vim.fn.system("date -Iseconds"))

    local template = string.format([[
---
title: "%s"
type: "%s"
timestamp: "%s"
---

# %s

## Key Findings


## Actionable Items


## Raw Notes
```text

```
    ]], title, note_type, timestamp, title)

    local filename = string.format("%s/notes/%s-%s.md", notes_dir, date, title:gsub('%s+', '-'))

    vim.fn.writefile(vim.split(template, "\n"), filename)
    vim.cmd.edit(vim.fn.fnameescape(filename))
end, {
    nargs = '+',
    complete = function(arg_lead, cmd_line, cursor_pos)
        local notes_dir = vim.env.NOTES_DIR or '${notes_dir}'
        local notes_path = notes_dir .. '/notes'

        if vim.fn.isdirectory(notes_path) == 0 then
            return {}
        end

        local files = vim.fn.glob(notes_path .. '/*.md', false, true)
        local completions = {}

        for _, file in ipairs(files) do
            local filename = vim.fn.fnamemodify(file, ':t')
            local title = filename:match('^%d%d%d%d%-%d%d%-%d%d%-(.+)%.md$')
            if title and title:find('^' .. vim.pesc(arg_lead)) then
                table.insert(completions, title)
            end
        end

        return completions
    end
})

vim.api.nvim_create_user_command('Cq', function(opts)
    local notes_dir = vim.env.NOTES_DIR or '${notesDir}'
    local changelog = notes_dir .. '/CHANGELOG.md'
    local project = table.concat(opts.fargs, ' ')
    -- if project == '' then project = nil end
    if project ~= '' then
        vim.fn.execute(string.format('silent! vimgrep /- \\[ \\].*\\[\\[%s\\]\\]/ %s', project, changelog))
    else
        project = nil
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
