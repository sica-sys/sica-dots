# nom: Carrousel de fonds
# groupe: 3-Ma déco
# duree: 16
# flou: non
clip() {
  titre "Carrousel de fonds" "Super+W · fait maison" 2; sleep 1.5
  lance python3 "$U/WallCarousel.py" --demo 2; sleep 1; attendre WallCarousel.py 20; sleep 1
}
