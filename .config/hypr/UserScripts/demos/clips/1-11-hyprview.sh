# nom: Hyprview (vue des fenêtres)
# groupe: 1-KooL Dots, natif
# duree: 18
# flou: non
clip() {
  ws 9; kit a btop; kit b cava; kit c; kit d; sleep 1.5
  titre "Hyprview" "toutes tes fenêtres d'un coup d'œil" 2.5; sleep 2
  local l; for l in $(printf 'spiral\nvortex\nsatellite\nmasonry\n' | shuf -n 3); do
    "$S/toggle-qs-hyprview.sh" "$l" >/dev/null 2>&1 & titre "Hyprview · $l" "" 1.8; sleep 3.5
    "$S/toggle-qs-hyprview.sh" "$l" >/dev/null 2>&1; sleep 1; done
  ferme_kits
}
