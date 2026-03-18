{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./base.nix ];

  # AWS Amplify CLI has no Nix package — installed via npm on first activation.
  # To remove: npm uninstall -g @aws-amplify/cli
  home.activation.installAmplifyCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! command -v amplify >/dev/null 2>&1; then
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      ${pkgs.nodejs}/bin/npm install -g @aws-amplify/cli
    fi
  '';
}
