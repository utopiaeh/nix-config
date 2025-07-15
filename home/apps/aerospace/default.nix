{ lib, pkgs, ... }: {
  config = lib.mkIf (pkgs.stdenv.isDarwin) {
    # Ensure aerospace package installed
    home.packages = with pkgs; [
      aerospace
    ];

    # Source aerospace config from the home-manager store
    home.file.".aerospace.toml".text = ''
            # Start AeroSpace at login
            start-at-login = true

            # Normalization settings
            enable-normalization-flatten-containers = true
            enable-normalization-opposite-orientation-for-nested-containers = true

            # Accordion layout settings
            accordion-padding = 30

            # Default root container settings…
            default-root-container-layout = 'tiles'
            default-root-container-orientation = 'auto'

            # Automatically unhide macOS hidden apps
            automatically-unhide-macos-hidden-apps = true

            # Key mapping preset
            [key-mapping]
            preset = 'qwerty'

            # Gaps settings
            [gaps]
            inner.horizontal = 0
            inner.vertical =   0
            outer.left =       3
            outer.bottom =     0
            outer.top =        0
            outer.right =      3

            # Main mode bindings
            [mode.main.binding]
            # Launch applications
#            alt-shift-b = 'exec-and-forget open -a "Zen"'
#            alt-shift-t = 'exec-and-forget open -a "Telegram"'
#            alt-shift-f = 'exec-and-forget open -a Finder'

            # Window management
            alt-q = "close"
            alt-slash = 'layout tiles horizontal vertical'
            alt-comma = 'layout accordion horizontal vertical'
            alt-m = 'fullscreen'

            # Focus movement
            alt-h = 'focus left'
            alt-j = 'focus down'
            alt-k = 'focus up'
            alt-l = 'focus right'

            # Window movement
            alt-shift-h = 'move left'
            alt-shift-j = 'move down'
            alt-shift-k = 'move up'
            alt-shift-l = 'move right'

            # Resize windows
            alt-shift-minus = 'resize smart -50'
            alt-shift-equal = 'resize smart +50'


            # Workspace navigation
            alt-tab = 'workspace-back-and-forth'
            alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

            # Enter service mode
            alt-shift-semicolon = 'mode service'

            alt-1 = 'workspace 1'
            alt-2 = 'workspace 2'
            alt-3 = 'workspace 3'
            alt-4 = 'workspace 4'
            alt-b = 'workspace B'
            alt-t = 'workspace T'

            alt-shift-1 = 'move-node-to-workspace 1'
            alt-shift-2 = 'move-node-to-workspace 2'
            alt-shift-3 = 'move-node-to-workspace 3'
            alt-shift-b = 'move-node-to-workspace B'
            alt-shift-t = 'move-node-to-workspace T'


            # Service mode bindings
            [mode.service.binding]
            # Reload config and exit service mode
            esc = ['reload-config', 'mode main¢¢¢']

            # Reset layout
            r = ['flatten-workspace-tree', 'mode main']

            # Toggle floating/tiling layout
            f = ['layout floating tiling', 'mode main']

            # Close all windows but current
            backspace = ['close-all-windows-but-current', 'mode main']

            # Join with adjacent windows
            alt-shift-h = ['join-with left', 'mode main']
            alt-shift-j = ['join-with down', 'mode main']
            alt-shift-k = ['join-with up', 'mode main']
            alt-shift-l = ['join-with right', 'mode main']


         # IntelliJ IDEA and Zen browser → workspace 2
         [[on-window-detected]]
         if.app-id = 'com.jetbrains.intellij'
         run = ['move-node-to-workspace 2']

         # Zen Browser → workspace B
         [[on-window-detected]]
         if.app-id = 'app.zen-browser.zen'  # confirm this with `aerospace list-apps`
         run = ['move-node-to-workspace B']

         # iTerm → workspace T
         [[on-window-detected]]
         if.app-id = 'com.googlecode.iterm2'
         run = ['move-node-to-workspace T']

        #  workspace 4
         [[on-window-detected]]
         if.app-id = 'com.openai.chat'
         run = ['move-node-to-workspace 4']

         [[on-window-detected]]
          if.app-id = 'ru.keepcoder.Telegram'
          run = ['move-node-to-workspace 4']

        [[on-window-detected]]
        if.app-id = 'ru.keepcoder.Telegram'
        run = ['move-node-to-workspace 4']

        [[on-window-detected]]
        if.app-id = 'com.tinyspeck.slackmacgap'
        run = ['move-node-to-workspace 4']

         [[on-window-detected]]
         check-further-callbacks = true
         run = ['layout floating']
    '';
  };
}
