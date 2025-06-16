{ pkgs, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

#    home-manager.users.utopiaeh = {
#        home.packages = with pkgs; [
#          python3
#          poetry
#        ];
#    };

  homebrew = {
    casks = [
      "slack"
    ];
  };
}
