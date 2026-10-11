# nom: Goutte et barre Cava (10 styles)
# groupe: 3-Ma déco
# duree: 16
# flou: non
clip() {
  cfg cava_haut on; cfg cava_bas on; cava_relance; playerctl play 2>/dev/null
  titre "Cava liquide" "la goutte sous la Waybar, la barre en bas" 2.5; sleep 3
  local s; for s in blocs braille liquide bulles sica; do cfg cava_style "$s"; titre "$s" "" 1.4; sleep 2.5; done
}
