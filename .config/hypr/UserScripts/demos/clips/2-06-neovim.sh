# nom: Neovim et ses modules
# groupe: 2-Système
# duree: 18
# flou: non
clip() {
  local img; img=$(readlink -f "$H/rofi/.current_wallpaper")
  printf '# Ma config Neovim\n\nCouleurs affichées en direct : #c678dd  #56d6c0  #f0997b  #4f9cf9\n\n| Module | Touche |\n|---|---|\n| undotree | Espace+U |\n| colorizer | Espace+u+c |\n\n![fond](%s)\n' "$img" > "$RUN/demo-nvim.md"
  ws 9; kit nvim nvim; titre "Neovim" "dashboard, thèmes et modules au choix" 2; sleep 6
  kit nvim2 nvim "$RUN/demo-nvim.md"; titre "Couleurs, tableaux et images" "directement dans le texte" 2; sleep 8; ferme_kits
}
