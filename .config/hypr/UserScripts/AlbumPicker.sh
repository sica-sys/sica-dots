#!/usr/bin/env bash
[ "$1" = "--cache" ] || { pkill -x rofi && exit 0; }
MUSIC="$(xdg-user-dir MUSIC 2>/dev/null)"; [ -d "$MUSIC" ] || MUSIC="$HOME/Music"
CACHE="$HOME/.cache/album-covers"; mkdir -p "$CACHE"
AUDIO='.*\.(mp3|flac|ogg|opus|m4a|wav|webm|aac)$'
mapfile -t DIRS < <(find "$MUSIC" -type f -regextype posix-extended -iregex "$AUDIO" -printf '%h\n' | sort -u)
[ ${#DIRS[@]} -eq 0 ] && { notify-send "AlbumPicker" "Aucune musique dans $MUSIC"; exit 1; }
cover_for() { # $2=1 : autorise la recherche en ligne
  local d="$1" out img f q url
  out="$CACHE/$(printf '%s' "$d" | md5sum | cut -c1-16).jpg"
  [ -s "$out" ] && { echo "$out"; return; }
  img=$(find "$d" -maxdepth 1 -type f -regextype posix-extended -iregex '.*\.(jpe?g|png|webp)$' | sort | head -1)
  [ -n "$img" ] && ffmpeg -loglevel quiet -y -i "$img" -vf scale=300:-1 "$out"
  if [ ! -s "$out" ]; then
    while IFS= read -r f; do
      ffmpeg -loglevel quiet -y -i "$f" -an -frames:v 1 -vf scale=300:-1 "$out" && [ -s "$out" ] && break
    done < <(find "$d" -maxdepth 1 -type f -regextype posix-extended -iregex "$AUDIO" | head -5)
  fi
  if [ ! -s "$out" ] && [ "$2" = 1 ] && [ ! -e "$out.none" ]; then
    q=$(basename "$d" | tr '_' ' ')
    url=$(curl -s -G https://itunes.apple.com/search --data-urlencode "term=$q" -d entity=album -d limit=1 | python3 -c 'import sys,json;r=json.load(sys.stdin)["results"];print(r[0]["artworkUrl100"].replace("100x100","600x600") if r else "")' 2>/dev/null)
    [ -n "$url" ] && curl -s "$url" -o "$out"
    [ -s "$out" ] || touch "$out.none"
  fi
  [ -s "$out" ] && echo "$out" || echo "audio-x-generic"
}
if [ "$1" = "--cache" ]; then
  n=0; for d in "${DIRS[@]}"; do cover_for "$d" 1 >/dev/null; n=$((n+1)); printf '\rPochettes : %d/%d' $n ${#DIRS[@]} >&2; done; echo >&2; exit 0
fi
THEME=~/.config/rofi/AlbumPicker-cava.rasi; [ -f "$THEME" ] || THEME=~/.config/rofi/AlbumPicker.rasi   # couleur Cava
IDX=$(for d in "${DIRS[@]}"; do
  name="$(basename "$d")"; [ "$d" = "$MUSIC" ] && name="Titres en vrac"
  printf '%s\0icon\x1f%s\n' "$name" "$(cover_for "$d")"
done | rofi -dmenu -i -show-icons -format i -p "" -theme "$THEME")
[ -z "$IDX" ] && exit 0
DIR="${DIRS[$IDX]}"
pkill -f 'mpv.*--no-video' 2>/dev/null; sleep 0.2
setsid -f mpv --no-video --title=AlbumPicker "$DIR" >/dev/null 2>&1
notify-send -i "$(cover_for "$DIR")" "▶ Lecture" "$(basename "$DIR")"
