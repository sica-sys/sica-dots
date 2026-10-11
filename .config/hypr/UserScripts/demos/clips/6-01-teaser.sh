# nom: Teaser 15 s
# groupe: 6-Teaser
# duree: 15
# flou: non
clip() {
  titre "Ma config Hyprland" "KooL Dots + déco Sica" 2; sleep 2
  "$S/WallpaperRandom.sh" >/dev/null 2>&1 & sleep 2.5
  cfg effet_actif pixel; "$U/EffetsPlus.sh" --appliquer pixel; sleep 2
  ws 9; kit a cava; kit b btop; kit c; sleep 1.2
  cfg cava_couleur degrade; python3 "$U/ChorusTheme.py" >/dev/null 2>&1; fenetre_suivante; sleep 1.5; fenetre_suivante; sleep 1.5
  local avant; avant=$(hyprctl -j getoption general:layout | jq -r ".str // \"dwindle\"")
  disposition scrolling; fenetre_suivante; sleep 1.5; disposition "$avant"; ferme_kits; ws 1
  titre "Merci JaKooLit et LinuxBeginnings" "" 2; sleep 2
}
