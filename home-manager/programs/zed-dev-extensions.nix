{
  inputs,
  config,
  lib,
  ...
}:

let
  extensionsDir = "${config.home.homeDirectory}/.config/zed-dev-extensions";
in
{
  # Pinned source for Zed dev extensions. Nix only fetches/pins the source (updates via
  # `nix flake update`) — Zed still has to compile and register it itself, one-time, per
  # extension: in Zed, Cmd+Shift+P -> "zed: install dev extension" -> pick the path below.
  #
  # Copied (not symlinked) into a writable dir: Zed's installer writes Cargo build
  # artifacts into the extension folder even when a prebuilt extension.wasm is present,
  # which fails against a read-only nix store path.
  #
  # intellij-lsp-zed: IntelliJ's LSP server (Java/Kotlin) for Zed.
  #   Path: ~/.config/zed-dev-extensions/intellij-lsp-zed
  home.activation.installZedDevExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${extensionsDir}"
    rm -rf "${extensionsDir}/intellij-lsp-zed"
    cp -R "${inputs.intellij-lsp-zed}" "${extensionsDir}/intellij-lsp-zed"
    chmod -R u+w "${extensionsDir}/intellij-lsp-zed"
  '';
}
