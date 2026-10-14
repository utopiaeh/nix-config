{ config, lib, ... }:

let
  layout = ../../assets/idea/window.layouts.xml;
  jetbrains = "${config.home.homeDirectory}/Library/Application Support/JetBrains";
in
{
  # IDEA rewrites window.layouts.xml on quit, so quit it before rebuilding or the layout is lost
  home.activation.installIdeaLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir=$(find "${jetbrains}" -maxdepth 1 -type d -name 'IntelliJIdea*' 2>/dev/null | sort -V | tail -n1 || true)
    if [ -z "$dir" ]; then
      echo "❯❯❯❯ · IntelliJ IDEA not launched yet, skipping layout (rebuild after first launch)"
    elif ! cmp -s ${layout} "$dir/options/window.layouts.xml"; then
      echo "❯❯❯❯ · Installing IntelliJ IDEA layout into $dir"
      mkdir -p "$dir/options"
      install -m 644 ${layout} "$dir/options/window.layouts.xml"
    fi
  '';
}
