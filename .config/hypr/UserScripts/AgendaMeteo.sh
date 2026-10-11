#!/usr/bin/env bash
K=$(command -v kitty || echo "$HOME/.local/kitty.app/bin/kitty")
S="$HOME/.config/hypr/UserScripts/AgendaMeteo.sh"; D="$HOME/.config/hypr/UserScripts/agenda"
pop(){ if pgrep -f "class $1 " >/dev/null; then pkill -f "class $1 "
       else setsid -f "$K" --class $1 -e "$S" $3 >/dev/null 2>&1; fi; }
gui(){ if pgrep -f "agenda_gui.py $1" >/dev/null; then pkill -f "agenda_gui.py $1"
       else setsid -f python3 "$D/agenda_gui.py" $1 >/dev/null 2>&1; fi; }
case "$1" in
  mini)    gui mini ;;
  agenda)  gui grand ;;
  meteo)   gui meteo ;;
  semaine) pop agenda-semaine "700 450" _semaine ;;
  nouveau) pop agenda-nouveau "750 200" _nouveau ;;
  _semaine) printf '\n  \e[1mLes 7 prochains jours\e[0m\n\n'; o=$(khal list today 7d 2>&1)
            [ -n "$o" ] && echo "$o" | sed 's/^/  /' || echo "  Aucun événement prévu."
            printf '\n  \e[2m(une touche pour fermer)\e[0m'; read -rsn1 ;;
  _nouveau) echo "Ex : 12/10 14:00 15:00 Dentiste   (ou : 12/10 Anniversaire)"; read -rp "> " e
            [ -n "$e" ] && khal new $e && echo "Ajouté ✓"; sleep 1.5 ;;
esac
