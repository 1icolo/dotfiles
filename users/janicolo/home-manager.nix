{
  isWSL,
  isStandalone ? false,
  inputs,
  currentSystemName,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  notesDir = "$HOME/work";
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
  mkJsTsLanguage = name: {
    inherit name;
    auto-format = true;
    language-servers = [
      "typescript-language-server"
      "oxlint"
      "tailwindcss-ls"
    ];
    formatter = {
      command = lib.getExe pkgs.oxfmt;
      args = [
        "--stdin-filepath"
        "%{buffer_name}"
      ];
    };
  };
in {
  imports = lib.optionals (!isStandalone) [inputs.direnv-instant.homeModules.direnv-instant];

  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;

  home.sessionVariables = {
    NOTES_DIR = notesDir;
  };

  home.sessionPath = ["$HOME/.local/bin"];

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
      aws.disabled = true;
      gcloud.disabled = true;
      azure.disabled = true;
    };
  };

  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    options = ["--cmd cd"];
  };

  programs.zk = {
    enable = true;
    settings = {
      notebook.dir = "${notesDir}/notes";
      note = {
        filename = "{{format-date now '%Y-%m-%d'}}-{{slug title}}";
      };
      format.markdown.hashtags = true;
      format.markdown.frontmatter = {
        title = true;
        date = true;
      };
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "base16_transparent";
      editor = {
        default-yank-register = "+";
        line-number = "relative";
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      keys.normal = {
        space = {
          "B" = [":! git blame -L %{cursor_line},%{cursor_line} %{buffer_name}"];
        };
        "C-g" = [
          ":write-all"
          ":new"
          ":insert-output lazygit"
          ":buffer-close!"
          ":redraw"
          ":reload-all"
        ];
      };
    };
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = {};
      };
    };
    extraPackages = with pkgs;
      [
        git

        ripgrep
        fzf
        fd

        lazygit

        nixd
        alejandra
        rust-analyzer
        rustfmt
        lldb
        lua-language-server
        tailwindcss-language-server
        typescript-language-server
        vscode-js-debug
        vscode-langservers-extracted
        markdown-oxide
        ruff
        terraform-ls
        oxfmt
        oxlint
        stylua
        yaml-language-server
        bash-language-server
        shellcheck
        tinymist
        typstyle
        typstPackages.touying
        unstable.typstPackages.tableframe
        just-lsp
        zk # for note-taking
        # xclip # if you are on X11 instead of Wayland
      ]
      ++ lib.optionals isLinux [
        wl-clipboard
      ];
    languages = {
      language-server.tinymist = {
        command = lib.getExe pkgs.tinymist;
        config = {
          preview.background.enabled = true;
          preview.background.args = ["--data-plane-host=127.0.0.1:23635" "--invert-colors=never" "--open"];
        };
      };
      language-server.oxlint = {
        command = lib.getExe pkgs.oxlint;
        args = ["--lsp"];
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = ["nixd"];
          formatter.command = lib.getExe pkgs.alejandra;
          roots = [
            "flake.nix"
            "flake.lock"
          ];
        }
        {
          name = "typst";
          auto-format = true;
          formatter.command = lib.getExe pkgs.typstyle;
        }
        {
          name = "lua";
          auto-format = true;
          formatter.command = lib.getExe pkgs.stylua;
        }
        {
          name = "just";
          auto-format = true;
          formatter.command = lib.getExe unstable.just;
          formatter.args = ["--justfile" "-" "--fmt"];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = ["ruff"];
        }
        (mkJsTsLanguage "tsx")
        (mkJsTsLanguage "typescript")
        (mkJsTsLanguage "jsx")
        ((mkJsTsLanguage "javascript")
          // {
            debugger = {
              name = "js-debug-dap";
              transport = "tcp";
              command = lib.getExe pkgs.vscode-js-debug;
              port-arg = "{} 127.0.0.1";
              quirks.absolute-paths = true;
              templates = [
                {
                  name = "source";
                  request = "launch";
                  completion = [
                    {
                      name = "main";
                      completion = "filename";
                      default = "index.js";
                    }
                  ];
                  args = {
                    program = "{0}";
                    skipFiles = ["<node_internals>/**"];
                  };
                }
              ];
            };
          })
        {
          name = "html";
          language-servers = [
            "vscode-html-language-server"
            "tailwindcss-ls"
          ];
        }
        {
          name = "css";
          language-servers = [
            "vscode-css-language-server"
            "tailwindcss-ls"
          ];
        }
        {
          name = "markdown";
          language-servers = ["markdown-oxide"];
        }
        {
          name = "yaml";
          language-servers = ["yaml-language-server"];
        }
      ];
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    extraPackages = with pkgs;
      [
        ripgrep
        fd
        rust-analyzer
        lua-language-server
        tailwindcss-language-server
        typescript-language-server
        markdown-oxide
        ruff
        git
        terraform-ls
        oxfmt
        oxlint

        alejandra
        stylua

        yaml-language-server
        bash-language-server
        shellcheck

        fzf
      ]
      ++ lib.optionals isLinux [
        wl-clipboard
      ];
    plugins = with pkgs.vimPlugins; [
      {plugin = onedark-vim;}
      {plugin = gitsigns-nvim;}
      {plugin = markdown-preview-nvim;}
      {plugin = nvim-treesitter.withAllGrammars;}
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
          vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
          vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
          vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope recent files" })
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
            { "<leader>n", group = "Notes" },
            { "<leader>f", group = "File" },
            { "<leader>c", group = "Changelog" },
          })
        '';
      }
      {
        plugin = oil-nvim;
        type = "lua";
        config = ''
          local oil = require("oil")
          oil.setup({})
          oil.default_file_explorer = true;
          oil.watch_for_changes = false;
          oil.columns = {
            "icon",
            "permissions",
            "size",
            "mtime",
          };
        '';
      }
    ];
    initLua = builtins.readFile ./nvim/init.lua;
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

  programs.zsh = {
    enable = true;
    shellAliases = {};
    initContent = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      if [ -d '/opt/homebrew' ]; then
        eval "$(/opt/homebrew/bin/brew shellenv zsh)"
      fi
    '';
  };

  programs.zed-editor = {
    enable = true;
    userSettings = builtins.fromJSON (builtins.readFile ./zed/settings.json);
    userKeymaps = builtins.fromJSON (builtins.readFile ./zed/keymap.json);
    userTasks = builtins.fromJSON (builtins.readFile ./zed/tasks.json);
    mutableUserSettings = true;
    mutableUserKeymaps = true;
    mutableUserTasks = true;
    extraPackages = [pkgs.ripgrep];
  };

  xdg.configFile."nvim/lua/settings.lua".source = ./nvim/lua/settings.lua;
  xdg.configFile."nvim/lua/lsp.lua".source = ./nvim/lua/lsp.lua;
  xdg.configFile."nvim/lua/notes.lua".source = ./nvim/lua/notes.lua;

  xdg.configFile."ghostty/config".source = ./ghostty/config.ghostty;
  xdg.configFile."ghostty/shaders/cursor_lightning.glsl".source =
    ./ghostty/shaders/cursor_lightning.glsl;
  xdg.configFile."ghostty/shaders/sparks-from-fire.glsl".source =
    ./ghostty/shaders/sparks-from-fire.glsl;

  # xdg.configFile."nix/nix.conf".source = ./nix/nix.conf;

  home.packages = with pkgs;
    [
      ioskeley-mono.normal
      nix-diff
      awscli2
      bun
      colima
      python3
      fastfetch
      btop
      marp-cli
      nmap
      p7zip
      podman
      rustc
      cargo
      unrar
      dos2unix
      glow
      grok-cli
      sqlitebrowser
      ripgrep
      fd
      nvimpager
      bun
      uv
      lazygit
      git-lfs
      unstable.opencode
      fastfetch
      glow
      bat
      pv
      just
      tldr
      pandoc
      typst
      zk
    ]
    ++ lib.optionals isDarwin [
      # Darwin-specific
      ghostty-bin
      iina
      aerospace
    ]
    ++ lib.optionals isLinux [
      # Linux-specific
    ]
    ++ lib.optionals (isLinux && !isWSL) [
      # Linux non-WSL
      networkmanager-strongswan
      # Linux non-WSLscope
    ];
}
