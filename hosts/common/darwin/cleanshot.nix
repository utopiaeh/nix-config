{
  lib,
  username,
  ...
}:

{
  # Automatically blocks CleanShot X license servers after activation.
  #
  # Workflow (one-time per machine):
  #   1. darwin-rebuild switch  →  CleanShot installs, no blocking
  #   2. Open CleanShot X and enter your license key
  #   3. Run: touch ~/.config/cleanshot-activated
  #   4. All future rebuilds auto-detect the marker and block the servers
  #
  # To re-allow (e.g. to reactivate): rm ~/.config/cleanshot-activated && rebuild

  system.activationScripts.postActivation.text = lib.mkAfter ''
    MARKER="/Users/${username}/.config/cleanshot-activated"
    BLOCK="# cleanshot-license-block"

    if [ -f "$MARKER" ]; then
      if ! grep -q "$BLOCK" /etc/hosts; then
        { echo ""; echo "$BLOCK"; echo "0.0.0.0 api.getcleanshot.com"; echo "0.0.0.0 updates.getcleanshot.com"; echo "0.0.0.0 keygen.cleanshot.com"; } >> /etc/hosts
        echo "❯❯❯❯ ✓ CleanShot license servers blocked"
      fi
    else
      LICENSE=$(cat /run/secrets/cleanshot_license 2>/dev/null || echo "not available")
      echo "❯❯❯❯ · CleanShot not yet activated — license servers accessible"
      echo "      License key: $LICENSE"
      echo "      After activating, run: cleanshot-activate && rebuild"
    fi
  '';
}
