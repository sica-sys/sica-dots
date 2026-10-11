# nom: yazi, fichiers dans le terminal
# groupe: 2-Système
# duree: 12
# flou: non
clip() {
  local d; for d in "$HOME/Pictures/wallpapers" "$HOME/Images/wallpapers" "$HOME/Pictures" "$H"; do [ -d "$d" ] && break; done
  ws 9; kit yazi yazi "$d"; titre "yazi" "explorateur avec aperçu des images" 2; sleep 10; ferme_kits
}
