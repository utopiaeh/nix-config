{ inputs, outputs, stateVersion, ... }:
{
  mkDarwin = { hostname, username ? "utopiaeh", system ? "aarch64-darwin",}:
  let
    inherit (inputs.nixpkgs) lib;
    customConfPath = ./../hosts/darwin/${hostname};
    customConf = if builtins.pathExists (customConfPath) then (customConfPath + "/default.nix") else ./../hosts/common/darwin-common-dock.nix;
  in

    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit system inputs username; };
      #extraSpecialArgs = { inherit inputs; }
      modules = [
        # ../modules/darwin
        ../hosts/common/common-packages.nix
        ../hosts/common/darwin-common.nix
        customConf
        # Add nodejs overlay to fix build issues (https://github.com/NixOS/nixpkgs/issues/402079)
        {
            nixpkgs.overlays = [
              (import ../overlays/node.nix)
#                 (final: prev: {
#                   cleanshot = final.callPackage ./../apps/darwin/cleanshot { };
#                 })
            ];
        }
        inputs.home-manager.darwinModules.home-manager {
            networking.hostName = hostname;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.users.${username} = {
              imports = [ ./../home/profiles/${hostname}.nix ];
            };
        }
        inputs.nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = "${username}";
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
          };
        }
      ];
      # ] ++ lib.optionals (builtins.pathExists ./../hosts/darwin/${hostname}/default.nix) [
      #     (import ./../hosts/darwin/${hostname}/default.nix)
      #   ];

    };

}
