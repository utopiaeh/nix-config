{ ... }:
{
  imports = [
    ./custom-dock.nix
  ];

  home = {
    packages = with pkgs; [
      python3
      poetry
    ];
  };

  homebrew = {
    casks = [
      "slack"
    ];
  };
}
