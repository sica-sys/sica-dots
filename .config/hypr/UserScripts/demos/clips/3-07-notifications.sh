# nom: Notifications
# groupe: 3-Ma déco
# duree: 8
# flou: non
clip() {
  titre "Notifications" "contour à la couleur de la Cava" 2; sleep 1.5
  notify-send -a Démo "Bonjour 👋" "Voici une notification"; sleep 1.5
  notify-send -a Démo -u critical "Important" "Elles suivent aussi la couleur"; sleep 4
}
