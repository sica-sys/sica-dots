#!/usr/bin/env bash
# Menu du bureau : platine, fonds d'écran, Cava (widget Waybar + goutte liquide + barre du bas)
U="$HOME/.config/hypr/UserScripts"; CONF="$U/bureau.conf"
rasi="$HOME/.config/hypr/rofi/config-kitty-theme.rasi"
menu() { local o=(-dmenu -i -p "$1"); [ -f "$rasi" ] && o+=(-config "$rasi"); rofi "${o[@]}"; }
get() { local v; v=$(grep -E "^$1=" "$CONF" 2>/dev/null | tail -1 | cut -d= -f2-); echo "${v:-$2}"; }
set_() { touch "$CONF"; sed -i "/^$1=/d" "$CONF"; echo "$1=$2" >> "$CONF"; }
restart_platine() {
  pkill -f 'UserScripts/Platine.py' 2>/dev/null; sleep 0.3
  [ "$(get platine on)" = on ] && setsid -f python3 "$U/Platine.py" >/dev/null 2>&1
}
restart_cava() {
  pkill -f 'UserScripts/CavaLiquide.py' 2>/dev/null; sleep 0.4
  { [ "$(get cava_haut off)" = on ] || [ "$(get cava_bas off)" = on ]; } && setsid -f python3 "$U/CavaLiquide.py" >/dev/null 2>&1
}
pipette() { sleep 0.3; hyprpicker -f hex 2>/dev/null | grep -oE '#[0-9a-fA-F]{6}' | tail -1; }
favori() {   # ajoute une couleur à « Mes couleurs » (8 max, la plus récente en premier)
  local f; f=$(get cava_favoris ""); f=$(printf '%s\n' "$1" ${f//,/ } | awk '!v[tolower($0)]++' | head -8 | paste -sd,)
  set_ cava_favoris "$f"; }
pkill -x rofi && exit 0

choice=$(printf '%s\n' \
  "󰸉  Changer le fond d'écran (carrousel)" \
  "󰀻  Ancien sélecteur JaKooLit" \
  "󰎆  Platine : $(get platine on)" \
  "󰋩  Style de la platine : $(get platine_style classique)" \
  "󰁌  Position de la platine : $(get platine_pos bas-droite)" \
  "󰩨  Taille de la platine : $(get platine_taille moyenne)" \
  "󰺢  Style Cava (haut + bas) : $(get cava_style blocs)" \
  "󰏘  Couleur Cava (haut + bas) : $(get cava_couleur wallust)" \
  "󰽰  Cava liquide (haut) : $(get cava_haut off)" \
  "󰕾  Barre Cava (bas) : $(get cava_bas off)" \
  "󰘖  Hauteur de la barre du bas : $(get cava_bas_hauteur moyenne)" \
  "󰂵  Transparence Cava : $(get cava_opacite 90) %" | menu "Bureau")
[ -z "$choice" ] && exit 0

case "$choice" in
  *carrousel*) setsid -f python3 "$U/WallCarousel.py" >/dev/null 2>&1 ;;
  *JaKooLit*)  setsid -f "$HOME/.config/hypr/scripts/WallpaperSelect.sh" >/dev/null 2>&1 ;;
  *"Platine :"*)
    [ "$(get platine on)" = on ] && set_ platine off || set_ platine on
    restart_platine; notify-send "Platine" "$(get platine on)" ;;
  *"Style de la platine"*)
    s=$(printf '%s\n' "classique   platine en bois + présentoir" "verre       carte Cava · disque, bras, boutons" \
      "neon        disque qui flotte · halo qui bat" "pochette    compacte · le disque sort de la pochette" | menu "Style de la platine")
    [ -n "$s" ] && { set_ platine_style "${s%% *}"; set_ platine on; restart_platine; notify-send "Platine" "style ${s%% *}"; } ;;
  *"Position de la platine"*)
    p=$(printf '%s\n' bas-droite bas-gauche bas-centre haut-droite haut-gauche centre | menu "Position de la platine")
    [ -n "$p" ] && { set_ platine_pos "$p"; restart_platine; } ;;
  *"Taille de la platine"*)
    t=$(printf '%s\n' petite moyenne grande | menu "Taille de la platine")
    [ -n "$t" ] && { set_ platine_taille "$t"; restart_platine; } ;;
  *"Style Cava"*)
    s=$(printf '%s\n' \
      "blocs      ▂▄▆█▆▄▂▃▅▇" "braille    ⡀⣄⣦⣿⣦⣄⡀⣀⣤⣶" "ondes      _‗⁻‾⁻‗_‗⁻‾" "fines      ▎▌▊█▊▌▎▍▋▉" \
      "ombre      ░▒▓█▓▒░▒▓█" "liquide    ▁▂▃▅▆▅▃▂▁▂" "bulles     ∘ ○ ◯ ∘  ○" "sica       ⠶⠃⠇⠧ (SICA en points)" \
      "collines   ⣀⣤⣶⣤⣀ ⠁ ⣀⣤" "pluie      ⠁ ⡀ ⠂⠈ ⢀ ⠄" | menu "Style Cava (haut + bas)")
    [ -n "$s" ] && { set_ cava_style "${s%% *}"; notify-send "Style Cava" "${s%% *}"; } ;;
  *"Couleur Cava"*)
    FAV=(); for x in $(get cava_favoris "" | tr ',' ' '); do FAV+=("★ ma couleur $x"); done
    c=$(printf '%s\n' "${FAV[@]}" "✎ taper un code couleur (#…)" "vert terminal #39ff6a" "rose #c678dd" "bleu #4f9cf9" "turquoise #56d6c0" "corail #f0997b" \
      "or #f5c66d" "blanc #e8e6f0" "dégradé (bleu → rose → corail)" "sombre (comme le cadre du post)" \
      "wallust (suit le fond d'écran)" "pipette (une couleur à l'écran, gardée dans ★)" "pipette dégradé (2 couleurs à l'écran)" \
      $( [ ${#FAV[@]} -gt 0 ] && echo "✕ retirer une de mes couleurs" ) | menu "Couleur Cava (haut + bas)")
    case "$c" in
      "pipette dégradé"*)
        notify-send "Pipette dégradé" "Clique la 1re couleur"; h1=$(pipette)
        [ -n "$h1" ] && { notify-send "Pipette dégradé" "1re : $h1 — clique la 2e couleur"; h2=$(pipette); }
        [ -n "$h1" ] && [ -n "$h2" ] && set_ cava_couleur "grad:$h1,$h2" ;;
      pipette*) h=$(pipette); [ -n "$h" ] && { set_ cava_couleur "$h"; favori "$h"; } ;;
      "✎ taper"*)
        h=$(printf '' | menu "Code couleur (ex. #001612)" | grep -oE '#?[0-9a-fA-F]{6}' | head -1)
        [ -n "$h" ] && { h="#${h#\#}"; set_ cava_couleur "$h"; favori "$h"; } || c="" ;;
      "✕ retirer"*)
        r=$(printf '%s\n' "${FAV[@]}" | menu "Retirer de mes couleurs")
        [ -n "$r" ] && set_ cava_favoris "$(get cava_favoris "" | tr ',' '\n' | grep -vix "${r##* }" | paste -sd,)"
        c="" ;;
      dégradé*) set_ cava_couleur degrade ;;
      sombre*)  set_ cava_couleur sombre ;;
      wallust*) set_ cava_couleur wallust ;;
      *'#'*)    set_ cava_couleur "#${c##*#}" ;;
    esac
    [ -n "$c" ] && { notify-send "Couleur Cava" "$(get cava_couleur wallust)"; setsid -f python3 "$U/ChorusTheme.py" >/dev/null 2>&1;  setsid -f "$U/EffetsPlus.sh" --appliquer teinte >/dev/null 2>&1; } ;;
  *"Cava liquide (haut)"*)
    [ "$(get cava_haut off)" = on ] && set_ cava_haut off || set_ cava_haut on
    restart_cava; notify-send "Cava liquide (haut)" "$(get cava_haut off)" ;;
  *"Barre Cava (bas)"*)
    [ "$(get cava_bas off)" = on ] && set_ cava_bas off || set_ cava_bas on
    restart_cava; notify-send "Barre Cava (bas)" "$(get cava_bas off)" ;;
  *"Hauteur de la barre du bas"*)
    h=$(printf '%s\n' petite moyenne grande | menu "Hauteur de la barre du bas")
    [ -n "$h" ] && { set_ cava_bas_hauteur "$h"; restart_cava; } ;;
  *"Transparence Cava"*)
    o=$(printf '%s\n' 100 90 75 60 45 | menu "Opacité Cava (%)")
    [ -n "$o" ] && set_ cava_opacite "$o" ;;
esac
