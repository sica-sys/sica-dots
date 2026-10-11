# nom: En cours de lecture
# groupe: 4-Musique
# duree: 12
# flou: non
clip() {
  playerctl play 2>/dev/null; lance python3 "$U/NowPlaying.py"; sleep 0.8
  titre "En cours de lecture" "pochette, Cava, contrôles" 2; sleep 10; pkill -f NowPlaying.py
}
