# nom: Flou et mode jeu
# groupe: 1-KooL Dots, natif
# duree: 15
# flou: non
clip() {
  ws 9; kit fetch; kit cava cava; sleep 0.8
  titre "Flou des fenêtres" "5 niveaux en un raccourci"; sleep 1.5
  "$S/ChangeBlur.sh" >/dev/null 2>&1; sleep 2.2
  "$S/ChangeBlur.sh" >/dev/null 2>&1; sleep 2.2
  titre "Mode jeu" "zéro effet, toute la puissance pour le jeu" 2; sleep 0.5
  "$S/GameMode.sh" >/dev/null 2>&1; sleep 3
  "$S/GameMode.sh" >/dev/null 2>&1; sleep 3
  ferme_kits
}
