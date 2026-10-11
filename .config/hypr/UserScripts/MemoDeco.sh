#!/usr/bin/env bash
# Enregistre le flou et l'opacité actuels ; relus au démarrage et à chaque rechargement de Hyprland
g() { hyprctl -j getoption "$1" 2>/dev/null | jq -r '.bool // .int // .float // empty'; }
b=$(g decoration:blur:enabled); case "$b" in true|1) b=true ;; *) b=false ;; esac
cat > "$HOME/.local/state/deco-memo.lua" <<L
return { blur = { enabled = $b, size = $(g decoration:blur:size), passes = $(g decoration:blur:passes) },
         active_opacity = $(g decoration:active_opacity), inactive_opacity = $(g decoration:inactive_opacity) }
L
