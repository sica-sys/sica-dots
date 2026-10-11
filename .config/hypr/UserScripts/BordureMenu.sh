#!/usr/bin/env bash
# Sous-menu « Bordure Cava » (ouvert depuis le menu Animations, Super+Shift+A)
U="$HOME/.config/hypr/UserScripts"; CONF="$U/bureau.conf"
rasi="$HOME/.config/hypr/rofi/config-Animations.rasi"
get() { local v; v=$(grep -E "^$1=" "$CONF" 2>/dev/null | tail -1 | cut -d= -f2-); echo "${v:-$2}"; }
o=(-dmenu -i -p "Bordure Cava"); [ -f "$rasi" ] && o+=(-config "$rasi")
m=$(printf '%s\n' "les2       rotation + battement" "rotation   le dégradé tourne" "battement  pulse avec les basses" "off        bordure normale" \
  | rofi "${o[@]}" -mesg "Actuel : $(get bordure_cava off) · couleur = Couleur Cava (menu Bureau)")
[ -z "$m" ] && exit 0
m=${m%% *}; touch "$CONF"; sed -i '/^bordure_cava=/d' "$CONF"; echo "bordure_cava=$m" >> "$CONF"
pkill -f 'UserScripts/CavaBordure.py' 2>/dev/null; sleep 0.4
if [ "$m" = off ]; then
  hyprctl eval 'local h=os.getenv("HOME") or ""; if not pcall(dofile, h.."/.config/hypr/UserConfigs/user_decorations.lua") then pcall(dofile, h.."/.config/hypr/lua/decorations.lua") end' >/dev/null 2>&1
else
  setsid -f python3 "$U/CavaBordure.py" >/dev/null 2>&1
fi
notify-send "Bordure Cava" "$m"
