# nom: Fonds d'écran (carrousel)
# groupe: 1-KooL Dots, natif
# duree: 22
# flou: non
clip() {
  titre "Fonds d'écran" "carrousel Super+W · les couleurs suivent le fond" 2.5; sleep 2
  lance python3 "$U/WallCarousel.py" --demo 3; sleep 1; attendre WallCarousel.py 25; sleep 1.5
}
