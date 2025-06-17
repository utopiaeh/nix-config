{ ... }:
{
  imports = [
    ./custom-dock.nix
  ];

  homebrew = {
    casks = [
      "discord"
      "qflipper"
    ];
  };
}
