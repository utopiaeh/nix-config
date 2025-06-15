{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/Telegram.app"
      "/Applications/Slack.app"
      "/Applications/Discord.app"
    ];
  };
}
