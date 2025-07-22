{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/IntelliJ IDEA.app"
      "/Applications/Zed.app"

      "/Applications/Telegram.app"
      "/Applications/Slack.app"
      "/Applications/ChatGPT.app"

      "/Applications/Spotify.app"
    ];
  };
}
