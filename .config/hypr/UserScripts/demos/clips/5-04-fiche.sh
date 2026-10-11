# nom: Fiche perso (reste jusqu'à la fin)
# groupe: 5-Productivité
# duree: 34
# flou: non
clip() {
  local F="$HOME/FichePerso" s c
  echo C > "$F/choix.txt"
  titre "Ma fiche perso" "bouton profil de la Waybar" 2; sleep 1
  clic_sur PROFIL "$S/ProfilCard.sh"; sleep 3
  for s in D E F G C; do echo "$s" > "$F/choix.txt"; sleep 3.2; done
  titre "Elle suit la couleur Cava" "en direct" 2.2
  for c in "#c678dd" degrade "#f5c66d" wallust; do cfg cava_couleur "$c"; python3 "$U/ChorusTheme.py" >/dev/null 2>&1; sleep 3.2; done
  # la fiche reste ouverte : elle est fermée à la toute fin de la démo
}
