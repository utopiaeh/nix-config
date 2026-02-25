{ pkgs, ... }:

{
  # Claude Code
  environment.systemPackages = [
    pkgs.claude-code
  ];
}
