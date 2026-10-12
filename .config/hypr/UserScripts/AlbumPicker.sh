#!/usr/bin/env bash
# Grille Rofi : albums (dossiers) + « Tous les titres » (chaque son, avec recherche)
[ "$1" = "--cache" ] || { pkill -x rofi && exit 0; }
MUSIC="$(xdg-user-dir MUSIC 2>/dev/null)"; [ -d "$MUSIC" ] || MUSIC="$HOME/Music"
CACHE="$HOME/.cache/album-covers"; mkdir -p "$CACHE"
THEME="$HOME/.config/rofi/AlbumPicker.rasi"
AUDIO='.*\.(mp3|flac|ogg|opus|m4a|wav|webm|aac|wma|mka|alac|aiff?)$'
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

play() { # $1 = fichier playlist ou dossier
  pkill -f 'mpv.*--no-video' 2>/dev/null; sleep 0.2
  if [ -d "$1" ]; then setsid -f mpv --no-video --title=AlbumPicker "$1" >/dev/null 2>&1
  else setsid -f mpv --no-video --title=AlbumPicker --playlist="$1" >/dev/null 2>&1; fi
}

declare -A COV
for d in "${DIRS[@]}"; do COV["$d"]="$(cover_for "$d")"; done

tracks() {
  local FILES IDX f d pl
  mapfile -t FILES < <(find "$MUSIC" -type f -regextype posix-extended -iregex "$AUDIO" | sort -f)
  IDX=$(for f in "${FILES[@]}"; do
          d="${f%/*}"; n="${f##*/}"; n="${n%.*}"
          printf '%s   ·   %s\0icon\x1f%s\n' "$n" "${d##*/}" "${COV[$d]:-audio-x-generic}"
        done | rofi -dmenu -i -show-icons -format i -p "" -theme "$THEME" \
          -mesg "♪ ${#FILES[@]} titres — tape pour chercher · Échap : retour aux albums" \
          -theme-str 'window{width:900px;} listview{columns:1;lines:8;} element{orientation:horizontal;padding:6px 14px;spacing:14px;} element-icon{size:52px;} element-text{horizontal-align:0;vertical-align:0.5;} entry{placeholder:"Rechercher un titre";}')
  [ -z "$IDX" ] && return 1
  f="${FILES[$IDX]}"; d="${f%/*}"
  pl="/tmp/albumpicker-$UID.m3u"
  find "$d" -maxdepth 1 -type f -regextype posix-extended -iregex "$AUDIO" | sort | awk -v s="$f" '$0==s{go=1} go' > "$pl"
  play "$pl"
  local t="${f##*/}"; notify-send -i "${COV[$d]}" "▶ Lecture" "${t%.*}"
  return 0
}

while :; do
  IDX=$({ printf '%s\0icon\x1f%s\n' "♪  Tous les titres" "audio-x-generic"
          for d in "${DIRS[@]}"; do
            name="${d##*/}"; [ "$d" = "$MUSIC" ] && name="Titres en vrac"
            printf '%s\0icon\x1f%s\n' "$name" "${COV[$d]}"
          done; } | rofi -dmenu -i -show-icons -format i -p "" -theme "$THEME")
  [ -z "$IDX" ] && exit 0
  if [ "$IDX" = 0 ]; then tracks && exit 0; continue; fi
  DIR="${DIRS[$((IDX-1))]}"
  play "$DIR"
  notify-send -i "${COV[$DIR]}" "▶ Lecture" "${DIR##*/}"
  exit 0
done
