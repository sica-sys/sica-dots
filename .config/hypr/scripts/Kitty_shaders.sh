#!/usr/bin/env bash
# Sélecteur de shaders Kitty (0.49+) : Entrée = aperçu, Ctrl+S = garder, Échap = annuler
state="$HOME/.config/kitty/kitty-shader.conf"
rofi_theme="$HOME/.config/hypr/rofi/config-kitty-shader.rasi"
kitty_bin="$(readlink -f "$HOME/.local/kitty.app/bin/kitty")"

labels=(
  "Désactiver"
  "── CURSEUR ──"
  "Traînée par défaut"
  "Blaze"
  "Lightning"
  "── FONDS ANIMÉS ──"
  "Inside the Matrix"
  "Feux d'artifice"
  "── EFFETS ──"
  "Pond Ripple (clic)"
  "Spotlight"
  "Focus Highlight"
  "Dim Inactive (fichier manquant ?)"
  "Tab Change"
  "── RÉTRO ──"
  "CRT bleu"
  "CRT (sans pipeline, à tester)"
  "TFT (sans pipeline, à tester)"
  "Water (sans pipeline, à tester)"
  "Underwater (sans pipeline, à tester)"
  "Bloom (sans pipeline, à tester)"
  "── COMBINAISONS ──"
  "Feux d'artifice + Lightning"
  "Spotlight + Focus Highlight"
  "CRT bleu + Spotlight"
)
values=(
  ""
  "#"
  "cursor-trail-default"
  "cursor-trail-blaze"
  "cursor-trail-lightning"
  "#"
  "inside-the-matrix"
  "fireworks"
  "#"
  "pond-ripple"
  "spotlight"
  "focus-highlight"
  "dim-inactive-windows"
  "tab-change"
  "#"
  "crt-blue"
  "crt"
  "tft"
  "water"
  "underwater"
  "bloom"
  "#"
  "fireworks cursor-trail-lightning"
  "spotlight focus-highlight"
  "crt-blue spotlight"
)

write_state() { if [ -z "$1" ]; then echo "# aucun shader" > "$state"; else echo "custom_shaders $1" > "$state"; fi; }
reload_kitty() {
  for p in $(pgrep -x kitty); do
    [ "$(readlink -f /proc/$p/exe 2>/dev/null)" = "$kitty_bin" ] && kill -SIGUSR1 "$p"
  done
  return 0
}

[ -r "$rofi_theme" ] || { notify-send "Kitty shaders" "Thème rofi introuvable : $rofi_theme"; exit 1; }
original="$(cat "$state" 2>/dev/null)"; [ -n "$original" ] || original="# aucun shader"
"$HOME/.config/hypr/scripts/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true

sel=0
while true; do
  choice=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -no-custom -format i \
    -p "Kitty Shader" -mesg "Entrée : aperçu | Ctrl+S : garder et quitter | Échap : annuler" \
    -config "$rofi_theme" -selected-row "$sel" -kb-custom-1 "Control+s,Control+S,Alt+1")
  rc=$?
  if [ "$rc" -ne 0 ] && { [ "$rc" -lt 10 ] || [ "$rc" -gt 28 ]; }; then
    echo "$original" > "$state"; reload_kitty; break
  fi
  [ -n "$choice" ] || break
  v="${values[$choice]}"
  if [ "$v" = "#" ]; then sel=$choice; continue; fi
  write_state "$v"; reload_kitty; sel=$choice
  if [ "$rc" -ge 10 ]; then notify-send "Kitty shaders" "Appliqué : ${labels[$choice]}"; break; fi
done
