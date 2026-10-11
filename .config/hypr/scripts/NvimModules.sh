#!/usr/bin/env bash
cfg="$HOME/.config/nvim/modules.conf"
themefile="$HOME/.config/nvim/colorscheme"
posfile="$HOME/.config/nvim/incline-pos"
rasi="$HOME/.config/hypr/rofi/config-kitty-theme.rasi"
menu() { local o=(-dmenu -i -p "$1"); [ -f "$rasi" ] && o+=(-config "$rasi"); rofi "${o[@]}"; }
declare -A def=( [which-key]=on [vim-be-good]=on [tips]=on [store]=on [yanky]=on [float-terminal]=on [showkeys]=off [neoscroll]=off [snacks-notifier]=on [snacks-scroll]=off [snacks-indent]=off [cellular-automaton]=on [duck]=on [bufferline]=on [incline]=on [oil]=on [table-mode]=on [snacks-input]=on [snacks-dim]=on [snacks-rename]=on [autopairs]=on [colorizer]=on [undotree]=on [image]=on [leetcode]=off [recherche]=on )
declare -A keys=( [which-key]="Espace puis attendre | Espace+?" [vim-be-good]="Espace+v+g" [tips]="astuce FR au demarrage" [store]="Espace+S" [yanky]="Espace+y" [float-terminal]="Espace+t | Ctrl+t ferme" [showkeys]="Espace+k" [neoscroll]="auto au defilement" [snacks-notifier]="auto | Espace+n historique" [snacks-scroll]="auto (comme neoscroll, pas les deux)" [snacks-indent]="auto" [cellular-automaton]="Espace+c+r pluie | Espace+c+g vie" [duck]="Espace+d+d canard | Espace+d+k retire" [bufferline]="barre du haut | Espace+b+l/h" [incline]="nom du fichier dans chaque fenetre" [oil]="Espace+o | - dossier parent" [table-mode]="Espace+T+n nouveau tableau" [snacks-input]="jolies fenetres de saisie" [snacks-dim]="Espace+Z | avec le zen Espace+z" [snacks-rename]="Espace+R renommer le fichier" [autopairs]="auto : ferme ( [ { \" en mode insertion" [colorizer]="auto : #hex en couleur | Espace+u+c" [undotree]="Espace+U historique d annulation" [image]="auto : images dans le Markdown (Kitty)" [leetcode]=":Leet exercices de code" [recherche]="Ctrl+F chercher dans le fichier" )
order=(which-key vim-be-good tips store yanky float-terminal showkeys neoscroll snacks-notifier snacks-scroll snacks-indent cellular-automaton duck bufferline incline oil table-mode snacks-input snacks-dim snacks-rename autopairs colorizer undotree image leetcode recherche)
themes=(default catppuccin-mocha catppuccin-macchiato catppuccin-frappe tokyonight-night tokyonight-storm tokyonight-moon rose-pine rose-pine-moon kanagawa-wave kanagawa-dragon)
get() { local v; v=$(grep -E "^$1=" "$cfg" 2>/dev/null | tail -1 | cut -d= -f2); echo "${v:-${def[$1]}}"; }
cur=$(cat "$themefile" 2>/dev/null || echo default)
pos=$(cat "$posfile" 2>/dev/null || echo top-right)
choice=$( { for m in "${order[@]}"; do printf '%-19s : %-3s -> basculer   [%s]\n' "$m" "$(get "$m")" "${keys[$m]}"; done; printf 'theme de couleurs   : %s -> choisir (%s)\n' "$cur" "${#themes[@]}"; printf 'position des noms   : %s -> choisir (4 coins)\n' "$pos"; } | menu "Modules Neovim")
[ -z "$choice" ] && exit 0
case "$choice" in
  theme*)
    pick=$(printf '%s\n' "${themes[@]}" | menu "Theme de couleurs Neovim")
    [ -z "$pick" ] && exit 0
    echo "$pick" > "$themefile"
    notify-send "Neovim" "Theme : $pick (au prochain lancement)"
    exit 0 ;;
  position*)
    pick=$(printf '%s\n' top-right top-left bottom-right bottom-left | menu "Position des noms de fenetre")
    [ -z "$pick" ] && exit 0
    echo "$pick" > "$posfile"
    notify-send "Neovim" "Position : $pick (au prochain lancement)"
    exit 0 ;;
esac
m=${choice%% *}
[ -z "${def[$m]}" ] && exit 0
[ "$(get "$m")" = on ] && new=off || new=on
touch "$cfg"; sed -i "/^$m=/d" "$cfg"; echo "$m=$new" >> "$cfg"
notify-send "Neovim" "$m : $new (au prochain lancement)"
[ "$new" = on ] && ( nvim --headless '+Lazy! install' +qa >/dev/null 2>&1 & )
