nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.flow48.system"



sudo ./result/sw/bin/darwin-rebuild switch --flake ".#flow48"