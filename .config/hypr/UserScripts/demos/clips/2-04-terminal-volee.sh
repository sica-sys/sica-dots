# nom: Terminal à la volée (thèmes, prompt, shaders)
# groupe: 2-Système
# duree: 36
# flou: non
clip() {
  ws 9; kit a; kit b; sleep 2.5
  titre "Terminal à la volée" "thème Kitty · prompt Oh My Zsh · shaders" 3; sleep 3
  local t z
  for t in $(kitty_themes_hasard 2); do kitty_theme "$t"; titre "Thème Kitty" "$t" 2; sleep 3.5; done
  for z in agnoster bira jonathan; do zsh_theme "$z"; ferme_kits; kit a; kit b; titre "Prompt Oh My Zsh" "$z" 2; sleep 4; done
  ferme_kits; kit a; sleep 1.2                    # shaders : une seule fenêtre
  shader water;    titre "Shader « Water »" "" 2; sleep 4
  shader crt-blue; titre "Shader « CRT bleu »" "" 2; sleep 4
  shader ""; ferme_kits
}
