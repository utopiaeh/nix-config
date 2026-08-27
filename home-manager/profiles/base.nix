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
    ../modules/iterm2
    ../programs/iterm2
    ../programs/git.nix
    ../programs/flashspace
    ../programs/rust.nix
    ../programs/nix.nix
    ../programs/node.nix
  ];

  home.packages = with pkgs; [
    neovim
    claude-code
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = "1";
    LSCOLORS = "gxfxcxdxbxgggdabagacad";
    SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  programs = {
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
          StrictHostKeyChecking = "no";
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
    /usr/bin/sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  home.activation.setDesktopWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      WALLPAPER_PATH=${wallpaper}
      CURRENT_PATH=$(/usr/bin/osascript -e 'tell application "System Events" to picture of desktop 1' 2>/dev/null || true)
      if [ -f "$WALLPAPER_PATH" ] && [ "$CURRENT_PATH" != "$WALLPAPER_PATH" ]; then
        /usr/bin/osascript <<EOF
        tell application "System Events"
          set picture of every desktop to POSIX file "$WALLPAPER_PATH"
        end tell
    EOF
      fi
  '';
}
