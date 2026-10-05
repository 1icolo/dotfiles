{ pkgs, pkgsUnstable, ... }:

let
  notesDir = "$HOME/work";
in
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "26.05";

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    NOTES_DIR = notesDir;
  };

  programs.yazi = {
    enable = true;
    extraPackages = with pkgs; [
      glow
      xleak
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      scan_timeout = 3000;
      aws = {
        disabled = true;
      };
      gcloud = {
        disabled = true;
      };
      azure = {
        disabled = true;
      };
    };
  };
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
local wezterm = require 'wezterm'

local act = wezterm.action
local config = wezterm.config_builder()

-- Windows
local is_windows = wezterm.target_triple:find("windows") ~= nil
local mod        = is_windows and 'ALT'    or 'SUPER'
local mod_shift  = is_windows and 'ALT|SHIFT'  or 'SUPER|SHIFT'
local mod_ctrl   = is_windows and 'ALT|CTRL'   or 'SUPER|CTRL'
if is_windows then
  config.wsl_domains = {
    {
      name = 'WSL:AlmaLinux-10',
      distribution = 'AlmaLinux-10',
      default_cwd = '~',
    },
  }
  config.default_domain = 'WSL:AlmaLinux-10'
end
-- Windows

use_fancy_tab_bar = true

config.window_background_opacity = 0.88
config.macos_window_background_blur = 25
-- config.font = wezterm.font 'Meslo'
config.font_size = 12

config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 20

config.color_scheme = 'OneHalfDark'

config.leader = { key = 'a', mods = mod, timeout_milliseconds = 1000 }
config.keys = {
  { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = 'SwapWithActiveKeepFocus' } },

  { key = 'v', mods = mod, action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's', mods = mod, action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  { key = 'h', mods = mod, action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = mod, action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = mod, action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = mod, action = act.ActivatePaneDirection 'Right' },



  { key = 'h', mods = mod_ctrl, action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j', mods = mod_ctrl, action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k', mods = mod_ctrl, action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l', mods = mod_ctrl, action = act.AdjustPaneSize { 'Right', 5 } },

  { key = 'c', mods = mod_shift, action = act.CloseCurrentPane { confirm = true } },

  { key = 't', mods = mod, action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 't', mods = mod_shift, action = act.SpawnCommandInNewTab { args = { 'cmd.exe' } } },
  { key = 't', mods = mod_shift, action = act.SpawnTab { DomainName = 'local' } },

  { key = 'w', mods = mod_shift, action = act.CloseCurrentTab { confirm = true } },

  { key = '1', mods = mod, action = act.ActivateTab(0) },
  { key = '2', mods = mod, action = act.ActivateTab(1) },
  { key = '3', mods = mod, action = act.ActivateTab(2) },
  { key = '4', mods = mod, action = act.ActivateTab(3) },
  { key = '5', mods = mod, action = act.ActivateTab(4) },
  { key = '6', mods = mod, action = act.ActivateTab(5) },
  { key = '7', mods = mod, action = act.ActivateTab(6) },
  { key = '8', mods = mod, action = act.ActivateTab(7) },
  { key = '9', mods = mod, action = act.ActivateTab(8) },

  { key = 'f', mods = mod, action = act.ToggleFullScreen },

  { key = 'r', mods = mod_shift, action = act.ReloadConfiguration },
}

config.key_tables = {
  leader = {
    { key = 's', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'v', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'q', action = act.CloseCurrentPane { confirm = true } },
  },
}

config.front_end = "Software"

return config
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ 
      ripgrep 
      nil
      nixd
      lua-language-server
      tailwindcss-language-server
      markdown-oxide
      ruff
    ];
    plugins = with pkgs.vimPlugins; [
      { plugin = onedark-vim; }
      { plugin = markdown-preview-nvim; }
      { plugin = nvim-treesitter.withAllGrammars; }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
	  local wk = require("which-key")
          wk.setup({})
	  wk.add({
            { "<leader>", group = "Leader" },
            { "<leader>m", group = "Markdown" },
            { "<leader>f", group = "File" },
            { "<leader>c", group = "Changelog" },
          })
        '';
      }

    ];
    initLua = ''
      vim.opt.termguicolors = true   
      vim.cmd("colorscheme onedark")
      vim.g.mapleader = " "
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.autochdir = true   

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
      vim.lsp.config('markdown_oxide', {
        cmd = { 'markdown-oxide' },
        filetypes = { 'markdown' },
        root_markers = { '.git', '.obsidian', '.moxide.toml' },
        capabilities = capabilities,
      })
      vim.lsp.enable('markdown_oxide')
      '';
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "Nico Gabo";
      email = "github.aviation441@silomails.com";
    };
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = [
      "https://github.com"
      "https://gist.github.com"
    ];
  };

  home.packages = [
    pkgs.ripgrep
    pkgs.deno
    pkgs.bun
    pkgs.uv
    pkgs.lazygit
    pkgs.git-lfs
    pkgsUnstable.opencode
    pkgs.fastfetch
    pkgs.glow
    pkgs.bat
    pkgs.pv

    pkgs.playwright
  ];
}
