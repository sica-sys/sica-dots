#!/usr/bin/env python3
# Contour des notifications (swaync) à la couleur de la Cava (« Couleur Cava » du menu Bureau).
# + la couleur de cava lancé dans le terminal (~/.config/cava/config). Ne touche plus du tout à Chorus.
import os, sys, subprocess
U = os.path.expanduser('~/.config/hypr/UserScripts'); sys.path.insert(0, U)
from CavaLiquide import conf, palette, rgbhex, hexrgb, melange

SWAYNC = os.path.expanduser('~/.config/swaync/style.css')
MARQUE = '/* ===== Verre (ajout)'


def degrade(cs, a):
    if len(cs) == 1:
        return 'linear-gradient(90deg, alpha(%s, %.2f), alpha(%s, %.2f))' % (cs[0], a, cs[0], a * 0.35)
    return 'linear-gradient(90deg, %s)' % ', '.join('alpha(%s, %.2f)' % (h, a) for h in cs)


def swaync(cs):
    """Réécrit le bloc Verre de swaync (s'il existe) avec la couleur de la Cava."""
    try: s = open(SWAYNC, encoding='utf-8').read()
    except Exception: return
    if MARQUE not in s: return
    c1 = cs[0]; grad = degrade(cs, 0.85) if len(cs) > 1 else 'none'
    b = '''/* ===== Verre (ajout) — notifications, contour à la couleur de la Cava (réécrit par ChorusTheme.py) ===== */
.notification-row .notification-background .notification, .notification {
  background: rgba(21, 18, 31, 0.84); border: 2px solid %(c1)s;
  border-radius: 14px; color: #f4f1ff; box-shadow: none; }
.notification .summary { color: #f4f1ff; font-weight: bold; }
.notification .body, .notification .time { color: #b9b2d6; }
.notification-default-action:hover, .notification-action:hover { background: alpha(%(c1)s, 0.18); }
.close-button { background: %(c1)s; color: #1b1029; border-radius: 50%%; }
.control-center { background: rgba(21, 18, 31, 0.86); border: 2px solid %(c1)s; border-radius: 16px; color: #f4f1ff; }
.control-center .notification-row .notification-background { background: transparent; }
.widget-title > button, .widget-dnd > switch:checked { background: %(c1)s; background-image: %(grad)s; color: #1b1029; }
progressbar progress { background: %(c1)s; background-image: %(grad)s; }
''' % {'c1': c1, 'grad': grad}
    neuf = s[:s.index(MARQUE)].rstrip('\n') + '\n\n' + b
    if neuf != s:
        open(SWAYNC, 'w', encoding='utf-8').write(neuf)
        subprocess.run(['swaync-client', '-rs'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


CAVA = os.path.expanduser('~/.config/cava/config')
DEB, FIN = '# >>> Couleur Cava (menu Bureau)', '# <<< Couleur Cava'


def cava_terminal():
    """cava du terminal : même couleur que la Cava (dégradé bas → haut). En mode wallust, on rend la main à Wallust."""
    try: s = open(CAVA, encoding='utf-8').read()
    except Exception: return
    lignes = s.split('\n'); out = []; dans = False
    for l in lignes:                                   # retire notre ancien bloc et réactive les lignes Wallust
        if l.startswith(DEB): dans = True; continue
        if l.startswith(FIN): dans = False; continue
        if dans: continue
        out.append(l[3:] if l.startswith(';W ') else l)
    c = conf()
    if c.get('cava_couleur', 'wallust') != 'sombre':               # wallust = couleur lue dans le fond d'écran
        cs = palette(c, pour_waybar=True) or [hexrgb('#c678dd')]
        if len(cs) == 1:                               # une couleur : sombre en bas → couleur → clair en haut
            x = cs[0]; cs = [tuple(v * 0.35 for v in x), x, tuple(v + (1 - v) * 0.6 for v in x)]
        bloc = [DEB, 'gradient = 1', 'gradient_count = 8'] + \
               ["gradient_color_%d = '%s'" % (i + 1, rgbhex(melange(cs, i / 7))) for i in range(8)] + [FIN]
        res, mis, sect = [], False, ''
        for l in out:
            t = l.strip()
            if t.startswith('['): sect = t
            if sect == '[color]' and t.split('=')[0].strip() in ('gradient', 'gradient_count', 'foreground') or \
               (sect == '[color]' and t.startswith('gradient_color_')):
                res.append(';W ' + l); continue        # ligne Wallust mise de côté (restaurée en mode wallust)
            res.append(l)
            if t == '[color]' and not mis: res += bloc; mis = True
        out = res
    neuf = '\n'.join(out)
    if neuf != s:
        open(CAVA, 'w', encoding='utf-8').write(neuf)
        subprocess.run(['pkill', '-USR2', '-x', 'cava'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


ROFI_THEMES = os.path.expanduser('~/.config/hypr/rofi/themes')


def rgba(h, a):
    h = h.lstrip('#'); return 'rgba(%d, %d, %d, %.2f)' % (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


def themes_rofi(cs):
    """Deux thèmes Rofi qui suivent la couleur Cava (choisis avec Super+Ctrl+R) : Cava-Verre-violet et Cava-Verre-opaque."""
    if not os.path.isdir(ROFI_THEMES): return
    c1, c2 = cs[0], cs[-1]
    commun = """configuration { show-icons: true; }
* { font: "JetBrainsMono Nerd Font 12"; text-color: #ece6ff; background-color: transparent; }
window { width: 560px; border-radius: 16px; padding: 14px; %(win)s }
mainbox { spacing: 10px; children: [ inputbar, listview ]; }
inputbar { padding: 9px 12px; border-radius: 10px; spacing: 8px; children: [ prompt, entry ]; %(inp)s }
prompt { text-color: %(c1)s; }
entry { placeholder: "Rechercher…"; placeholder-color: #8a85a8; }
listview { lines: 8; columns: 1; spacing: 4px; scrollbar: false; fixed-height: false; }
element { padding: 8px 10px; border-radius: 9px; spacing: 10px; }
element-icon { size: 22px; }
element-text { vertical-align: 0.5; }
element selected.normal, element selected.active { %(sel)s }
element-text selected { text-color: %(selt)s; }
"""
    violet = commun % {
        'c1': c1,
        'win': 'background-color: rgba(70, 40, 110, 0.42); border: 2px solid; border-color: %s;' % rgba(c1, 0.85),
        'inp': 'background-color: rgba(255, 255, 255, 0.07);',
        'sel': 'background-color: %s; border: 1px solid; border-color: %s;' % (rgba(c1, 0.35), c1),
        'selt': '#ffffff'}
    grad = ', '.join(cs) if len(cs) > 1 else '%s, %s' % (c1, c1)
    opaque = commun % {
        'c1': c1,
        'win': 'background-color: rgba(14, 12, 24, 0.88); border: 2px solid; border-color: %s;' % c1,
        'inp': 'background-color: %s; border: 1px solid; border-color: %s;' % (rgba(c1, 0.10), rgba(c1, 0.40)),
        'sel': 'background-color: %s; background-image: linear-gradient(to right, %s);' % (c1, grad),
        'selt': '#0b0f18'}
    for nom, txt in (('Cava-Verre-violet.rasi', violet), ('Cava-Verre-opaque.rasi', opaque)):
        p = os.path.join(ROFI_THEMES, nom)
        try:
            if not os.path.exists(p) or open(p).read() != txt: open(p, 'w').write(txt)
        except Exception:
            pass


ALBUM = os.path.expanduser('~/.config/rofi/AlbumPicker-cava.rasi')   # hors de ~/.config/hypr (pas de rechargement auto)


def theme_albums(cs):
    """Menu des albums (AlbumPicker.sh) : grille de pochettes, contour et sélection à la couleur Cava."""
    c1 = cs[0]; grad = ', '.join(cs) if len(cs) > 1 else '%s, %s' % (c1, c1)
    txt = """* { font: "JetBrainsMono Nerd Font 11"; text-color: #ece6ff; background-color: transparent; }
window { width: 1000px; border-radius: 18px; padding: 16px; location: center;
         background-color: rgba(14, 12, 24, 0.82); border: 2px solid; border-color: %(c1)s; }
mainbox { spacing: 14px; children: [ inputbar, listview ]; }
inputbar { padding: 9px 14px; border-radius: 10px; children: [ entry ];
           background-color: %(fin)s; border: 1px solid; border-color: %(bord)s; }
entry { placeholder: "Rechercher un album…"; placeholder-color: #8a85a8; }
listview { columns: 5; lines: 2; spacing: 10px; scrollbar: false; fixed-columns: true; }
element { orientation: vertical; padding: 10px; border-radius: 12px; spacing: 8px; }
element-icon { size: 140px; horizontal-align: 0.5; }
element-text { horizontal-align: 0.5; vertical-align: 0.5; }
element selected.normal, element selected.active { background-color: %(sel)s; border: 2px solid; border-color: %(c1)s; }
element-text selected { text-color: #ffffff; }
""" % {'c1': c1, 'fin': rgba(c1, 0.10), 'bord': rgba(c1, 0.40), 'sel': rgba(c1, 0.28)}
    try:
        os.makedirs(os.path.dirname(ALBUM), exist_ok=True)
        if not os.path.exists(ALBUM) or open(ALBUM).read() != txt: open(ALBUM, 'w').write(txt)
    except Exception:
        pass


def main():
    cs = [rgbhex(c) for c in (palette(conf(), pour_waybar=True) or [hexrgb('#c678dd')])]
    swaync(cs)
    cava_terminal()
    themes_rofi(cs)
    theme_albums(cs)


if __name__ == '__main__':
    main()
