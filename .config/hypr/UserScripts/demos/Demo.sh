#!/usr/bin/env bash
# Lance une suite de clips de démo, enregistre (option), floute les passages marqués, puis remet la config comme avant.
# Usage : Demo.sh "Nom de la vidéo" clip1.sh [clip2.sh …]      Arrêt : Super+Alt+Échap
source "$HOME/.config/hypr/UserScripts/demos/lib.sh"
NOM="$1"; shift; CLIPS=("$@"); [ ${#CLIPS[@]} -gt 0 ] || exit 0
pkill -f 'UserScripts/VisiteGuidee.sh' 2>/dev/null
echo $$ > "$RUN/demo.pid"
VID="$HOME/Videos/Demos"; mkdir -p "$VID"
slug=$(echo "$NOM" | iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')
m=$(find "$VID" -name '[0-9]*-*.mp4' -printf '%f\n' 2>/dev/null | grep -oE '^[0-9]+' | sort -n | tail -1); N=$(( 10#${m:-0} + 1 ))   # sous-dossiers compris
# rangé dans tes dossiers : visite complète, sinon le groupe des clips (plusieurs groupes = Demo_selection)
declare -A DOSSIER=([1]="Kool-dots_natif" [2]="Demo_systme" [3]="Demo_ma-deco" [4]="Demo_musique" [5]="Demo_productivite" [6]="Demo_teaser")
grp=$(for c in "${CLIPS[@]}"; do b=$(basename "$c"); echo "${b%%-*}"; done | sort -u)
if [ "$NOM" = "Visite complète" ]; then SOUS="Demo _visite_complete"
elif [ "$(echo "$grp" | wc -l)" = 1 ] && [ -n "${DOSSIER[$grp]}" ]; then SOUS="${DOSSIER[$grp]}"
else SOUS="Demo_selection"; fi
mkdir -p "$VID/$SOUS"
OUT="$VID/$SOUS/$(printf '%02d' "$N")-${slug:-video}.mp4"                     # ex. 07-visite-complete.mp4
E="$H/wallpaper_effects"; R="$H/rofi"

# ---------------------------------------------------------------- état de la config (sauvegarde / remise)
sauve() {
  cp -f "$U/bureau.conf" "$RUN/bureau.conf" 2>/dev/null
  cp -f "$H/UserConfigs/user_animations.lua" "$RUN/anim.lua" 2>/dev/null
  FOND=$(readlink -f "$R/.current_wallpaper" 2>/dev/null); cp -f "$FOND" "$RUN/fond.img" 2>/dev/null
  for f in "$E"/.wallpaper_*; do [ -f "$f" ] && cp -f "$f" "$RUN/we$(basename "$f")"; done
  BLUR=$(hyprctl -j getoption decoration:blur:enabled | jq -r '.int // (if .bool then 1 else 0 end) // 1')
  PASSES=$(hyprctl -j getoption decoration:blur:passes | jq -r '.int // 3')
  WS0=$(hyprctl -j activeworkspace | jq -r '.id // 1')
  for f in "$HOME/.config/kitty/kitty-shader.conf" "$HOME/.config/kitty/kitty.conf" "${ZDOTDIR:-$HOME}/.zshrc"; do
    [ -f "$f" ] && cp -f "$f" "$RUN/sv-$(basename "$f")"; done
  WAYBAR0=$(readlink "$H/waybar/config")
  LAYOUTS=$(hyprctl -j workspaces | jq -r '.[] | "\(.id) \(.tiledLayout // .tiled_layout // "")"')
}
restaure() {
  ferme_kits; ferme; pkill -x wlogout 2>/dev/null; pkill -f DemoTitre.py 2>/dev/null; pkill -f 'class profil-card' 2>/dev/null
  if [ -n "$WAYBAR0" ] && [ "$(readlink "$H/waybar/config")" != "$WAYBAR0" ]; then
    ln -sf "$WAYBAR0" "$H/waybar/config"; "$S/Refresh.sh" >/dev/null 2>&1 &
  fi
  if ! cmp -s "$RUN/anim.lua" "$H/UserConfigs/user_animations.lua"; then
    cp -f "$RUN/anim.lua" "$H/UserConfigs/user_animations.lua"; hyprctl reload >/dev/null 2>&1; sleep 0.8
  fi
  hyprctl eval "hl.config({ decoration = { blur = { enabled = $([ "$BLUR" = 1 ] && echo true || echo false), passes = $PASSES } } })" >/dev/null 2>&1
  # fond d'écran (et images de Effets +) comme avant
  if [ -n "$FOND" ] && [ -f "$RUN/fond.img" ]; then
    case "$FOND" in "$E"/*) ;; *) [ -f "$FOND" ] && "$U/MemoFond.sh" "$FOND" ;; esac
    for f in "$RUN"/we.wallpaper_*; do [ -f "$f" ] && cp -f "$f" "$E/${f##*/we}"; done
    [ -f "$FOND" ] || cp -f "$RUN/fond.img" "$FOND"
    W=$(command -v awww || command -v swww)
    "$W" img "$FOND" --transition-type fade --transition-duration 1 >/dev/null 2>&1
    ln -sfn "$FOND" "$R/.current_wallpaper"
    for m in $(hyprctl monitors | awk '/^Monitor/{print $2}'); do ln -sfn "$FOND" "$R/.current_wallpaper_$m"; done
    "$S/WallustSwww.sh" "$FOND" >/dev/null 2>&1
  fi
  # terminal : shader, thème Kitty, prompt zsh
  local kr=0
  for f in "$HOME/.config/kitty/kitty-shader.conf" "$HOME/.config/kitty/kitty.conf" "${ZDOTDIR:-$HOME}/.zshrc"; do
    b="$RUN/sv-$(basename "$f")"; [ -f "$b" ] && ! cmp -s "$b" "$f" && { cp -f "$b" "$f"; kr=1; }
  done
  [ "$kr" = 1 ] && kitty_reload
  # réglages du bureau (couleur Cava, effet, bordure…)
  if ! cmp -s "$RUN/bureau.conf" "$U/bureau.conf"; then
    cp -f "$RUN/bureau.conf" "$U/bureau.conf"; setsid -f python3 "$U/ChorusTheme.py" >/dev/null 2>&1
    pkill -f 'UserScripts/CavaLiquide.py'; sleep 0.3; setsid -f python3 "$U/CavaLiquide.py" >/dev/null 2>&1
  fi
  # disposition de chaque espace
  while read -r id lay; do
    [ -n "$lay" ] || continue
    cur=$(hyprctl -j workspaces | jq -r ".[] | select(.id==$id) | (.tiledLayout // .tiled_layout // \"\")")
    [ -n "$cur" ] && [ "$cur" != "$lay" ] && { ws "$id"; "$S/ChangeLayout.sh" --quiet "$lay" >/dev/null 2>&1; }
  done <<< "$LAYOUTS"
  ws "$WS0"
}

fini=0
fin() {
  [ "$fini" = 1 ] && return; fini=1
  python3 "$D/DemoFlou.py" --fin >/dev/null 2>&1
  if [ -n "$REC" ]; then
    kill -INT "$REC" 2>/dev/null; for _ in $(seq 40); do kill -0 "$REC" 2>/dev/null || break; sleep 0.25; done
  fi
  rm -f "$RUN/rec" "$RUN/demo.pid"
  restaure
  if [ -n "$REC" ] && [ -s "$OUT" ]; then
    if python3 "$D/DemoFlou.py" --attacher "$OUT" "$REC"; then
      notify-send -a Démo "Vidéo enregistrée" "$(basename "$OUT") — floutage en cours (l'original va dans .originaux)…"
      python3 "$D/DemoFlou.py" --appliquer "$OUT"
    else
      notify-send -a Démo "Vidéo enregistrée" "$(basename "$OUT")"
    fi
  fi
}
trap fin EXIT; trap 'exit 0' INT TERM

# ---------------------------------------------------------------- c'est parti
sauve
titre "3" "" 0.9; sleep 1; titre "2" "" 0.9; sleep 1; titre "1" "" 0.9; sleep 1.1
if [ "$(opt rec oui)" = oui ] && command -v wf-recorder >/dev/null; then
  AUD=(); [ "$(opt son oui)" = oui ] && AUD=(--audio="$(pactl get-default-sink).monitor")
  wf-recorder "${AUD[@]}" -f "$OUT" >/dev/null 2>&1 & REC=$!
  sleep 0.8; echo "$REC $(date +%s.%N)" > "$RUN/rec"
fi
for c in "${CLIPS[@]}"; do
  [ -f "$c" ] || continue
  ( source "$D/lib.sh"; source "$c"; clip; flou_fin >/dev/null 2>&1; ferme; true )
done
if [ "$NOM" = "Visite complète" ]; then
  titre "Merci d'avoir regardé" "KooL Hyprland Dots · JaKooLit et LinuxBeginnings · déco : Sica" 4; sleep 4.3
fi
sleep 0.5
