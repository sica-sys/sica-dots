# nom: Vue d'ensemble et session
# groupe: 1-KooL Dots, natif
# duree: 10
# flou: non
clip() {
  titre "Session" "vue d'ensemble · menu de sortie"; sleep 1.5
  "$S/OverviewToggle.sh" >/dev/null 2>&1 && { sleep 3; "$S/OverviewToggle.sh" >/dev/null 2>&1; sleep 0.6; }
  lance "$S/Wlogout.sh"; sleep 3.5; pkill -x wlogout
}
