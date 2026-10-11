#!/usr/bin/env bash
# Visite guidée de la config pour la vidéo. Lancer : Super+Alt+V — Arrêter : Super+Alt+Échap
# ====================== RÉGLAGES ======================
SCENES=(bureau fonds kitty musique waybar series menus)   # ordre des scènes (retire/déplace ici)
D_BUREAU=5; D_FONDS=8; D_KITTY=8; D_MUSIQUE=10; D_WAYBAR=10; D_SERIES=5; D_MENUS=6   # durées en secondes
TITRES=1        # 1 = petits titres à l'écran, 0 = rien
ENREGISTRER=1   # 1 = le script enregistre, 0 = tu lances ton enregistreur toi-même
SON=1           # 1 = son du PC (ta musique), 0 = vidéo muette
# =====================================================
H="$HOME/.config/hypr"; S="$H/scripts"; U="$H/UserScripts"
DIR="$(xdg-user-dir VIDEOS 2>/dev/null)"; [ -d "$DIR" ] || DIR="$HOME/Vidéos"; mkdir -p "$DIR"
OUT="$DIR/visite-config-$(date +%Y%m%d-%H%M%S).mp4"
titre() { [ "$TITRES" = 1 ] && notify-send -a "Visite" -t 2200 "$1" "${2:-}"; }
ferme() { pkill -x rofi 2>/dev/null; sleep 0.3; }
ws()    { hyprctl dispatch workspace "$1" >/dev/null 2>&1; }
lance() { setsid -f "$@" >/dev/null 2>&1; }
fin()   { ferme; pkill -f "class visite-kitty" 2>/dev/null; pkill -f agenda_gui.py 2>/dev/null; pkill -f NowPlaying.py 2>/dev/null
          [ -n "$PLATINE" ] && pkill -f Platine.py; pkill -INT -x wf-recorder 2>/dev/null; true; }
trap fin EXIT; trap 'fin; exit' INT TERM

scene_bureau()  { titre "Mon bureau" "Hyprland · KooL Dots"; ws 1; sleep "$D_BUREAU"; }
scene_fonds()   { titre "Fonds d'écran" "les couleurs suivent le fond"
                  lance python3 "$U/WallCarousel.py"; sleep $((D_FONDS / 2)); pkill -f WallCarousel.py
                  "$S/WallpaperRandom.sh" >/dev/null 2>&1 & sleep $((D_FONDS - D_FONDS / 2)); }
scene_kitty()   { titre "Terminal" "Kitty + fastfetch"; lance kitty --class visite-kitty
                  sleep "$D_KITTY"; pkill -f "class visite-kitty"; sleep 0.5; }
scene_musique() { titre "Musique" "albums, platine, lecture en cours"; playerctl play 2>/dev/null
                  lance "$U/AlbumPicker.sh"; sleep 3; ferme
                  pgrep -f Platine.py >/dev/null || { lance python3 "$U/Platine.py"; PLATINE=1; }
                  lance python3 "$U/NowPlaying.py"; sleep $((D_MUSIQUE - 3)); pkill -f NowPlaying.py; }
scene_waybar()  { titre "Barre" "calendrier, météo, agenda"; A="$U/AgendaMeteo.sh"; n=$((D_WAYBAR / 3))
                  $A mini; sleep $n; $A mini; $A meteo; sleep $n; $A meteo; $A agenda; sleep $n; $A agenda; }
scene_series()  { titre "Mes séries"; lance "$U/series/MesSeries.sh"; sleep "$D_SERIES"; ferme; }
scene_menus()   { titre "Menus"; n=$((D_MENUS / 2))
                  lance "$S/KeyBinds.sh"; sleep $n; ferme; lance "$S/Kool_Quick_Settings.sh"; sleep $n; ferme; }

for i in 3 2 1; do notify-send -a "Visite" -t 900 "Départ dans $i…"; sleep 1; done; sleep 1
if [ "$ENREGISTRER" = 1 ]; then
  AUD=(); [ "$SON" = 1 ] && AUD=(--audio="$(pactl get-default-sink).monitor")
  lance wf-recorder "${AUD[@]}" -f "$OUT"; sleep 1
fi
for s in "${SCENES[@]}"; do "scene_$s"; done
titre "Merci d'avoir regardé"; ws 1; sleep 2
fin; trap - EXIT
[ "$ENREGISTRER" = 1 ] && notify-send -a "Visite" "Vidéo enregistrée" "$OUT"
