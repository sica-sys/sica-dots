#!/usr/bin/env bash
# Aide-mémoire en français (Super+H ou clic gauche sur HINT! dans la Waybar). Tape pour filtrer, Échap pour fermer.
# Clic droit sur HINT! = chercher dans TOUS les raccourcis (KeyBinds.sh de KooL).
pkill -x rofi && exit 0
S="Super"   # touche Windows
L=( \
  "━━━━━━━━" "BASES" "" \
  "$S Entrée" "Terminal" "Kitty" \
  "$S D" "Lanceur d'applications" "Rofi (thème : $S Ctrl R)" \
  "$S E" "Fichiers" "Thunar" \
  "$S B" "Navigateur" "" \
  "$S Q" "Fermer la fenêtre" "$S Shift Q = forcer" \
  "$S A" "Hyprview (vue des fenêtres)" "$S Alt L = choisir la disposition" \
  "$S Alt 1 / 2 / 3 / 4" "Disposition de l'espace" "dwindle · master · scrolling · monocle" \
  "$S H" "Cet aide-mémoire" "clic droit sur HINT! = tous les raccourcis" \
  "$S Shift K" "Chercher un raccourci" "" \
  "$S Shift E" "Réglages KooL" "" \
  "━━━━━━━━" "FONDS ET COULEURS" "" \
  "$S W" "Carrousel de fonds d'écran" "fait maison" \
  "$S Shift W" "Effets + (pixel art, teinte Cava, thèmes)" "« Gérer les Effets + » pour en cacher" \
  "Ctrl Alt W" "Fond d'écran au hasard" "" \
  "Clic molette sur la Cava" "Menu Bureau" "couleur, style, goutte, barre, platine" \
  "$S Shift A" "Animations + « A Bordure Cava »" "les2 · rotation · battement · off" \
  "$S Alt O" "Niveau de flou" "désactivé → ultra, gardé au redémarrage" \
  "$S Ctrl O" "Opacité des fenêtres" "100 → 55 %, gardée au redémarrage" \
  "$S Ctrl R" "Thème Rofi" "dont Cava-Verre-violet et Cava-Verre-opaque" \
  "━━━━━━━━" "WAYBAR" "" \
  "$S Ctrl B" "Style de la Waybar" "" \
  "$S Alt B" "Disposition de la Waybar" "" \
  "Ctrl Alt B" "Cacher / montrer la Waybar" "" \
  "$S Alt R" "Recharger Waybar, notifications, Rofi" "" \
  "$S Alt Y" "Bascule barre Cyber (boite a outils cybersecurite)" "" \
  "Clic gauche / droit sur la Cava" "Lecteur / pause" "" \
  "Clic gauche / droit sur le profil" "Fiche perso / fiche pro" "fiche perso : touches A à G pour le style" \
  "Clic sur la date, l'heure, la météo" "Calendrier, agenda, météo" "" \
  "━━━━━━━━" "MUSIQUE ET OUTILS" "" \
  "$S Shift M" "RofiBeats (radios)" "" \
  "$S Alt A" "Mes séries" "" \
  "$S Alt V" "Presse-papier" "" \
  "$S Alt E" "Emojis (en français)" "tape « coeur », « mdr »…" \
  "$S S" "Recherche web" "" \
  "$S Shift N" "Centre de notifications" "" \
  "Ctrl Alt P" "Menu d'extinction" "wlogout" \
  "━━━━━━━━" "CAPTURES ET VIDÉOS" "" \
  "Impr" "Capture d'écran" "Shift Impr = zone · Alt Impr = fenêtre" \
  "$S Shift S" "Capture d'une zone + annotations" "swappy" \
  "$S Favoris (étoile)" "Enregistrer l'écran" "démarrer / arrêter · ~/Videos/Recordings" \
  "$S Alt Z" "Démos vidéo de la config" "groupes, visite complète, options" \
  "$S Alt Échap" "Arrêter la démo" "la config revient comme avant" \
  "$S Alt F" "Flouter un passage de la vidéo" "1er appui : encadrer la zone (clic = tout l'écran) · 2e appui : fin" \
  "━━━━━━━━" "TERMINAL ET NEOVIM" "" \
  "$S Alt K" "Shaders Kitty" "" \
  "$S Alt N" "Dashboards Neovim" "" \
  "$S Alt M" "Modules Neovim" "activer / désactiver" \
  "$S Alt X" "Thème de la barre Neovim" "lualine" \
  "Neovim : Ctrl F" "Chercher dans le fichier" "Entrée pour y aller" \
  "Neovim : Espace U" "Historique d'annulation" "undotree" \
  "Neovim : :w" "Enregistrer sans quitter" ":wq = enregistrer et quitter" \
)
# affichage avec Rofi (thème Cava si présent) : touche · action · détail
T="$HOME/.config/hypr/rofi/themes/Cava-Verre-opaque.rasi"; O=(); [ -f "$T" ] && O=(-theme "$T")
esc() { local x="${1//&/&amp;}"; x="${x//</&lt;}"; printf '%s' "${x//>/&gt;}"; }
for ((i=0; i<${#L[@]}; i+=3)); do
  k="${L[i]}"; a="${L[i+1]}"; d="${L[i+2]}"
  if [[ "$k" == ━* ]]; then printf '<b>━━━━  %s  ━━━━</b>\n' "$(esc "$a")"; continue; fi
  pad=$(( 34 - ${#k} )); [ $pad -lt 1 ] && pad=1
  printf '<b>%s</b>%*s%s' "$(esc "$k")" $pad '' "$(esc "$a")"
  [ -n "$d" ] && printf "  <span alpha='55%%'>· %s</span>" "$(esc "$d")"; echo
done | rofi -dmenu -i -markup-rows -no-custom -p "Aide-mémoire" "${O[@]}" \
  -theme-str 'window { width: 1100px; } mainbox { children: [ inputbar, message, listview ]; } textbox { text-color: #9a94b8; } listview { lines: 18; } element-icon { enabled: false; } entry { placeholder: "Tape pour filtrer (ex. flou, waybar)…"; }' \
  -mesg "Super+H ou clic gauche sur HINT! · clic droit sur HINT! = chercher dans tous les raccourcis" >/dev/null
