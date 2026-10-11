# sica-dots — Hyprland, une seule couleur

> 🇬🇧 English below

Ma config Hyprland, construite par-dessus les **KooL's Hyprland dots** de **JaKooLit** et **LinuxBeginnings**.
L'idée : **une seule couleur, la « couleur Cava »**. Tout le bureau la suit : la barre, les bordures, les menus, les notifications et le terminal. Elle peut venir du fond d'écran, d'une pipette ou de ta propre liste.

![Aperçu](screenshots/apercu.png)


🎬 **Vidéo de présentation** : *[r/LinuxPorn](https://www.reddit.com/r/LinuxPorn/comments/1x39gya/hyprland_my_first_rice_everything_follows_one/)*

## Ce qu'il y a dedans

| | |
|---|---|
| 🎨 **Couleur Cava** | Une couleur pour tout : lue dans le fond d'écran, prise à la pipette, tapée en `#hex` ou choisie dans « ★ Mes couleurs » |
| 🌊 **Cava liquide** | Visualiseur audio en haut et en bas de l'écran, 10 styles (blocs, braille, liquide, SICA géant…) |
| 🔲 **Bordure Cava** | La bordure des fenêtres bat avec la musique |
| 🖼️ **Carrousel de fonds** | Sélecteur de fonds d'écran animé (Super+W) + **Effets +** (pixel art, teinte Cava…) |
| 💿 **Platine** | Platine vinyle sur le bureau, 4 styles : classique, verre, néon, pochette |
| 🎵 **Musique** | Grille de pochettes d'albums, fenêtre « en cours de lecture », RofiBeats |
| 🪟 **Rofi en verre** | Thèmes `Cava-Verre-violet` et `Cava-Verre-opaque` qui suivent la couleur |
| ❓ **Aide-mémoire FR** | Tous les raccourcis en français (Super+H) |
| 🎬 **Démos vidéo** | Clips automatiques de la config, enregistrés et floutés (Super+Alt+Z) |
| 🫥 **Flou des vidéos** | Super+Alt+F pendant l'enregistrement, ou après coup, plusieurs passages d'un coup |
| 🐱 **Kitty** | Shaders, thèmes à la volée |
| 📝 **Neovim** | Dashboards, modules, Ctrl+F |
| 🪪 **Fiche perso** | Fiche de présentation dans le terminal, 7 styles |

## Installation

1. Installe d'abord les **KooL's Hyprland dots** : <https://github.com/JaKooLit/Hyprland-Dots>
2. Puis :
   ```bash
   git clone https://github.com/<ton-pseudo>/sica-dots ~/sica-dots
   cd ~/sica-dots && ./install.sh
   ```
   Tes fichiers actuels sont sauvegardés dans `~/.local/state/sica-dots-sauvegarde-…` avant d'être remplacés.

**Dépendances** : `python3-gi`, `gtk-layer-shell`, `cava`, `imagemagick`, `ffmpeg`, `wf-recorder`, `grim`, `slurp`, `hyprpicker`, `playerctl`, `mpv`, `jq`, Kitty ≥ 0.49 (pour les shaders).

## Raccourcis principaux

| Touches | Action |
|---|---|
| Super+H | Aide-mémoire (tous les raccourcis) |
| Super+W | Carrousel de fonds d'écran |
| Super+Shift+W | Effets + |
| Clic molette sur la Cava | Menu Bureau (couleur, style, platine…) |
| Super+Ctrl+R | Thème Rofi |
| Super+Alt+Z | Démos vidéo |
| Super+Alt+F | Flouter un passage de la vidéo |

## Crédits

- **JaKooLit** et **LinuxBeginnings** : les [KooL's Hyprland dots](https://github.com/JaKooLit/Hyprland-Dots), la base de tout
- Hyprland, Waybar, Rofi, Kitty, Cava, Wallust et leurs développeurs

---

## 🇬🇧 English

My Hyprland rice, built on top of **KooL's Hyprland dots** by **JaKooLit** & **LinuxBeginnings**.
The idea: **one color, the "Cava color"**. The whole desktop follows it: bar, borders, menus, notifications and terminal. It can come from the wallpaper, an eyedropper or your own list.

**Features**: liquid Cava visualizer (10 styles) · Cava border pulsing with music · animated wallpaper carousel + Effects+ · desktop turntable (4 styles) · album grid & now-playing window · glass Rofi themes following the color · French cheat sheet (Super+H) · automatic demo clips with recording & blur · Kitty shaders · Neovim dashboards · terminal profile card.

**Install**: install KooL's Hyprland dots first, then `git clone` this repo and run `./install.sh` (your current files are backed up first).

**Credits**: JaKooLit & LinuxBeginnings for [KooL's Hyprland dots](https://github.com/JaKooLit/Hyprland-Dots).
