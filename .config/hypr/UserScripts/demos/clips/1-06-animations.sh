# nom: Presets d'animations
# groupe: 1-KooL Dots, natif
# duree: 20
# flou: non
clip() {
  local A="$H/animations" UA="$H/UserConfigs/user_animations.lua"
  titre "Animations" "plus de 20 presets prêts à l'emploi"; sleep 1.5
  vu 3 "$S/Animations.sh"
  for p in "HYDE - Vertical" "ML4W - dynamic" "END-4"; do
    [ -f "$A/$p.lua" ] || continue
    cp -f "$A/$p.lua" "$UA"; hyprctl reload >/dev/null 2>&1; titre "$p" "" 1.5; sleep 0.8
    kit anim; sleep 1.2; ws 9; sleep 1; ws 8; sleep 1; ferme_kits; sleep 0.8
  done
  ws 1
}
