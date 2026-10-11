#!/usr/bin/env bash
# Effets + : effets de fond d'écran en plus de ceux de KooLDots (Super+Shift+W).
# Chaque effet s'active / se désactive dans « Gérer les Effets + ». Le menu KooLDots d'origine reste accessible.
# Usage : EffetsPlus.sh                      → menu
#         EffetsPlus.sh --appliquer teinte   → réapplique la teinte Cava (après un changement de couleur)
U="$HOME/.config/hypr/UserScripts"; CONF="$U/bureau.conf"; S="$HOME/.config/hypr/scripts"
E="$HOME/.config/hypr/wallpaper_effects"; R="$HOME/.config/hypr/rofi"; TMP="${XDG_RUNTIME_DIR:-/tmp}/effets-plus"
rasi="$R/config-wallpaper-effect.rasi"
menu() { local o=(-dmenu -i -p "$1"); [ -f "$rasi" ] && o+=(-config "$rasi"); rofi "${o[@]}"; }
get() { local v; v=$(grep -E "^$1=" "$CONF" 2>/dev/null | tail -1 | cut -d= -f2-); echo "${v:-$2}"; }
set_() { touch "$CONF"; sed -i "/^$1=/d" "$CONF"; echo "$1=$2" >> "$CONF"; }

IDS=(pixel teinte theme)
declare -A NOM=([pixel]="Pixel art" [teinte]="Teinte Cava" [theme]="Thème de couleurs")
declare -A THEMES=(
  [rose-pine]="#191724 #1f1d2e #26233a #6e6a86 #908caa #e0def4 #eb6f92 #f6c177 #ebbcba #31748f #9ccfd8 #c4a7e7"
  [catppuccin]="#11111b #181825 #1e1e2e #313244 #45475a #585b70 #cdd6f4 #f5e0dc #f5c2e7 #cba6f7 #f38ba8 #fab387 #f9e2af #a6e3a1 #94e2d5 #89b4fa #b4befe"
  [tokyo-night]="#16161e #1a1b26 #24283b #414868 #565f89 #a9b1d6 #c0caf5 #7aa2f7 #7dcfff #bb9af7 #9ece6a #e0af68 #f7768e #ff9e64"
  [dracula]="#21222c #282a36 #44475a #6272a4 #f8f8f2 #8be9fd #50fa7b #ffb86c #ff79c6 #bd93f9 #ff5555 #f1fa8c"
  [nord]="#2e3440 #3b4252 #434c5e #4c566a #d8dee9 #eceff4 #8fbcbb #88c0d0 #81a1c1 #5e81ac #bf616a #d08770 #ebcb8b #a3be8c #b48ead"
  [gruvbox]="#1d2021 #282828 #3c3836 #504945 #665c54 #ebdbb2 #fbf1c7 #cc241d #98971a #d79921 #458588 #b16286 #689d6a #fe8019"
)
actif() { case ",$(get effets_off ''),": in *",$1,"*) return 1 ;; esac; return 0; }

mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null)
base="$E/.wallpaper_base"; [ -n "$mon" ] && [ -f "$E/.wallpaper_base_$mon" ] && base="$E/.wallpaper_base_$mon"
[ -f "$base" ] || base=$(awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1)
out="$E/.wallpaper_modified"; mkdir -p "$E" "$R" "$TMP"

poser() {   # $1 = image à mettre en fond, $2 = nom de l'effet (ou vide)
  local img="$1" W; W=$(command -v awww || command -v swww)
  for p in swaybg mpvpaper; do pkill -x "$p" 2>/dev/null; done
  "$W" img ${mon:+-o "$mon"} "$img" --transition-type wipe --transition-fps 60 --transition-duration 1.5 >/dev/null 2>&1
  ln -sfn "$img" "$R/.current_wallpaper"; cp -f "$img" "$E/.wallpaper_current"
  if [ -n "$mon" ]; then ln -sfn "$img" "$R/.current_wallpaper_$mon"; cp -f "$img" "$E/.wallpaper_current_$mon"; fi
  [ -x "$S/WallustSwww.sh" ] && "$S/WallustSwww.sh" "$img" >/dev/null 2>&1 &
  [ -n "$2" ] && notify-send -u low "Effets +" "$2 appliqué"
}

appliquer() {   # $1 = id de l'effet, $2 = option (thème)
  [ -f "$base" ] || { notify-send -u critical "Effets +" "Image de base introuvable — choisis un fond avec Super+W"; return 1; }
  notify-send -u low "Effets +" "${NOM[$1]} en cours…"
  case "$1" in
    pixel)
      magick "$base" -resize 12.5% +dither -colors 24 -filter point -resize 800% "$out" ;;
    teinte)
      local cs; cs=$(python3 -c "import sys; sys.path.insert(0, '$U'); from CavaLiquide import conf, palette, rgbhex; print(' '.join(rgbhex(c) for c in palette(conf())))")
      local args=(xc:'#0f0c18'); for c in $cs; do args+=("xc:$c"); done
      magick "${args[@]}" +append -filter triangle -resize '256x1!' "$TMP/clut.png" &&
      magick "$base" -modulate 100,0 -auto-level "$TMP/clut.png" -clut "$out" ;;
    theme)
      local t="$2" args=()
      for c in ${THEMES[$t]}; do args+=("xc:$c"); done
      magick "${args[@]}" +append "$TMP/pal.png" &&
      magick "$base" -dither FloydSteinberg -remap "$TMP/pal.png" "$out" ;;
  esac || { notify-send -u critical "Effets +" "${NOM[$1]} n'a pas pu être appliqué"; return 1; }
  set_ effet_actif "$1"; [ -n "$2" ] && set_ effet_theme "$2"
  poser "$out" "${NOM[$1]}${2:+ ($2)}"
}

if [ "$1" = "--appliquer" ]; then
  [ "$(get effet_actif none)" = "$2" ] && appliquer "$2" "$(get effet_theme rose-pine)"
  exit 0
fi

pkill -x rofi && exit 0
lignes=("󰸉  Effets KooLDots…")
for id in "${IDS[@]}"; do actif "$id" && lignes+=("✦  ${NOM[$id]}"); done
lignes+=("󰋩  Retirer l'effet (fond d'origine)" "󰒓  Gérer les Effets +")
choix=$(printf '%s\n' "${lignes[@]}" | menu "Effets")
case "$choix" in
  *KooLDots*) exec "$S/WallpaperEffects.sh" ;;
  *"Pixel art"*) appliquer pixel ;;
  *"Teinte Cava"*) appliquer teinte ;;
  *"Thème de couleurs"*)
    t=$(printf '%s\n' rose-pine catppuccin tokyo-night dracula nord gruvbox | menu "Thème de couleurs")
    [ -n "$t" ] && appliquer theme "$t" ;;
  *Retirer*) set_ effet_actif none; poser "$base" "Fond d'origine" ;;
  *Gérer*)
    while :; do
      g=$( { for id in "${IDS[@]}"; do actif "$id" && e=on || e=off; printf '%-20s : %s\n' "${NOM[$id]}" "$e"; done; } | menu "Activer / désactiver")
      [ -z "$g" ] && break
      for id in "${IDS[@]}"; do
        if [[ "$g" == "${NOM[$id]}"* ]]; then
          l=$(get effets_off ''); if actif "$id"; then l="$l,$id"; else l=$(echo ",$l," | sed "s/,$id,/,/g"); fi
          set_ effets_off "$(echo "$l" | sed 's/^,*//; s/,*$//; s/,,*/,/g')"
        fi
      done
    done ;;
esac
