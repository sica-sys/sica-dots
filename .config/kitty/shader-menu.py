#!/usr/bin/env python3

import curses
import json
import subprocess
import sys


KITTY = "/home/hote/.local/kitty.app/bin/kitten"


SHADERS = [
    ("Désactiver", None),

    ("── CURSEUR ──", "header"),
    ("🔥 Blaze", "cursor-trail-blaze"),
    ("⚡ Lightning", "cursor-trail-lightning"),

    ("── ARRIÈRE-PLANS ANIMÉS ──", "header"),
    ("🟩 Inside the Matrix", "inside-the-matrix"),
    ("🌌 Northern Lights", "northern-lights"),
    ("🎆 Fireworks", "fireworks"),
    ("🚀 Fireworks Rockets", "fireworks-rockets"),
    ("🌊 Water", "water"),
    ("🌊 Underwater", "underwater"),

    ("── EFFETS ──", "header"),
    ("💧 Pond Ripple", "pond-ripple"),
    ("🔦 Spotlight", "spotlight"),
    ("✨ Bloom", "bloom"),
    ("🎯 Focus Highlight", "focus-highlight"),
    ("🌑 Dim Inactive Windows", "dim-inactive-windows"),
    ("🔄 Tab Change", "tab-change"),
    ("🚫 Negative", "negative"),

    ("── TERMINAUX RÉTRO ──", "header"),
    ("📺 CRT", "crt"),
    ("🔵 CRT Blue", "crt-blue"),
    ("📺 TFT", "tft"),

    ("── COMBINAISONS ──", "header"),
    ("🟩 Matrix + 🔥 Blaze", "matrix-blaze"),
    ("🌌 Northern Lights + ⚡ Lightning", "northern-lights-lightning"),
    ("📺 CRT + 🔦 Spotlight", "crt-spotlight"),
]


def apply_shader(shader):
    """
    Applique le shader à la fenêtre Kitty qui a lancé le kitten.

    On utilise kitten @ load-config uniquement pour l'application
    du choix final. Le menu lui-même reste entièrement intégré
    dans le kitten.
    """
    config_dir = "/home/hote/.config/kitty"
    temp_file = f"{config_dir}/shader-menu/.active-shader.conf"

    if shader is None:
        content = "custom_shaders\n"
    elif shader in {
        "matrix-blaze",
        "northern-lights-lightning",
        "crt-spotlight",
    }:
        content = f"custom_shaders {shader}\n"
    else:
        content = f"custom_shaders {shader}\n"

    with open(temp_file, "w", encoding="utf-8") as f:
        f.write(content)

    result = subprocess.run(
        [
            KITTY,
            "@",
            "load-config",
            "--no-response",
            temp_file,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )

    return result.returncode == 0, result.stderr


def draw_menu(stdscr):
    curses.curs_set(0)
    stdscr.keypad(True)

    selected = 0

    while True:
        stdscr.erase()

        height, width = stdscr.getmaxyx()

        visible = [
            item for item in SHADERS
            if item[1] != "header"
        ]

        # On construit l'affichage avec les headers conservés.
        rows = SHADERS

        title = "🎨  KITTY CUSTOM SHADERS  🎨"
        subtitle = "↑ ↓ naviguer   •   Entrée appliquer   •   Échap quitter"

        try:
            stdscr.addstr(
                1,
                max(0, (width - len(title)) // 2),
                title,
                curses.A_BOLD,
            )
            stdscr.addstr(
                2,
                max(0, (width - len(subtitle)) // 2),
                subtitle,
            )
        except curses.error:
            pass

        y = 4
        selectable_index = 0

        selectable_positions = []

        for label, value in rows:
            if value == "header":
                try:
                    stdscr.addstr(
                        y,
                        3,
                        label,
                        curses.A_BOLD,
                    )
                except curses.error:
                    pass
                y += 1
                continue

            selectable_positions.append((y, selectable_index))

            prefix = "▶ " if selectable_index == selected else "  "

            attr = curses.A_REVERSE if selectable_index == selected else curses.A_NORMAL

            try:
                stdscr.addstr(
                    y,
                    4,
                    prefix + label,
                    attr,
                )
            except curses.error:
                pass

            selectable_index += 1
            y += 1

            if y >= height - 2:
                break

        key = stdscr.getch()

        if key in (27, ord("q")):
            return None

        if key in (curses.KEY_UP, ord("k")):
            selected = (selected - 1) % len(visible)

        elif key in (curses.KEY_DOWN, ord("j")):
            selected = (selected + 1) % len(visible)

        elif key in (curses.KEY_ENTER, 10, 13):
            return visible[selected][1]


def main():
    try:
        selected = curses.wrapper(draw_menu)

        if selected is None:
            return ""

        ok, error = apply_shader(selected)

        if not ok:
            print(f"Erreur lors de l'application du shader:\n{error}", file=sys.stderr)
            return ""

        return ""

    except KeyboardInterrupt:
        return ""


if __name__ == "__main__":
    main()
