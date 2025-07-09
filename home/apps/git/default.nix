{ config, pkgs, ... }:

{
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
}
