{ ... }:
{
  imports = [
    ./custom-dock.nix
  ];



  homebrew = {
    casks = [
      "slack"
    ];
  };
}
