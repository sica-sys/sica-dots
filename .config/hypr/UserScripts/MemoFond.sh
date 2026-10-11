#!/usr/bin/env bash
# Mémorise le fond choisi : retour au démarrage (WallpaperDaemon.sh) + image de base des effets (Super+Shift+W)
[ -f "$1" ] || exit 0
C="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"; L="$C/rofi"; E="$C/wallpaper_effects"; mkdir -p "$L" "$E"
ln -sfn "$1" "$L/.current_wallpaper"
cp -f "$1" "$E/.wallpaper_base"; cp -f "$1" "$E/.wallpaper_current"
for m in $(hyprctl monitors | awk '/^Monitor/{print $2}'); do
  ln -sfn "$1" "$L/.current_wallpaper_$m"
  cp -f "$1" "$E/.wallpaper_base_$m"; cp -f "$1" "$E/.wallpaper_current_$m"
done
sed -i "/^effet_actif=/d" "$HOME/.config/hypr/UserScripts/bureau.conf" 2>/dev/null
