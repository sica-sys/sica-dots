# nom: Dispositions + shaders
# groupe: 1-KooL Dots, natif
# duree: 40
# flou: non
clip() {
  local avant; avant=$(hyprctl -j getoption general:layout | jq -r '.str // "dwindle"')
  ws 9
  # shaders : sur UNE seule fenêtre (plusieurs Kitty avec shader = ça saccade)
  kit fetch; sleep 1.5
  shader water;    titre "Shader « Water »" "un effet d'eau dans le terminal" 2.5; sleep 4
  shader crt-blue; titre "Shader « CRT bleu »" "comme un vieil écran" 2.2; sleep 4
  shader ""; ferme_kits
  titre "Plusieurs dispositions de page" "les fenêtres se rangent toutes seules" 3
  kit btop sh -c 'btop || htop || top'; kit cava cava; kit fetch; kit nvim nvim; sleep 2.5
  disposition dwindle;   titre "Dwindle" "chaque fenêtre coupe l'espace en deux" 2.2; sleep 5
  disposition master;    titre "Master" "une grande à gauche, les autres empilées" 2.2; sleep 5
  disposition scrolling; titre "Scrolling" "les fenêtres défilent comme un ruban" 2.2; sleep 2
  for _ in 1 2 3 4; do fenetre_suivante; sleep 1.3; done
  "$S/ScrollCycleColumnWidth.sh" >/dev/null 2>&1; sleep 2
  disposition monocle;   titre "Monocle" "une seule fenêtre à la fois" 2.2; sleep 4
  disposition "$avant"; ferme_kits
}
