{ inputs, ... }:
let
  inherit (inputs)
    nix-darwin
    home-manager
    nix-homebrew
    rust-overlay
    claude-code
    sops-nix
    ;
in
{
  mkDarwin =
    {
      hostname,
      username ? "utopiaeh",
      system ? "aarch64-darwin",
    }:
    let
      customConf = ./../hosts/darwin/${hostname}/default.nix;
      overlayDir = ../overlays;
      localOverlays =
        let
          files = builtins.attrNames (builtins.readDir overlayDir);
          nixFiles = builtins.filter (n: builtins.match ".*\\.nix" n != null) files;
        in
        map (n: import (overlayDir + "/${n}")) nixFiles;

    in
    nix-darwin.lib.darwinSystem {
      specialArgs = { inherit system inputs username; };
      modules = [
        sops-nix.darwinModules.sops
        ../hosts/common/common-packages.nix
        ../hosts/common/darwin
        customConf
        {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            claude-code.overlays.default
          ]
          ++ localOverlays;
        }
        home-manager.darwinModules.home-manager
        {
          networking.hostName = hostname;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs username; };
          home-manager.users.${username} = {
            imports = [ ./../home-manager/profiles/${hostname}.nix ];
          };
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = false;
            user = "${username}";
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "sw33tlie/homebrew-macshot" = homebrew-macshot;
            };
          };
        }
        # Keep homebrew.taps in sync with nix-homebrew.taps (avoids config drift)
        (
          { config, ... }:
          {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
          }
        )
      ];
    };
}
