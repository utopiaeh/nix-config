# Example iTerm2 configuration based on the provided plist
{ config, pkgs, ... }:

{
  programs.iterm2 = {
    enable = true;
    copyApplications = false;

    settings.appearance.theme = "minimal";

    profiles = [{
      name = "nix managed";
      default = true;

    transparency = {
        enable = true;
        value = 0.066155133928571433;
    };
    blur = {
       enable = true;
       value = 2.5972795758928573;
    };

      window = {
        columns = 120;
        rows = 22;
      };
      font = {
        normal = "MesloLGLNF-Regular 16";
        nonAscii = "MesloLGL Nerd Font 16";
        useNonAsciiFont = false;
        antiAlias = true;
        brightenBold = true;
      };

      cursor.type = "box";

      terminal = {
        mouseReporting = true;
        showBellIcon = true;
        visualBell = true;
        closeSessionsOnEnd = true;
        warnShortLivedSessions = false;
      };

      colors = {
        background = "#15191e";
        foreground = "#dbdbdb";

        black = {
          normal = "#000000";
          bright = "#606060";
        };

        red = {
          normal = "#ed7482";
          bright = "#ef766d";
        };

        green = {
          normal = "#57bf37";
          bright = "#8cf67a";
        };

        yellow = {
          normal = "#f2a96f";
          bright = "#fefb7e";
        };

        blue = {
          normal = "#7cb4f7";
          bright = "#6a71f6";
        };

        magenta = {
          normal = "#b93ec1";
          bright = "#f07ef8";
        };

        cyan = {
          normal = "#9dcbfa";
          bright = "#55ffff";
        };

        white = {
          normal = "#c7c7c7";
          bright = "#feffff";
        };
      };
    }];
  };
}
