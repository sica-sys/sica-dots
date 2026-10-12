#!/usr/bin/env bash
W="$HOME/.config/hypr/waybar"
CUR=$(readlink "$W/config")
if echo "$CUR" | grep -q Cyber; then
  ln -sf "$W/configs/TOP-Default-Laptop-glass.bak" "$W/config"; notify-send Waybar "Principale"
else
  ln -sf "$W/configs/[TOP] Cyber" "$W/config"; notify-send Waybar "Cyber"
fi
pkill waybar; sleep 0.4; waybar -c "$W/config" -s "$W/style.css" & disown
