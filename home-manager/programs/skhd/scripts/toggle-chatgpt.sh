#!/usr/bin/env bash

osascript <<EOF
tell application "System Events"
  set isRunning to (name of processes) contains "ChatGPT"
end tell

if isRunning then
  tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    if frontApp is "ChatGPT" then
      tell application "ChatGPT" to activate
      delay 0.1
      tell process "ChatGPT" to keystroke "h" using {command down}
    else
      tell application "ChatGPT" to activate
    end if
  end tell
else
  tell application "ChatGPT" to activate
end if
EOF
