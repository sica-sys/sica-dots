# nom: Effets + (pixel, teinte, thèmes)
# groupe: 3-Ma déco
# duree: 17
# flou: non
clip() {
  titre "Effets +" "pixel art · teinte Cava · thèmes de couleurs"; sleep 1.5
  vu 3 "$U/EffetsPlus.sh"
  cfg effet_actif pixel; "$U/EffetsPlus.sh" --appliquer pixel; titre "Pixel art" "" 1.5; sleep 3.5
  cfg effet_actif teinte; "$U/EffetsPlus.sh" --appliquer teinte; titre "Teinte Cava" "" 1.5; sleep 3.5
  cfg effet_theme catppuccin; cfg effet_actif theme; "$U/EffetsPlus.sh" --appliquer theme; titre "Thème Catppuccin" "" 1.5; sleep 3.5
}
