# nom: Bordure qui bat
# groupe: 3-Ma déco
# duree: 18
# flou: non
clip() {
  cfg bordure_cava les2; pkill -f CavaBordure.py; sleep 0.3; setsid -f python3 "$U/CavaBordure.py" >/dev/null 2>&1
  playerctl play 2>/dev/null; ws 9; kit a cava; kit b btop; kit c; sleep 1
  titre "Bordure Cava" "réagit aux basses de la musique" 3.5; sleep 1
  for _ in 1 2 3 4 5 6; do fenetre_suivante; sleep 2.2; done; ferme_kits
}
