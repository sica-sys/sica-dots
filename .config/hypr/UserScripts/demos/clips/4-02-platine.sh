# nom: Platine vinyle
# groupe: 4-Musique
# duree: 10
# flou: non
clip() {
  local la=0; playerctl play 2>/dev/null
  pgrep -f 'UserScripts/Platine.py' >/dev/null || { lance python3 "$U/Platine.py"; la=1; }
  titre "Platine" "la pochette tourne sur le bureau" 2; sleep 8.5
  [ "$la" = 1 ] && pkill -f 'UserScripts/Platine.py'
}
