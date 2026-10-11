#!/usr/bin/env python3
# Barre d'ambiance Cava (Waybar) : style et couleur partagés avec la Cava liquide (bureau.conf)
# + info-bulle du morceau + lancement de la platine et de la Cava liquide au démarrage
import subprocess, json, time, html, os, sys, random, math
U = os.path.expanduser('~/.config/hypr/UserScripts')
ORIG = U + '/cava_orig_cmd'; CONF = U + '/bureau.conf'
if not os.path.exists(ORIG): sys.exit(1)
cmd = open(ORIG).read().strip()
sys.path.insert(0, U)
from CavaLiquide import conf, palette, melange, rgbhex   # mêmes réglages que la barre du bas

SRC = '▁▂▃▄▅▆▇█'
DOTS = [0x40, 0x04, 0x02, 0x01]          # points braille de la colonne gauche, du bas vers le haut
DOTS_D = [0x80, 0x20, 0x10, 0x08]        # colonne droite
# « SICA » en points, 4 points de haut (une lettre = 2 caractères braille)
MINI = {'S': ['11', '10', '01', '11'], 'I': ['1', '1', '1', '1'], 'C': ['11', '10', '10', '11'], 'A': ['01', '11', '11', '11']}


def braille(gauche, droite):
    """gauche/droite : nombre de points allumés (0…4) dans chaque colonne, du bas."""
    b = 0
    for k in range(gauche): b |= DOTS[k]
    for k in range(droite): b |= DOTS_D[k]
    return chr(0x2800 + b)


def lisse(niv):
    return [(niv[max(i - 1, 0)] + 2 * niv[i] + niv[min(i + 1, len(niv) - 1)]) / 4 for i in range(len(niv))]


def rendu(style, niv, t):
    """niv : niveaux 0…7 par colonne → texte du widget."""
    n = len(niv); r = random.random
    if style == 'blocs':  return ''.join(SRC[v] for v in niv)
    if style == 'fines':  return ''.join('▏▎▍▌▋▊▉█'[v] for v in niv)
    if style == 'ombre':  return ''.join(' ░░▒▒▓▓█'[v] for v in niv)
    if style == 'ondes':  return ''.join('_‗‗⁻⁻‾‾‾'[v] for v in niv)
    if style == 'liquide': return ''.join(SRC[round(v)] for v in lisse(lisse(niv)))
    if style == 'braille':
        return ''.join(braille(min(4, (niv[i] + 1) // 2), min(4, (niv[min(i + 1, n - 1)] + 1) // 2)) for i in range(n))
    if style == 'collines':
        s = lisse(niv)
        return ''.join(('⠁' if r() < 0.05 + v / 40 else '⠀') if v < 1.5 else braille(min(4, round(v / 2)), min(4, round(v / 2)))
                       for v in s)
    if style == 'pluie':
        return ''.join(random.choice('⠁⠂⠄⡀⠈⠐⠠⢀') if r() < v / 8 else '⠀' for v in niv)
    if style == 'bulles':
        return ''.join(('◯' if v > 5 else '○' if v > 3 else '∘') if r() < 0.15 + v / 10 else ' ' for v in niv)
    if style == 'sica':
        cols = []                                        # colonnes de points du mot (4 de haut)
        for li, ch in enumerate('SICA'):
            g = MINI[ch]
            for x in range(len(g[0])): cols.append([g[3 - y][x] == '1' for y in range(4)])
            if li < 3: cols.append([False] * 4)
        cells = (len(cols) + 1) // 2; debut = max(0, (n - cells) // 2); out = []
        for i in range(n):
            j = i - debut
            if 0 <= j < cells:
                b = 0; v = niv[i]
                for side, masks in ((0, DOTS), (1, DOTS_D)):
                    k = 2 * j + side
                    if k < len(cols):
                        for y in range(4):
                            if cols[k][y] and r() < 0.72 + v / 25: b |= masks[y]
                out.append(chr(0x2800 + b))
            else:
                out.append('⣀' if niv[i] > 4 else '⠀')
        return ''.join(out)
    return ''.join(SRC[v] for v in niv)


def colorer(txt, cs):
    if not cs: return html.escape(txt)
    if len(cs) == 1: return "<span color='%s'>%s</span>" % (rgbhex(cs[0]), html.escape(txt))
    n = max(1, len(txt) - 1)
    return ''.join("<span color='%s'>%s</span>" % (rgbhex(melange(cs, i / n)), html.escape(ch)) for i, ch in enumerate(txt))


def tip():
    try:
        o = subprocess.run(['playerctl', '-p', 'mpv,%any', 'metadata', '--format', '{{status}}\t{{artist}}\t{{title}}'],
                           capture_output=True, text=True, timeout=1).stdout.strip()
    except Exception:
        o = ''
    hint = '<small>Clic gauche : lecteur · Clic droit : pause · Molette : menu</small>'
    if not o: return 'Rien en lecture\n' + hint
    st, ar, ti = (o.split('\t') + ['', '', ''])[:3]
    line = ' – '.join(x for x in (ar, ti) if x) or 'Lecture en cours'
    return '%s  %s\n%s' % ('󰏤' if st == 'Paused' else '󰎆', html.escape(line), hint)


if __name__ == '__main__':
    c = conf()
    # lance la platine au démarrage si elle est activée
    if c.get('platine', 'on') == 'on':
        if subprocess.run(['pgrep', '-f', 'UserScripts/Platine.py'], capture_output=True).returncode != 0:
            subprocess.Popen(['python3', U + '/Platine.py'], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    # lance la Cava liquide (haut / bas) si elle est activée
    if c.get('cava_haut', 'off') == 'on' or c.get('cava_bas', 'off') == 'on':
        if subprocess.run(['pgrep', '-f', 'UserScripts/CavaLiquide.py'], capture_output=True).returncode != 0:
            subprocess.Popen(['python3', U + '/CavaLiquide.py'], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    chorus = lambda: subprocess.Popen(['python3', U + '/ChorusTheme.py'], start_new_session=True,
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    chorus()                                   # thème de Chorus aux couleurs de la Cava
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True, bufsize=1)
    t, last = tip(), time.time()
    mtime = -1; style = c['cava_style']; cs = palette(c, pour_waybar=True)
    for line in p.stdout:
        now = time.time()
        if now - last > 1:
            t, last = tip(), now
            try: m = (os.path.getmtime(CONF), os.path.getmtime(os.path.expanduser('~/.config/cava/config')))
            except OSError: m = 0                  # bureau.conf ou config cava (réécrite par Wallust) modifiée
            if m != mtime:
                mtime = m; cc = conf(); style = cc['cava_style']; cs = palette(cc, pour_waybar=True)
                chorus()
        niv = [SRC.index(ch) if ch in SRC else 0 for ch in line.rstrip('\n')]
        print(json.dumps({'text': colorer(rendu(style, niv, now), cs), 'tooltip': t}), flush=True)
