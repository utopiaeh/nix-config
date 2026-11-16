{ lib, ... }:

{

  home.activation.installTokenEater = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/TokenEater.app" ]; then
      echo "❯❯❯❯ · Installing TokenEater..."
      export HOMEBREW_NO_AUTO_UPDATE=1
      if ! { run /opt/homebrew/bin/brew trust athevon/tokeneater \
        && run /opt/homebrew/bin/brew install --cask athevon/tokeneater/tokeneater; }; then
        echo "❯❯❯❯ ✗ TokenEater install failed. Fix by hand:" >&2
        echo "  brew trust athevon/tokeneater && brew install --cask athevon/tokeneater/tokeneater" >&2
      fi
    fi
  '';

}
