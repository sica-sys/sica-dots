# nom: Super Productivity
# groupe: 5-Productivité
# duree: 16
# flou: oui
clip() {
  local deja=0 n=0; pgrep -f super_productivity >/dev/null && deja=1
  titre "Super Productivity" "tâches synchronisées avec le téléphone" 2; sleep 1.5
  clic_sur SUPERPROD flatpak run com.super_productivity.SuperProductivity
  while ! hyprctl clients | grep -qi 'superproductivity\|super-productivity\|super_productivity' && [ $n -lt 12 ]; do sleep 1; n=$((n+1)); done
  hyprctl dispatch "hl.dsp.focus({ window = \"class:(?i).*super.?productivity.*\" })" >/dev/null 2>&1; sleep 1
  flou_fenetre 0.5; sleep 7; flou_fin
  [ "$deja" = 0 ] && pkill -f super_productivity
}
