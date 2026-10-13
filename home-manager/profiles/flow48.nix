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
    # activation PATH lacks ~/.npm-global/bin, so check the binary directly
    if [ ! -x "$HOME/.npm-global/bin/amplify" ]; then
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      ${pkgs.nodejs}/bin/npm install -g --fund=false @aws-amplify/cli@14.5.1 \
        || echo "warning: amplify install failed (offline?), retrying next switch"
    fi
  '';
}
