#!/usr/bin/env bash
cfg="$HOME/.config/nvim"
rasi="$HOME/.config/hypr/rofi/config-kitty-theme.rasi"
menu() { local o=(-dmenu -i -p "$1"); [ -f "$rasi" ] && o+=(-config "$rasi"); rofi "${o[@]}"; }
splash_list() {
  { nvim --headless "+lua io.stdout:write(table.concat(require('milli').list(), '\n'))" +qa 2>/dev/null
    ls "$HOME/.local/share/nvim/milli/splashes" 2>/dev/null | sed 's/\..*$//'
    printf '%s\n' fire blackhole finger dancerramp skeleton vibecat
  } | grep -E '^[A-Za-z0-9_-]+$' | sort -u
}
milli=$(cat "$cfg/dashboard-milli" 2>/dev/null || echo off)
splash=$(cat "$cfg/dashboard-splash" 2>/dev/null || echo random)
n=$(splash_list | wc -l)
choice=$(printf '%s\n' snacks-default snacks-compact dashnvim-hyper dashnvim-doom \
  alpha-dashboard alpha-startify alpha-theta mini-starter \
  "milli (logo anime) : $milli -> basculer" "milli splash : $splash -> choisir ($n splashes + random)" | menu "Choose Neovim dashboard")
[ -z "$choice" ] && exit 0
case "$choice" in
  "milli splash"*)
    pick=$( { echo random; splash_list; } | menu "Choose milli splash (random ou 1 des $n)")
    [ -z "$pick" ] && exit 0
    echo "$pick" > "$cfg/dashboard-splash"
    notify-send "Neovim" "Splash milli : $pick (au prochain lancement)"
    [ "$pick" != random ] && ( kitty --class milli-preview -e nvim "+MilliPreview $pick" >/dev/null 2>&1 & ) ;;
  milli*)
    [ "$milli" = on ] && new=off || new=on
    echo "$new" > "$cfg/dashboard-milli"
    notify-send "Neovim" "milli : $new (au prochain lancement)" ;;
  *)
    echo "$choice" > "$cfg/dashboard-choice"
    notify-send "Neovim" "Dashboard : $choice (au prochain lancement)" ;;
esac
