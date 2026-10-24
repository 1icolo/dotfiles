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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
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

vim.keymap.set('n', '<leader>na', ':NoteActionables ', { desc = 'View Actionables' })
vim.keymap.set('n', '<leader><leader>',
  function()
    local l = vim.api.nvim_get_current_line(); local c = vim.api.nvim_win_get_cursor(0)[2] + 1; if l:sub(1, c - 1):match '%[' and l:sub(c):match '%]' then
      vim.api.nvim_set_current_line(l:sub(1, c - 1) .. (l:sub(c, c) == 'x' and ' ' or 'x') .. l:sub(c + 1))
    end
  end, { desc = "Mark a Checkbox" })


-- Note: Create a new note with frontmatter template
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

-- Cq: Find actionables in CHANGELOG.md
vim.api.nvim_create_user_command('Cq', function(opts)
  local notes_dir = vim.env.NOTES_DIR or '${notesDir}'
  local changelog = notes_dir .. '/CHANGELOG.md'
  local project = table.concat(opts.fargs, ' ')
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

-- NoteActionables: Find checkbox items in notes, optionally filtered by project (frontmatter)
-- Usage: :NoteActionables [project] [all]
--   project: optional, filters by frontmatter project: field
--   all: optional flag, includes checked items (- [x]); default shows only empty (- [ ])
vim.api.nvim_create_user_command('NoteActionables', function(opts)
  local notes_dir = vim.env.NOTES_DIR or '${notes_dir}'
  local notes_path = notes_dir .. '/notes'

  if vim.fn.isdirectory(notes_path) == 0 then
    print('Notes directory not found: ' .. notes_path)
    return
  end

  -- Parse arguments: first non-"all" word is project, "all" anywhere enables all items
  local args = vim.split(opts.args, '%s+')
  local project_filter = nil
  local show_all = false
  for _, arg in ipairs(args) do
    if arg:lower() == 'all' then
      show_all = true
    elseif arg ~= '' and not project_filter then
      project_filter = arg
    end
  end

  local files = vim.fn.glob(notes_path .. '/**/*.md', false, true)
  local qf_items = {}

  for _, file in ipairs(files) do
    local lines = vim.fn.readfile(file)
    local in_frontmatter = false
    local file_project = nil
    local frontmatter_done = false

    -- First pass: extract project from frontmatter
    for i, line in ipairs(lines) do
      if i == 1 and line == '---' then
        in_frontmatter = true
      elseif in_frontmatter then
        if line == '---' then
          in_frontmatter = false
          frontmatter_done = true
          break
        end
        local proj = line:match('^project:%s*["\']?([^"\']+)["\']?%s*$')
        if proj then
          file_project = vim.trim(proj)
        end
      elseif frontmatter_done then
        break
      end
    end

    -- Skip if project filter doesn't match
    if project_filter and file_project ~= project_filter then
      goto continue
    end

    -- Second pass: find checkboxes
    for lnum, line in ipairs(lines) do
      local checkbox = line:match('^%s*%- %[([ xX])%]')
      if checkbox then
        local is_done = checkbox:lower() == 'x'
        -- Skip done items unless show_all is true
        if not show_all and is_done then
          goto next_checkbox
        end
        local text = line:gsub('^%s*%- %[[ xX]%]%s*', ''):gsub('^%s+', '')
        -- Extract title from frontmatter
        local file_title = nil
        local in_fm = false
        for i, l in ipairs(lines) do
          if i == 1 and l == '---' then
            in_fm = true
          elseif in_fm then
            if l == '---' then break end
            local t = l:match('^title:%s*["\']?([^"\']+)["\']?%s*$')
            if t then file_title = vim.trim(t) end
          else
            break
          end
        end
        local display_text = file_title and string.format('%s, %s', file_title, text) or text
        table.insert(qf_items, {
          filename = file,
          lnum = lnum,
          col = 1,
          text = string.format('[%s] %s', is_done and 'x' or ' ', display_text),
          type = is_done and 'I' or 'W',
        })
        ::next_checkbox::
      end
    end

    ::continue::
  end

  if #qf_items == 0 then
    local msg_parts = {}
    if project_filter then table.insert(msg_parts, 'for project: ' .. project_filter) end
    if show_all then table.insert(msg_parts, '(including done)') end
    local msg = 'No actionables found'
    if #msg_parts > 0 then msg = msg .. ' ' .. table.concat(msg_parts, ' ') end
    print(msg)
    return
  end

  vim.fn.setqflist(qf_items, 'r')
  vim.fn.execute('copen')

  local count_open = 0
  for _, item in ipairs(qf_items) do
    if item.type == 'W' then count_open = count_open + 1 end
  end
  local count_done = #qf_items - count_open
  local msg_parts = {}
  if project_filter then table.insert(msg_parts, 'project: ' .. project_filter) end
  if show_all then table.insert(msg_parts, 'all') end
  local project_msg = #msg_parts > 0 and (' (' .. table.concat(msg_parts, ', ') .. ')') or ''
  print(string.format('Found %d actionables%s (%d open, %d done)', #qf_items, project_msg, count_open, count_done))
end, {
  nargs = '*',
  complete = function(arg_lead, cmd_line, cursor_pos)
    local notes_dir = vim.env.NOTES_DIR or '${notes_dir}'
    local notes_path = notes_dir .. '/notes'

    if vim.fn.isdirectory(notes_path) == 0 then
      return {}
    end

    local files = vim.fn.glob(notes_path .. '/**/*.md', false, true)
    local projects, seen = {}, {}

    for _, file in ipairs(files) do
      local lines = vim.fn.readfile(file)
      local in_frontmatter = false
      for i, line in ipairs(lines) do
        if i == 1 and line == '---' then
          in_frontmatter = true
        elseif in_frontmatter then
          if line == '---' then
            break
          end
          local proj = line:match('^project:%s*["\']?([^"\']+)["\']?%s*$')
          if proj then
            proj = vim.trim(proj)
            if not seen[proj] and proj:find('^' .. vim.pesc(arg_lead)) then
              seen[proj] = true
              table.insert(projects, proj)
            end
          end
        end
      end
    end

    -- Add "all" as a completion option
    if ('all'):find('^' .. vim.pesc(arg_lead)) then
      table.insert(projects, 'all')
    end

    return projects
  end,
  desc = 'Find actionable items (checkboxes) in notes. Args: [project] [all]'
})

-- Old Config

-- package.path = package.path .. ';' .. vim.fn.stdpath("config") .. '/lua/?.lua'
--
-- -- Settings
-- require('settings')
--
-- -- LSP
-- require('lsp')
--
-- --- Functions
--
-- require('notes')
