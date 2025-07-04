{ config, inputs, pkgs, lib, unstablePkgs, username,  ... }:
{
  home.stateVersion = "23.11";


  # list of programs
  # https://mipmip.github.io/home-manager-option-search

    imports = [
#        ../../apps/darwin/raycast
    ../apps/iterm2
    ../modules/iterm2
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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

  programs.git = {
    enable = true;
    userEmail = "utopiaeh01@gmail.com";
    userName = "utopiaeh";
    diff-so-fancy.enable = true;
    ignores = [ "*~" ".DS_Store" ];
    lfs.enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull = {
        rebase = true;
      };
    };
  };


  programs.lf.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = pkgs.lib.importTOML ../starship/starship.toml;
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

}
