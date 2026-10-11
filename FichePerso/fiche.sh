#!/usr/bin/env bash
# Affiche la fiche perso. Touches : A à G = changer de style (gardé), autre touche = fermer.
# Se redessine toute seule si le style ou la couleur Cava change (utile pour les démos vidéo).
F="$HOME/FichePerso"; B="$HOME/.config/hypr/UserScripts/bureau.conf"
sig() { stat -c %Y "$F/choix.txt" "$B" "$HOME/.cache/cava-couleur-fond.txt" 2>/dev/null | tr '\n' ' '; }
while :; do
  clear; python3 "$F/fiche.py"
  printf '\n  \033[2mStyle :  A améliorée · B encadrée · C SICA · D néon · E arcade · F contour · G ombre\n  autre touche = fermer\033[0m'
  printf '\033[?25l'; s0=$(sig)
  while :; do
    if read -rsn1 -t 1 k; then
      printf '\033[?25h'
      case "${k^^}" in A|B|C|D|E|F|G) echo "${k^^}" > "$F/choix.txt"; break ;; *) exit 0 ;; esac
    fi
    [ "$(sig)" != "$s0" ] && break
  done
done
