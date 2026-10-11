#!/usr/bin/env bash
# Boîte à outils des clips de démo (chargée par Demo.sh). Chaque clip = un fichier dans clips/ avec :
#   # nom: …      # groupe: N-Nom du groupe      # flou: oui|non      puis une fonction clip() { … }
H="$HOME/.config/hypr"; U="$H/UserScripts"; S="$H/scripts"; D="$U/demos"
RUN="${XDG_RUNTIME_DIR:-/tmp}/demo"; mkdir -p "$RUN"
OPT="$HOME/.local/state/demos-options.conf"; mkdir -p "${OPT%/*}"   # hors de ~/.config/hypr (sinon rechargement auto)
opt()   { local v; v=$(grep -E "^$1=" "$OPT" 2>/dev/null | tail -1 | cut -d= -f2); echo "${v:-$2}"; }
titre() { [ "$(opt titres oui)" = oui ] || return 0      # titre "Grand titre" "sous-titre" [durée]
          setsid -f python3 "$D/DemoTitre.py" "$1" "${2:-}" "${3:-2.5}" >/dev/null 2>&1; }
ferme() { pkill -x rofi 2>/dev/null; sleep 0.3; }
lance() { setsid -f "$@" >/dev/null 2>&1; }
ws()    { hyprctl dispatch "hl.dsp.focus({ workspace = $1 })" >/dev/null 2>&1; sleep 0.4; }
# kitty de démo (classe demo-NOM, fermé tout seul à la fin) : kit NOM [commande…]
KB="$HOME/.local/kitty.app/bin/kitty"; [ -x "$KB" ] || KB=kitty          # ton Kitty 0.49 (shaders), pas l'ancien
kit()   { local c="$1"; shift; setsid -f "$KB" --class "demo-$c" "$@" >/dev/null 2>&1; sleep 0.7; }
ferme_kits() { pkill -f -- '--class demo-' 2>/dev/null; sleep 0.3; }
# ouvre un menu, le laisse visible N secondes puis le ferme : vu N commande…
vu()    { local n="$1"; shift; lance "$@"; sleep "$n"; ferme; }
fenetre_suivante() { "$S/LuaCycleWindow.sh" >/dev/null 2>&1 || true; }
couche() { hyprctl -j layers 2>/dev/null | grep -q "\"namespace\": *\"$1\""; }   # une couche (rofi, wlogout…) est visible ?
# flou automatique des infos perso (option « Flou automatique » du menu)
flou_debut() { [ "$(opt flou_auto oui)" = oui ] && python3 "$D/DemoFlou.py" --debut "${1:-plein}"; true; }   # plein ou "x y w h"
flou_fin()   { python3 "$D/DemoFlou.py" --fin >/dev/null 2>&1; true; }
flou_fenetre() { local g; sleep "${1:-1}"        # floute la fenêtre active (agenda, tâches, fiche…)
          g=$(hyprctl -j activewindow | jq -r '"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"' 2>/dev/null)
          local m; m=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.x) \(.y)"')
          set -- $g; local mx=${m% *} my=${m#* }
          [ -n "$4" ] && flou_debut "$(( $1 - mx - 6 )) $(( $2 - my - 6 )) $(( $3 + 12 )) $(( $4 + 12 ))" || flou_debut plein; }
cfg()   { touch "$U/bureau.conf"; sed -i "/^$1=/d" "$U/bureau.conf"; echo "$1=$2" >> "$U/bureau.conf"; }   # réglage bureau (remis à la fin)
cava_relance() { pkill -f 'UserScripts/CavaLiquide.py'; sleep 0.3; setsid -f python3 "$U/CavaLiquide.py" >/dev/null 2>&1; }
# change le fond (transition + couleurs Wallust) : fond image [transition]
fond()  { local W; W=$(command -v awww || command -v swww)
          "$W" img "$1" --transition-type "${2:-grow}" --transition-duration 1.2 --transition-fps 60 >/dev/null 2>&1
          setsid -f "$S/WallustSwww.sh" "$1" >/dev/null 2>&1; }
base_fond() { local m; m=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')
          local b="$H/wallpaper_effects/.wallpaper_base"; [ -f "${b}_$m" ] && b="${b}_$m"; echo "$b"; }
disposition() { "$S/ChangeLayout.sh" --quiet "$1" >/dev/null 2>&1; }
# --- terminal : shaders, thème Kitty, prompt Oh My Zsh (tout est remis comme avant à la fin par Demo.sh)
KSH="$HOME/.config/kitty/kitty-shader.conf"; KC="$HOME/.config/kitty/kitty.conf"; KT="$H/UserConfigs/kitty-themes"
kitty_reload() { for p in $(pgrep -x kitty) $(pgrep -f 'kitty.app/bin/kitty'); do kill -USR1 "$p" 2>/dev/null; done; }
shader()      { if [ -z "$1" ]; then echo "# aucun shader" > "$KSH"; else echo "custom_shaders $1" > "$KSH"; fi; kitty_reload; }
kitty_theme() { [ -f "$KT/$1.conf" ] || return 0
                sed -i -E '/^[[:space:]]*include[[:space:]]+.*kitty-themes\/.*\.conf[[:space:]]*$/d' "$KC"
                echo "include $KT/$1.conf" >> "$KC"; kitty_reload; }
kitty_themes_hasard() { ls "$KT" 2>/dev/null | sed -n 's/\.conf$//p' | grep -v -E '^(00-Default|01-Wallust)$' | shuf -n "${1:-2}"; }
zsh_theme()   { local z="${ZDOTDIR:-$HOME}/.zshrc"; [ -f "$z" ] && sed -i -E "s|^ZSH_THEME=.*|ZSH_THEME=\"$1\"|" "$z"; }
attendre()    { local n=0; while pgrep -f "$1" >/dev/null && [ $n -lt "${2:-30}" ]; do sleep 1; n=$((n+1)); done; }   # attendre la fin d'un programme
# --- souris : le curseur glisse jusqu'à un bouton de la Waybar (positions dans demos/positions.conf)
pos()      { grep -m1 "^$1=" "$D/positions.conf" 2>/dev/null | cut -d= -f2 | tr ',' ' '; }
curseur_xy() { hyprctl dispatch "hl.dsp.exec_raw('movecursor $1 $2')" >/dev/null 2>&1 \
               || hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null 2>&1; }
curseur()  { local p x y x0 y0 i; p=$(pos "$1"); [ -n "$p" ] || return 0; set -- $p; x=$1; y=$2
             read -r x0 y0 < <(hyprctl cursorpos 2>/dev/null | tr -d ',' ); x0=${x0:-960}; y0=${y0:-540}
             for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
               curseur_xy $(( x0 + (x - x0) * i / 14 )) $(( y0 + (y - y0) * i / 14 )); sleep 0.035; done; }
clic_sur() { local n="$1"; shift; curseur "$n"; sleep 0.6; lance "$@"; }        # « clic » : le curseur va au bouton puis ça s'ouvre
# --- Waybar : changer de disposition pour de vrai (remise comme avant à la fin)
waybar_style() { local c="$H/waybar/configs/$1"; [ -e "$c" ] || return 0
                 ln -sf "$c" "$H/waybar/config"; "$S/Refresh.sh" >/dev/null 2>&1 & sleep 2.5; }
