{ username, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Zen.app"

      "/Applications/Zed.app"
      "/Applications/IntelliJ IDEA.app"
      "/Users/${username}/Applications/Home Manager Apps/Ghostty.app"

      "/Applications/Telegram.app"

      "/Applications/Claude.app"

      "/Applications/Spotify.app"

      "/Applications/Notion.app"
    ];
  };
}
