# nom: btop, moniteur système
# groupe: 2-Système
# duree: 16
# flou: non
clip() {
  ws 9; titre "Infos système" "en passant la souris sur la barre" 2.5
  curseur TEMPERATURE; sleep 2.5
  curseur RAM; sleep 2.5
  titre "btop" "clic droit sur la RAM" 1.8; kit btop btop; sleep 8; ferme_kits
}
