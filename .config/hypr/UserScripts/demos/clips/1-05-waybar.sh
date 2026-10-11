# nom: Waybar : 3 dispositions
# groupe: 1-KooL Dots, natif
# duree: 20
# flou: non
clip() {
  titre "Waybar" "des dizaines de styles et de dispositions" 2.5; sleep 1.5
  vu 3 "$S/WaybarLayout.sh"
  waybar_style "[BOT] Default Laptop"; titre "Waybar en bas" "" 2; sleep 4
  waybar_style "[LEFT] WestWing";      titre "Waybar sur le côté" "" 2; sleep 4
  waybar_style "TOP-Default-Laptop-glass.bak"; titre "Ma Waybar" "verre, en haut" 2; sleep 3.5
}
