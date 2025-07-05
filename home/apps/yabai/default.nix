{ config, lib, pkgs, ...}:

{
      services.yabai = {
          enable = true;
          config = {
#            external_bar = "all:39:0";

            layout = "float";
#
            mouse_modifier = "alt";
            # set modifier + right-click drag to resize window (default: resize)
            mouse_action2 = "resize";
            # set modifier + left-click drag to resize window (default: move)
            mouse_action1 = "move";

#            # gaps
#            top_padding = 15;
#            bottom_padding = 15;
#            left_padding = 15;
#            right_padding = 15;
#            window_gap = 15;
          };
        extraConfig = ''

        '';
        };

       services.skhd = {
        enable = true;
        skhdConfig = ''

         # focus window
#          alt - h : yabai -m window --focus west
#          alt - l : yabai -m window --focus east


        # Resize focused window on the left
            ctrl + alt - left : \
              yabai -m window --toggle float; \
              mkdir -p ~/.cache; \
              idx=$(cat ~/.cache/yabai-left-index 2>/dev/null || echo 0); \
              next_idx=$(( (idx + 1) % 3 )); \
              echo $next_idx > ~/.cache/yabai-left-index; \
              screen_width=$(yabai -m query --displays --display | jq .frame.w); \
              screen_height=$(yabai -m query --displays --display | jq .frame.h); \
              xpos=0; \
              case $next_idx in \
                0) width=$(($screen_width / 2));; \
                1) width=$(($screen_width / 3));; \
                2) width=$((2 * $screen_width / 3));; \
              esac; \
              yabai -m window --move abs:$xpos:0; \
              yabai -m window --resize abs:$width:$screen_height

            # Resize focused window on the right
              ctrl + alt - right : \
                yabai -m window --toggle float; \
                mkdir -p ~/.cache; \
                idx=$(cat ~/.cache/yabai-right-index 2>/dev/null || echo 0); \
                next_idx=$(( (idx + 1) % 3 )); \
                echo $next_idx > ~/.cache/yabai-right-index; \
                screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                case $next_idx in \
                  0) width=$(($screen_width / 2)); xpos=$(($screen_width - $width));; \
                  1) width=$(($screen_width / 3)); xpos=$(($screen_width - $width));; \
                  2) width=$((2 * $screen_width / 3)); xpos=$(($screen_width - $width));; \
                esac; \
                yabai -m window --move abs:$xpos:0; \
                yabai -m window --resize abs:$width:$screen_height

            # Center focused window in screen
                ctrl + alt - c : \
                  yabai -m window --toggle float; \
                  screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                  screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                  window_width=$(yabai -m query --windows --window | jq .frame.w); \
                  window_height=$(yabai -m query --windows --window | jq .frame.h); \
                  xpos=$(( ($screen_width - $window_width) / 2 )); \
                  ypos=$(( ($screen_height - $window_height) / 2 - 20)); \
                  yabai -m window --move abs:$xpos:$ypos

            # Shortcut: Ctrl + Alt + ⌫ will now resize the focused window to 60% of the screen, capped at 1024×900, and center it.
                ctrl + alt - backspace : \
                  yabai -m window --toggle float; \
                  screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                  screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                  max_width=1024; max_height=900; \
                  target_width=$(( screen_width * 60 / 100 )); \
                  target_height=$(( screen_height * 60 / 100 )); \
                  width=$(( target_width > max_width ? max_width : target_width )); \
                  height=$(( target_height > max_height ? max_height : target_height )); \
                  xpos=$(( (screen_width - width) / 2 )); \
                  ypos=$(( (screen_height - height) / 2 - 20 )); \
                  yabai -m window --move abs:$xpos:$ypos; \
                  yabai -m window --resize abs:$width:$height

            # Ctrl + Alt + Return will now toggle the focused window into float mode
            #and maximize it to full screen size (based on current display dimensions).
                ctrl + alt - return : \
                  yabai -m window --toggle float; \
                  screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                  screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                  yabai -m window --move abs:0:0; \
                  yabai -m window --resize abs:$screen_width:$screen_height


            #Ctrl + Alt + Shift + → to move the focused window to the next display (preserve position and aspect ratio)
                ctrl + alt + shift - right : \
                  yabai -m window --toggle float; \
                  window_width=$(yabai -m query --windows --window | jq .frame.w); \
                  window_height=$(yabai -m query --windows --window | jq .frame.h); \
                  display_index=$(yabai -m query --displays --display | jq .index); \
                  next_display=$((display_index + 1)); \
                  yabai -m window --display $next_display; \
                  yabai -m display --focus $next_display; \
                  sleep 0.1; \
                  screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                  screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                  xpos=$(( (screen_width - window_width) / 2 )); \
                  ypos=$(( (screen_height - window_height) / 2 )); \
                  yabai -m window --move abs:$xpos:$ypos; \
                  yabai -m window --resize abs:$window_width:$window_height

            #Ctrl + Alt + Shift + ← to move it to the previous display (preserve position and aspect ratio)
                ctrl + alt + shift - left : \
                  yabai -m window --toggle float; \
                  window_width=$(yabai -m query --windows --window | jq .frame.w); \
                  window_height=$(yabai -m query --windows --window | jq .frame.h); \
                  display_index=$(yabai -m query --displays --display | jq .index); \
                  prev_display=$((display_index - 1)); \
                  yabai -m window --display $prev_display; \
                  yabai -m display --focus $prev_display; \
                  sleep 0.1; \
                  screen_width=$(yabai -m query --displays --display | jq .frame.w); \
                  screen_height=$(yabai -m query --displays --display | jq .frame.h); \
                  xpos=$(( (screen_width - window_width) / 2 )); \
                  ypos=$(( (screen_height - window_height) / 2 )); \
                  yabai -m window --move abs:$xpos:$ypos; \
                  yabai -m window --resize abs:$window_width:$window_height


                  # Resize windows (float-compatible, reliable absolute resize)
                  ctrl + alt - h : \
                    is_float=$(yabai -m query --windows --window | jq .floating); \
                    if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                    frame=$(yabai -m query --windows --window | jq .frame); \
                    width=$(echo "$frame" | jq .w); \
                    height=$(echo "$frame" | jq .h); \
                    width=$((width - 50)); \
                    yabai -m window --resize abs:$width:$height

                    ctrl + alt - l : \
                      is_float=$(yabai -m query --windows --window | jq .floating); \
                      if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                      frame=$(yabai -m query --windows --window | jq .frame); \
                      x=$(echo "$frame" | jq .x); \
                      y=$(echo "$frame" | jq .y); \
                      width=$(echo "$frame" | jq .w); \
                      height=$(echo "$frame" | jq .h); \
                      new_width=$((width - 50)); \
                      new_x=$((x + 50)); \
                      yabai -m window --move abs:$new_x:$y; \
                      yabai -m window --resize abs:$new_width:$height

#                  ctrl + alt - j : \
#                    is_float=$(yabai -m query --windows --window | jq .floating); \
#                    if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
#                    frame=$(yabai -m query --windows --window | jq .frame); \
#                    width=$(echo "$frame" | jq .w); \
#                    height=$(echo "$frame" | jq .h); \
#                    height=$((height + 50)); \
#                    yabai -m window --resize abs:$width:$height

#                  ctrl + alt - k : \
#                    is_float=$(yabai -m query --windows --window | jq .floating); \
#                    if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
#                    frame=$(yabai -m query --windows --window | jq .frame); \
#                    width=$(echo "$frame" | jq .w); \
#                    height=$(echo "$frame" | jq .h); \
#                    height=$((height - 50)); \
#                    yabai -m window --resize abs:$width:$height


                # Enlarge window width from the left (move left by 50px and grow width by 50px)
                ctrl + alt + shift - h : \
                  is_float=$(yabai -m query --windows --window | jq .floating); \
                  if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                  frame=$(yabai -m query --windows --window | jq .frame); \
                  x=$(echo "$frame" | jq .x); \
                  y=$(echo "$frame" | jq .y); \
                  width=$(echo "$frame" | jq .w); \
                  height=$(echo "$frame" | jq .h); \
                  new_x=$((x - 50)); \
                  if [ "$new_x" -lt 0 ]; then new_x=0; fi; \
                  new_width=$((width + 50)); \
                  yabai -m window --move abs:$new_x:$y; \
                  yabai -m window --resize abs:$new_width:$height

                # Enlarge window width from the right (just increase width by 50px)
                ctrl + alt + shift - l : \
                  is_float=$(yabai -m query --windows --window | jq .floating); \
                  if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                  frame=$(yabai -m query --windows --window | jq .frame); \
                  width=$(echo "$frame" | jq .w); \
                  height=$(echo "$frame" | jq .h); \
                  new_width=$((width + 50)); \
                  yabai -m window --resize abs:$new_width:$height

#                # Enlarge window height (grow height by 50px)
#                ctrl + alt + shift - j : \
#                  is_float=$(yabai -m query --windows --window | jq .floating); \
#                  if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
#                  frame=$(yabai -m query --windows --window | jq .frame); \
#                  width=$(echo "$frame" | jq .w); \
#                  height=$(echo "$frame" | jq .h); \
#                  new_height=$((height + 50)); \
#                  yabai -m window --resize abs:$width:$new_height

#                # Shrink window height (shrink height by 50px)
#                ctrl + alt + shift - k : \
#                  is_float=$(yabai -m query --windows --window | jq .floating); \
#                  if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
#                  frame=$(yabai -m query --windows --window | jq .frame); \
#                  width=$(echo "$frame" | jq .w); \
#                  height=$(echo "$frame" | jq .h); \
#                  new_height=$((height - 50)); \
#                  yabai -m window --resize abs:$width:$new_height


              # Increase height by 50px
              ctrl + alt - j : \
                is_float=$(yabai -m query --windows --window | jq .floating); \
                if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                frame=$(yabai -m query --windows --window | jq .frame); \
                width=$(echo "$frame" | jq .w); \
                height=$(echo "$frame" | jq .h); \
                new_height=$((height + 50)); \
                yabai -m window --resize abs:$width:$new_height

              # Move window down 50px
              ctrl + alt + shift - j : \
                frame=$(yabai -m query --windows --window | jq .frame); \
                x=$(echo "$frame" | jq .x); \
                y=$(echo "$frame" | jq .y); \
                yabai -m window --move abs:$x:$((y + 50))

              # Decrease height by 50px
              ctrl + alt - k : \
                is_float=$(yabai -m query --windows --window | jq .floating); \
                if [ "$is_float" = "0" ]; then yabai -m window --toggle float; fi; \
                frame=$(yabai -m query --windows --window | jq .frame); \
                width=$(echo "$frame" | jq .w); \
                height=$(echo "$frame" | jq .h); \
                new_height=$((height - 50)); \
                yabai -m window --resize abs:$width:$new_height

              # Move window up 50px
              ctrl + alt + shift - k : \
                frame=$(yabai -m query --windows --window | jq .frame); \
                x=$(echo "$frame" | jq .x); \
                y=$(echo "$frame" | jq .y); \
                new_y=$((y - 50)); \
                if [ "$new_y" -lt 0 ]; then new_y=0; fi; \
                yabai -m window --move abs:$x:$new_y
       '';
      };
  }
