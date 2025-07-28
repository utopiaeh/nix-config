{ config, lib, pkgs, ...}:

{

       services.skhd = {
        enable = true;
        skhdConfig = ''

        # flashspace shortcuts
        alt - q : flashspace profile P
        alt - e : flashspace profile W

       '';
      };
  }
