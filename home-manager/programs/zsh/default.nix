{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = builtins.readFile ../../../data/mac-dot-zshrc;
  };
}
