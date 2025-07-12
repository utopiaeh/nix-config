{ config, inputs, pkgs, lib, unstablePkgs, username, ... }:

let
  cleanshotPackage = import ../apps/cleanshot { inherit pkgs; };
in

{
  home.stateVersion = "23.11";


  # list of programs
  # https://mipmip.github.io/home-manager-option-search

  imports = [
    ../apps/iterm2
    ../apps/git
    ../modules/iterm2
    ../apps/aerospace
  ];

  programs = {
    ssh = {
      enable = true;

      extraConfig = ''
        StrictHostKeyChecking no
      '';

      matchBlocks = {
        # Use SSH over HTTPS for GitHub and point to your SOPS-managed key
        "github.com" = {
          hostname = "ssh.github.com";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "*" = {
          user = "root";
        };
      };
    };


    bat = {
      enable = true;
      config.theme = "Nord";
    };
  };

  programs.gpg.enable = true;

  #  IMPORTANT: Use this if decide to use specific env per project
  #  Installs and enables nix-direnv allows you to write .envrc files like this:
  #  and it will automatically load a Nix shell environment (shell.nix or flake.nix) when entering that directory.
  #  use nix

  #  programs.direnv = {
  #    enable = true;
  #    nix-direnv.enable = true;
  #  };

  programs.eza = {
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

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [
      "--no-mouse"
    ];
  };


  programs.lf.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = pkgs.lib.importTOML ../../data/starship/starship.toml;
  };

  programs.bash.enable = true;



  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      cl = "clear";
      lg = "lazygit";
      dev = "cd ~/Developer";
    };
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  programs.zoxide.enable = true;


  home.activation.manageCleanshot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Cleaning up existing CleanShot X symlink if needed..."
    rm -f "$HOME/Applications/CleanShot X.app"

    if [ -d "${cleanshotPackage}/Applications/CleanShot X.app" ]; then
      echo "Re-linking CleanShot X.app"
      mkdir -p "$HOME/Applications"
      ln -s "${cleanshotPackage}/Applications/CleanShot X.app" "$HOME/Applications/CleanShot X.app"
    fi
  '';

}
