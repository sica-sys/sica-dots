#!/usr/bin/env bash
# Installe sica-dots par-dessus KooL's Hyprland dots. Tes fichiers actuels sont sauvegardés avant.
set -e
D="$(cd "$(dirname "$0")" && pwd)"
[ -d "$HOME/.config/hypr/UserScripts" ] || { echo "Installe d'abord KooL's Hyprland dots (JaKooLit) : https://github.com/JaKooLit/Hyprland-Dots"; exit 1; }
B="$HOME/.local/state/sica-dots-sauvegarde-$(date +%Y%m%d-%H%M%S)"
cd "$D"
find .config FichePerso -type f 2>/dev/null | while read -r f; do
  if [ -e "$HOME/$f" ]; then mkdir -p "$B/$(dirname "$f")"; cp -a "$HOME/$f" "$B/$f"; fi
  mkdir -p "$HOME/$(dirname "$f")"; cp -a "$f" "$HOME/$f"
done
find "$HOME/.config/hypr/UserScripts" "$HOME/.config/hypr/scripts" "$HOME/FichePerso" -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2>/dev/null
[ -f "$HOME/FichePerso/textes.conf" ] || cp "$HOME/FichePerso/textes.exemple.conf" "$HOME/FichePerso/textes.conf" 2>/dev/null || true
echo "✓ sica-dots installé. Ancienne config sauvegardée dans : $B"
command -v hyprctl >/dev/null && hyprctl reload >/dev/null
