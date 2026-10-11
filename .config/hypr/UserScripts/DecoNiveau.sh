#!/usr/bin/env bash
# Flou (Super+Alt+O) et opacité (Super+Ctrl+O) qui restent après redémarrage ou rechargement de Hyprland.
# Le choix est écrit d'abord dans ~/.local/state/deco-memo.lua (relu à CHAQUE chargement de la config), puis appliqué.
# Usage : DecoNiveau.sh flou | opacite      (option : un numéro de niveau, ex. DecoNiveau.sh flou 0)
ACT="$1"; NIV="$2"          # gardés à part : « set -- » plus bas écrase $1 et $2
M="$HOME/.local/state/deco-memo.lua"; mkdir -p "${M%/*}"
g() { hyprctl -j getoption "$1" 2>/dev/null | jq -r '.bool // .int // .float // empty'; }
# niveaux de flou : nom activé taille passes
FL=("Désactivé false 0 0" "Faible true 3 1" "Moyen true 6 2" "Fort true 8 3" "Ultra true 10 4")
# niveaux d'opacité : nom active inactive
OP=("100 % 1.0 0.9" "90 % 0.9 0.8" "80 % 0.8 0.7" "70 % 0.7 0.6" "55 % 0.55 0.45")

be=$(g decoration:blur:enabled); case "$be" in true|1) be=true ;; *) be=false ;; esac
bs=$(g decoration:blur:size); bp=$(g decoration:blur:passes); ao=$(g decoration:active_opacity); io=$(g decoration:inactive_opacity)
nf=0; [ "$be" = true ] && for i in 1 2 3 4; do set -- ${FL[$i]}; [ "$4" = "$bp" ] && nf=$i; done
no=0; for i in 0 1 2 3 4; do set -- ${OP[$i]}; awk -v a="$ao" -v b="$3" 'BEGIN{exit !(a-b<0.03 && b-a<0.03)}' && no=$i; done

case "$ACT" in
  flou)    nf=${NIV:-$(( (nf + 1) % 5 ))}; set -- ${FL[$nf]}; nom="Flou : $1"; be=$2; bs=$3; bp=$4 ;;
  opacite) no=${NIV:-$(( (no + 1) % 5 ))}; set -- ${OP[$no]}; nom="Opacité : $1 $2"; ao=$3; io=$4 ;;
  *) echo "usage : $0 flou|opacite [niveau]"; exit 1 ;;
esac
cat > "$M" <<L
return { blur = { enabled = $be, size = ${bs:-6}, passes = ${bp:-3} },
         active_opacity = ${ao:-1.0}, inactive_opacity = ${io:-0.9} }
L
hyprctl eval "hl.config({ decoration = { blur = { enabled = $be, size = ${bs:-6}, passes = ${bp:-3} }, active_opacity = ${ao:-1.0}, inactive_opacity = ${io:-0.9} } })" >/dev/null 2>&1
notify-send -e -u low -h string:x-canonical-private-synchronous:deco_notif "$nom" "gardé après redémarrage"
