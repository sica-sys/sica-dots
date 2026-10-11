#!/usr/bin/env bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
nvim_dir="$config_home/nvim"
state="$nvim_dir/lualine-theme"
theme_list="$nvim_dir/lualine-themes.txt"
rofi_theme="$config_home/hypr/rofi/config-edit.rasi"

[[ -r "$theme_list" && -r "$rofi_theme" ]] || {
  notify-send "Lualine" "Liste de thèmes ou thème Rofi introuvable."
  exit 1
}

current="auto"
[[ -r "$state" ]] && current="$(head -n1 "$state")"

mapfile -t themes < "$theme_list"
selected_row=0
for i in "${!themes[@]}"; do
  [[ "${themes[$i]}" == "$current" ]] && selected_row="$i"
done

"$config_home/hypr/scripts/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true

choice="$(
  printf '%s\n' "${themes[@]}" |
    rofi -dmenu -i -no-custom -p "Neovim · Lualine" \
      -config "$rofi_theme" \
      -mesg "Thème actuel : $current | Le choix sera mémorisé" \
      -selected-row "$selected_row"
)" || exit 0

[[ -n "$choice" ]] || exit 0
grep -Fxq -- "$choice" "$theme_list" || exit 1

mkdir -p "$nvim_dir"
printf '%s\n' "$choice" > "$state"
notify-send -u low "Neovim · Lualine" \
  "Thème choisi : $choice. Il sera appliqué au prochain démarrage de Neovim."
