#!/usr/bin/env bash

record_dir="$HOME/Videos/Recordings"
mkdir -p "$record_dir"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send "🎥 Enregistrement" "⏹️ Enregistrement arrêté" -t 2500
    exit 0
fi

m=$(find "$record_dir" -name 'video-*.mp4' -printf '%f\n' 2>/dev/null | grep -oE '^video-[0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1); n=$(( 10#${m:-0} + 1 ))
file="$record_dir/video-$(printf '%02d' "$n")_$(date '+%d-%m_%Hh%M').mp4"     # ex. video-12_11-10_01h48.mp4

notify-send "🎥 Enregistrement" "▶️ Enregistrement démarré" -t 2500

wf-recorder -f "$file"

if [ -f "$file" ]; then
    notify-send "🎥 Enregistrement" "💾 Sauvegardé : $(basename "$file")" -t 3000
fi
