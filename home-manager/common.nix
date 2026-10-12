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
    extraConfig = builtins.readFile ../wezterm/wezterm.lua;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ 
      ripgrep 
      fd
      nil
      nixd
      rust-analyzer
      lua-language-server
      tailwindcss-language-server
      typescript-language-server
      markdown-oxide
      ruff
      git
      terraform-ls
    ];
    plugins = with pkgs.vimPlugins; [
      { plugin = onedark-vim; }
      { plugin = gitsigns-nvim; }
      { plugin = markdown-preview-nvim; }
      { plugin = nvim-treesitter.withAllGrammars; }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
          vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
          vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
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
    initLua = builtins.readFile ../nvim/init.lua;
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "nicolo";
      email = "git.noreply.ultimate450@passmail.com";
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
    pkgs.fd
    pkgs.nvimpager
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
