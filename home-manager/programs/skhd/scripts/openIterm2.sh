#!/bin/bash

if pgrep -x "iTerm2" > /dev/null; then
  # iTerm2 is already running → focus it
  osascript -e 'tell application "iTerm2" to activate'
else
  # iTerm2 is not running → launch it
  open -a "iTerm2"
fi
