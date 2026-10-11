# nom: Outils Rofi (emoji, calcul, presse-papier)
# groupe: 1-KooL Dots, natif
# duree: 15
# flou: non
clip() {
  titre "Outils Rofi" "emoji · calculatrice · presse-papier · recherche"; sleep 1.5
  vu 3.5 "$U/RofiEmojiFR.sh"
  vu 3.5 "$U/RofiCalc.sh"
  flou_debut plein; vu 3 "$S/ClipManager.sh"; flou_fin        # l'historique du presse-papier est flouté
  vu 3 "$S/RofiSearch.sh"
}
