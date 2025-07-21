{ config, inputs, pkgs, lib, unstablePkgs, specialArgs, ... }:
{

  imports = [
    ./base.nix
  ];

   home.packages = with pkgs; [
      poetry
      python3
    ];


  #To remove package
  #npm uninstall -g @aws-amplify/cli
  #rm -rf ~/.npm-global/lib/node_modules/@aws-amplify
  #rm ~/.npm-global/bin/amplify
  home.activation.installAmplifyCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="$HOME/.npm-global/bin:$PATH"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      if ! command -v amplify >/dev/null 2>&1; then
        echo "📦Installing Amplify CLI globally via npm..."
        ${pkgs.nodejs}/bin/npm install -g @aws-amplify/cli
      else
        echo "📦 Amplify CLI already installed, skipping..."
      fi
  '';
}
