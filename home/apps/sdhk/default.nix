{ config, lib, pkgs, ...}:

{

       services.skhd = {
        enable = true;
        skhdConfig = ''

        # flashspace shortcuts
        alt - [ : flashspace profile P
        alt - ] : flashspace profile W

        # app shortcuts
        alt - c : open -a "ChatGPT.app"

        alt - b : open -a "Zen.app"
        alt - i : open -a "Idea.app"

       '';
      };
  }
