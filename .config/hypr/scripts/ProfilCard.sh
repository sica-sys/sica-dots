#!/usr/bin/env bash
exec >/tmp/profilcard.log 2>&1
KITTY=$(command -v kitty || echo "$HOME/.local/kitty.app/bin/kitty")
CMD="$KITTY --class profil-card -o confirm_os_window_close=0 $HOME/.config/hypr/scripts/ProfilCardShow.sh"
if pgrep -f "class profil-card" >/dev/null; then pkill -f "class profil-card"; exit; fi
OUT=$(hyprctl dispatch "hl.dsp.exec_cmd(\"$CMD\", { float = true, size = {1000, 600} })")
echo "$OUT"
echo "$OUT" | grep -qi error && hyprctl dispatch "hl.dsp.exec_cmd(\"$CMD\", { float = true })"
