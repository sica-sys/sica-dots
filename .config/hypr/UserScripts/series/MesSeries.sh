#!/usr/bin/env bash
# Mes séries — grille Rofi d'affiches. Liste : series.txt (Titre|lien ou chemin local)
D="$HOME/.config/hypr/UserScripts/series"; L="$D/series.txt"; J="$D/jaquettes"; I="$D/icones"
TH="$HOME/.config/rofi/verre-grille.rasi"; TL="$HOME/.config/rofi/verre.rasi"
mkdir -p "$J"; touch "$L"
nom()    { echo "${1//\//-}"; }
liste()  { rofi -theme "$TL" -dmenu -i "$@"; }
saisie() { rofi -theme "$TL" -dmenu -p "$1" -theme-str 'listview{lines:0;}' </dev/null; }
cible()  { grep -F "$1|" "$L" | head -1 | cut -d'|' -f2-; }
premiere_video() {
  if [ -d "$1" ]; then find "$1" -maxdepth 2 -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.avi' -o -iname '*.webm' -o -iname '*.mov' \) | sort | head -1
  else echo "$1"; fi; }
capture() {  # $1 vidéo  $2 image  $3 seconde de départ
  ffmpeg -loglevel error -y -ss "${3:-90}" -i "$1" -vf "thumbnail=80,scale=480:-1" -frames:v 1 "$2" 2>/dev/null \
  || ffmpeg -loglevel error -y -i "$1" -vf "thumbnail=80,scale=480:-1" -frames:v 1 "$2" 2>/dev/null; }
affiche_auto() {  # affiche avec initiales quand il n'y a pas d'image
  local f="$J/.auto-$(nom "$1").svg"
  local ini; ini=$(echo "$1" | awk '{for(i=1;i<=NF&&i<=2;i++) printf toupper(substr($i,1,1))}')
  [ -f "$f" ] || cat > "$f" <<A
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="280" viewBox="0 0 200 280"><rect x="4" y="4" width="192" height="272" rx="18" fill="#262238" stroke="#4f9cf9" stroke-width="4"/><circle cx="100" cy="125" r="58" fill="#c678dd" opacity="0.18"/><text x="100" y="145" font-family="sans-serif" font-size="56" font-weight="bold" fill="#f4f1ff" text-anchor="middle">$ini</text><rect x="40" y="225" width="120" height="6" rx="3" fill="#c678dd" opacity="0.6"/></svg>
A
  echo "$f"; }
grille() {
  { while IFS='|' read -r t c; do [ -z "$t" ] && continue
      img=$(ls "$J/$(nom "$t")".* 2>/dev/null | head -1); [ -z "$img" ] && img=$(affiche_auto "$t")
      printf '%s\0icon\x1f%s\n' "$t" "$img"
    done < "$L"
    printf 'Ajouter\0icon\x1f%s\n' "$I/ajouter.svg"
    if [ -s "$L" ]; then printf 'Affiche\0icon\x1f%s\nRetirer\0icon\x1f%s\n' "$I/affiche.svg" "$I/retirer.svg"; fi
  } | rofi -theme "$TH" -dmenu -i -p "Mes séries" -show-icons
}
lire() { if command -v mpv >/dev/null; then setsid -f mpv --force-window=immediate "$1" >/dev/null 2>&1; else xdg-open "$1"; fi; }

choix=$(grille) || exit 0
case "$choix" in
  Ajouter)
    t=$(saisie "Titre") || exit 0; [ -z "$t" ] && exit 0; n=$(nom "$t")
    type=$(printf '🔗  Lien\n🎬  Fichier vidéo\n📁  Dossier d'"'"'épisodes\n' | liste -p "Type") || exit 0
    case "$type" in
      *Lien*)
        c=$(wl-paste 2>/dev/null | head -1 | liste -p "Lien (Entrée = presse-papiers)") || exit 0
        a=$(saisie "Lien de l'affiche (Échap = aucune)") && [ -n "$a" ] && curl -sL "$a" -o "$J/$n.jpg" ;;
      *Fichier*)
        c=$(zenity --file-selection --title="Choisis la vidéo" --file-filter="Vidéos | *.mp4 *.mkv *.avi *.webm *.mov *.m4v" 2>/dev/null) || exit 0
        capture "$c" "$J/$n.jpg" ;;
      *Dossier*)
        c=$(zenity --file-selection --directory --title="Choisis le dossier d'épisodes" 2>/dev/null) || exit 0
        v=$(premiere_video "$c"); [ -n "$v" ] && capture "$v" "$J/$n.jpg" ;;
      *) exit 0 ;;
    esac
    [ -n "$c" ] && printf '%s|%s\n' "$t" "$c" >> "$L"
    exec "$0" ;;
  Affiche)
    t=$(cut -d'|' -f1 "$L" | liste -p "Affiche de") || exit 0; n=$(nom "$t"); c=$(cible "$t")
    opts='🔗  Image depuis un lien\n🖼  Image de mon PC'
    case "$c" in http*) ;; *) opts="$opts"'\n🎬  Nouvelle capture de la vidéo' ;; esac
    o=$(printf "$opts\n" | liste -p "Source") || exit 0
    case "$o" in
      *lien*) a=$(wl-paste 2>/dev/null | head -1 | liste -p "Lien de l'image") || exit 0
              rm -f "$J/$n".*; curl -sL "$a" -o "$J/$n.jpg" ;;
      *PC*)   f=$(zenity --file-selection --title="Choisis l'image" --file-filter="Images | *.jpg *.jpeg *.png *.webp" 2>/dev/null) || exit 0
              rm -f "$J/$n".*; cp "$f" "$J/$n.${f##*.}" ;;
      *capture*) v=$(premiere_video "$c"); rm -f "$J/$n".*; capture "$v" "$J/$n.jpg" $((RANDOM % 900 + 60)) ;;
    esac
    exec "$0" ;;
  Retirer)
    t=$(cut -d'|' -f1 "$L" | liste -p "Retirer") || exit 0
    grep -vF "$t|" "$L" > "$L.tmp" && mv "$L.tmp" "$L"; rm -f "$J/$(nom "$t")".* "$J/.auto-$(nom "$t").svg"
    exec "$0" ;;
  *)
    c=$(cible "$choix")
    case "$c" in http*) xdg-open "$c" ;; "") ;; *) lire "$c" ;; esac ;;
esac
