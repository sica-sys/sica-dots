#!/usr/bin/env bash
# Menu « Démos vidéo » (Super+Alt+Z) : groupes de clips, montages, options, flou après coup.
source "$HOME/.config/hypr/UserScripts/demos/lib.sh"
rasi="$H/rofi/config-kitty-theme.rasi"
menu() { local o=(-dmenu -i -p "$1"); [ -f "$rasi" ] && o+=(-config "$rasi"); shift; rofi "${o[@]}" "$@"; }
set_() { touch "$OPT"; sed -i "/^$1=/d" "$OPT"; echo "$1=$2" >> "$OPT"; }
champ() { grep -m1 "^# $2:" "$1" | cut -d: -f2- | sed 's/^ *//'; }
pkill -x rofi && exit 0

# clips rangés par groupe (champ « # groupe: N-Nom »)
declare -A GFILES GDUR; GROUPES=()
while IFS= read -r f; do
  g=$(champ "$f" groupe); [ -n "$g" ] || continue
  [ -n "${GFILES[$g]}" ] || GROUPES+=("$g")
  GFILES[$g]+="$f"$'\n'; d=$(champ "$f" duree | tr -cd 0-9); GDUR[$g]=$(( ${GDUR[$g]:-0} + ${d:-15} ))
done < <(ls "$D"/clips/*.sh 2>/dev/null | sort)
mapfile -t GROUPES < <(printf '%s\n' "${GROUPES[@]}" | sort -n)
nomg() { echo "${1#*-}"; }
duree() { local s=$1; [ "$s" -ge 60 ] && printf '%d min %02d s' $((s/60)) $((s%60)) || printf '%d s' "$s"; }
tous() { for g in "${GROUPES[@]}"; do [[ "$g" == *Teaser* ]] && continue; printf '%s' "${GFILES[$g]}"; done | sed '/^$/d'; }   # la fiche perso finit la visite

while :; do
  L=()
  for g in "${GROUPES[@]}"; do n=$(printf '%s' "${GFILES[$g]}" | grep -c .)
    L+=("$( [ "${g%%-*}" = 1 ] && echo '★' || echo '▸')  $(nomg "$g")   ($n clips · $(duree "${GDUR[$g]}"))"); done
  total=0; for g in "${GROUPES[@]}"; do total=$((total + GDUR[$g])); done
  L+=("▶  Visite complète   (tous les clips · $(duree $total))" "☑  Ma sélection (Maj+Entrée pour cocher)")
  [ -x "$U/VisiteGuidee.sh" ] && L+=("▶  Ancienne visite guidée")
  L+=("●  Enregistrer : $(opt rec oui)" "♪  Son de la musique : $(opt son oui)" "T  Titres à l'écran : $(opt titres oui)"
      "◐  Flou automatique des infos perso : $(opt flou_auto oui)" "◐  Flouter la dernière vidéo")
  [ -f "$RUN/demo.pid" ] && L+=("■  Arrêter la démo en cours")
  c=$(printf '%s\n' "${L[@]}" | menu "Démos vidéo" -mesg "Super+Alt+F pendant l'enregistrement = début / fin d'un passage flouté · Super+Alt+Échap = stop")
  [ -z "$c" ] && exit 0
  case "$c" in
    *"Enregistrer :"*) [ "$(opt rec oui)" = oui ] && set_ rec non || set_ rec oui; continue ;;
    *"Son de la musique"*) [ "$(opt son oui)" = oui ] && set_ son non || set_ son oui; continue ;;
    *"Titres à l'écran"*) [ "$(opt titres oui)" = oui ] && set_ titres non || set_ titres oui; continue ;;
    *"Flou automatique"*) [ "$(opt flou_auto oui)" = oui ] && set_ flou_auto non || set_ flou_auto oui; continue ;;
    *"Flouter la dernière"*) exec python3 "$D/DemoFlou.py" --apres ;;
    *"Arrêter la démo"*) pkill -f 'demos/Demo.sh'; exit 0 ;;
    *"Ancienne visite"*) exec "$U/VisiteGuidee.sh" ;;
    *"Visite complète"*) mapfile -t F < <(tous); exec "$D/Demo.sh" "Visite complète" "${F[@]}" ;;
    *"Ma sélection"*)
      mapfile -t F < <(tous); N=(); for f in "${F[@]}"; do N+=("$(champ "$f" nom)   · $(nomg "$(champ "$f" groupe)")"); done
      sel=$(printf '%s\n' "${N[@]}" | menu "Ma sélection" -multi-select -mesg "Maj+Entrée pour cocher plusieurs clips, Entrée pour lancer")
      [ -z "$sel" ] && continue; G=()
      while IFS= read -r l; do for i in "${!N[@]}"; do [ "${N[$i]}" = "$l" ] && G+=("${F[$i]}"); done; done <<< "$sel"
      exec "$D/Demo.sh" "Ma sélection" "${G[@]}" ;;
  esac
  for g in "${GROUPES[@]}"; do
    [[ "$c" == *"$(nomg "$g")   ("* ]] || continue
    mapfile -t F < <(printf '%s' "${GFILES[$g]}" | sed '/^$/d')
    S2=("▶  Tout le groupe   ($(duree "${GDUR[$g]}"))"); for f in "${F[@]}"; do
      S2+=("   $(champ "$f" nom)   ($(champ "$f" duree | tr -cd 0-9) s)$( [ "$(champ "$f" flou)" = oui ] && echo '   ◐ flouté')"); done
    S2+=("←  Retour")
    k=$(printf '%s\n' "${S2[@]}" | menu "$(nomg "$g")")
    case "$k" in ""|*Retour*) continue ;; *"Tout le groupe"*) exec "$D/Demo.sh" "$(nomg "$g")" "${F[@]}" ;; esac
    for f in "${F[@]}"; do [[ "$k" == "   $(champ "$f" nom)   ("* ]] && exec "$D/Demo.sh" "$(champ "$f" nom)" "$f"; done
  done
done
