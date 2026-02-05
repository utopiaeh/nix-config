{
  inputs = {
    # Base nixpkgs for macOS
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs = {
      follows = "nixpkgs-darwin";
    }; # do NOT give a url here

    # nix-darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # homebrew integration
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Rust overlay
    "rust-overlay".url = "github:oxalica/rust-overlay";
    "rust-overlay".inputs.nixpkgs.follows = "nixpkgs-darwin";

  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;

      stateVersion = "24.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };

    in
    {

      darwinConfigurations = {
        # personal
        mac-pro = libx.mkDarwin { hostname = "mac-pro"; };

        # work
        flow48 = libx.mkDarwin { hostname = "flow48"; };
      };
    };

}
