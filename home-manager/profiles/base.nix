{
  pkgs,
  lib,
  username,
  ...
}:

let
  cleanshotPackage = import ../programs/cleanshot { inherit pkgs; };
  wallpaper = ../../assets/wallpapers/enchanted_forest_giant_by_billy_christian.jpg;
in

{
  home.stateVersion = "23.11";

  imports = [
    ../modules/iterm2
    ../programs/iterm2
    ../programs/git
    ../programs/flashspace
    ../programs/rust
    ../programs/nix
    ../programs/node
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

      extraConfig = ''
        StrictHostKeyChecking no
      '';

      matchBlocks = {
        "github.com" = {
          hostname = "ssh.github.com";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "*" = {
          user = "${username}";
          addKeysToAgent = "yes";
          extraOptions.UseKeychain = "yes";
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
        cl = "clear";
        lg = "lazygit";
        tscl = "npx tsc";
        dev = "cd ~/Developer";
        fix-sound = "sudo killall coreaudiod";
        cleanshot-activate = "touch ~/.config/cleanshot-activated && echo 'Marker created. Run rebuild to apply blocking.'";
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

        # darwin-rebuild with optional host argument
        rebuild() {
          local host="''${1:-$(hostname)}"
          if [[ $# -gt 0 ]]; then
            shift
          fi
          sudo darwin-rebuild switch --flake ".#''${host}" "$@"
        }

        # Open project in IntelliJ IDEA
        idea() {
          open -a "IntelliJ IDEA" "$@" >/dev/null 2>&1
        }

        # Nix store garbage collection
        cleanup() {
          echo "❯❯❯❯ · Store size before cleanup: $(sudo du -sh /nix/store | cut -f1)"

          echo "❯❯❯❯ · Deleting generations older than 14 days..."
          sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 14d
          nix-env --delete-generations 14d

          echo "❯❯❯❯ · Running garbage collection..."
          sudo nix-collect-garbage -d
          nix-collect-garbage -d

          echo "❯❯❯❯ ✓ Done. Store size after: $(sudo du -sh /nix/store | cut -f1)"
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

  home.activation.linkCleanshotToApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${cleanshotPackage}/Applications/CleanShot X.app" ] && [ ! -e "/Applications/CleanShot X.app" ]; then
      ln -s "${cleanshotPackage}/Applications/CleanShot X.app" "/Applications/"
    fi
  '';

  home.activation.createDeveloperDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Users/${username}/Developer" ]; then
      mkdir -p "/Users/${username}/Developer"
      chown ${username}:staff "/Users/${username}/Developer"
    fi
  '';

  home.activation.applyKeyboardShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  home.activation.setDesktopWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      WALLPAPER_PATH=${wallpaper}
      if [ -f "$WALLPAPER_PATH" ]; then
        /usr/bin/osascript <<EOF
        tell application "System Events"
          set picture of every desktop to POSIX file "$WALLPAPER_PATH"
        end tell
    EOF
      fi
  '';
}
