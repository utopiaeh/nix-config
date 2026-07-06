{ ... }:

{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          email = "utopiaeh01@gmail.com";
          name = "utopiaeh";
        };
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
        core.editor = "nvim";

      };
      ignores = [
        "*~"
        ".DS_Store"
      ];
      lfs.enable = true;
      signing.format = null;
    };

    diff-so-fancy = {
      enableGitIntegration = true;
    };
  };

}
