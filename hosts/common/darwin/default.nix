{
  lib,
  system,
  username,
  pkgs,
  ...
}:
{

  imports = [
    ./settings/system.nix
    ./settings/userPreferences.nix
    ./settings/disableHotkeys.nix
    ./homebrew.nix
  ];

  system.stateVersion = 5;
  # Set primary user for system-wide activation
  system.primaryUser = "${username}";

  users.users.${username}.home = "/Users/${username}";

  time.timeZone = "Europe/Chisinau";

  # Standalone Nix (not nix-darwin) manages /etc/nix/nix.conf; GC is manual via `nix run .#cleanup`.
  nix.enable = false;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  environment.variables = { };

  environment.systemPackages = [ ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

}
