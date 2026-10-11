# nom: Cava partout + pipette
# groupe: 3-Ma déco
# duree: 24
# flou: non
clip() {
  cfg cava_haut on; cfg cava_bas on; cava_relance
  ws 9; kit cava cava; titre "Une couleur pour tout" "Waybar · goutte · barre · bordure · notifications · cava" 3; sleep 3
  local c; for c in "#c678dd" degrade; do
    cfg cava_couleur "$c"; python3 "$U/ChorusTheme.py" >/dev/null 2>&1; notify-send -a Démo "Couleur Cava" "$c"; sleep 4; done
  titre "Pipette" "une couleur prise directement à l'écran" 2.5
  curseur POINT_PIPETTE; sleep 1.5
  local p h; p=$(pos POINT_PIPETTE); set -- $p
  h=$(grim -g "$1,$2 1x1" -t ppm - 2>/dev/null | magick - -format '#%[hex:p{0,0}]' info: 2>/dev/null | cut -c1-7)
  [ ${#h} -eq 7 ] || h="#56d6c0"
  cfg cava_couleur "$h"; python3 "$U/ChorusTheme.py" >/dev/null 2>&1; notify-send -a Démo "Pipette" "$h"; sleep 5
  ferme_kits
}
