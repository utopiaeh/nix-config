{
  pkgs,
  lib,
  username,
  config,
  ...
}:

let
  wallpaper = ../../assets/wallpapers/enchanted_forest_giant_by_billy_christian.jpg;
in

{
  home.stateVersion = "25.05";

  imports = [
    ../programs/ghostty.nix
    ../programs/git.nix
    ../programs/flashspace
    ../programs/macshot.nix
    ../programs/switch.nix
    ../programs/crisp.nix
    ../programs/wheelclick.nix
    ../programs/rust.nix
    ../programs/nix.nix
    ../programs/node.nix
    ../programs/claude.nix
    ../programs/idea.nix
  ];

  home.packages = with pkgs; [
    neovim
  ];

  # Stable path for macOS java_home and IDEA's JDK detection; JAVA_HOME's store path changes on every update
  home.file."Library/Java/JavaVirtualMachines/zulu-25.jdk".source =
    "${config.programs.java.package}/Library/Java/JavaVirtualMachines/zulu-25.jdk";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = "1";
    LSCOLORS = "gxfxcxdxbxgggdabagacad";
    SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  programs = {
    # also sets JAVA_HOME, which IDEA and Gradle use to find the JDK
    java = {
      enable = true;
      package = pkgs.openjdk25;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "github.com" = {
          HostName = "ssh.github.com";
          IdentityFile = "~/.ssh/id_ed25519";
          IdentitiesOnly = true;
        };

        "*" = {
          User = "${username}";
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
          StrictHostKeyChecking = "accept-new";
        };
      };
    };

    bat = {
      enable = true;
      config.theme = "Nord";
    };

    gpg.enable = true;

    lazygit.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--color=auto"
      ];
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [ "--no-mouse" ];
    };

    lf.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = pkgs.lib.importTOML ../../assets/starship/starship.toml;
    };

    bash.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        dev = "cd ~/Developer";

        cl = "clear";
        lg = "lazygit";
        tscl = "npx tsc";

        fix-sound = "sudo killall coreaudiod";

        tpl-node = "nix flake init -t 'github:utopiaeh/nix-config#node'";
        tpl-esp32 = "nix flake init -t 'github:utopiaeh/nix-config#esp32-rust'";
        tpl-api-rust = "nix flake init -t 'github:utopiaeh/nix-config#api-rust'";
      };

      initContent = ''
        # Keybindings
        [[ -n ''${key[Delete]} ]] && bindkey "''${key[Delete]}" delete-char
        [[ -n ''${key[Home]} ]] && bindkey "''${key[Home]}" beginning-of-line
        [[ -n ''${key[End]} ]] && bindkey "''${key[End]}" end-of-line
        [[ -n ''${key[Up]} ]] && bindkey "''${key[Up]}" up-line-or-search
        [[ -n ''${key[Down]} ]] && bindkey "''${key[Down]}" down-line-or-search

        # PATH (appended after Nix paths so Nix-managed tools take precedence)
        export PATH="$PATH:$HOME/go/bin"
        export PATH="$PATH:$HOME/.npm-global/bin"
        export PATH="$PATH:$HOME/.cargo/bin"

        # bat as cat
        cat() {
          bat --paging=always "$@"
        }

        # Run packages without installing via nix
        , () {
          nix run nixpkgs#comma -- "$@"
        }

        # ulimit can't live in .envrc: direnv runs it in a subshell
        _nix_config_ulimit() {
          local repo=''${NIX_CONFIG_DIR:-$HOME/nix-config}
          [[ ''${PWD:A}/ == ''${repo:A}/* ]] && ulimit -n 4096 2>/dev/null
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook chpwd _nix_config_ulimit
        _nix_config_ulimit
      '';
    };

    home-manager.enable = true;
    nix-index.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };

  home.activation.createDeveloperDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${config.home.homeDirectory}/Developer" ]; then
      mkdir -p "${config.home.homeDirectory}/Developer"
      chown ${username}:staff "${config.home.homeDirectory}/Developer"
    fi
  '';

  # ponytail: relies on a private, undocumented Apple framework path — may break across macOS versions, no fallback if it disappears.
  home.activation.applyKeyboardShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # already runs as the user; sudo here could prompt mid-rebuild
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
  '';

  home.activation.setDesktopWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      WALLPAPER_PATH=${wallpaper}
      CURRENT_PATH=$(/usr/bin/osascript -e 'tell application "System Events" to picture of desktop 1' 2>/dev/null || true)
      if [ -f "$WALLPAPER_PATH" ] && [ "$CURRENT_PATH" != "$WALLPAPER_PATH" ]; then
        /usr/bin/osascript <<EOF || echo "❯❯❯❯ ✗ wallpaper not set (allow Automation → System Events)" >&2
        tell application "System Events"
          set picture of every desktop to POSIX file "$WALLPAPER_PATH"
        end tell
    EOF
      fi
  '';
}
