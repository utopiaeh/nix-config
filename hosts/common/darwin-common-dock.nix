{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/Telegram.app"
      "/Applications/Discord.app"
      "/Applications/Spotify.app"
    ];
  };
}
