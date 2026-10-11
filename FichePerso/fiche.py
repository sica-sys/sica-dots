#!/usr/bin/env python3
# Fiche perso (clic gauche sur le profil, Waybar) : prépare le style choisi aux couleurs Cava puis lance fastfetch.
import os, sys, json, re, subprocess, glob
F = os.path.expanduser('~/FichePerso'); U = os.path.expanduser('~/.config/hypr/UserScripts')
PHOTO = os.path.expanduser('~/.config/profil-card/photo.png')
sys.path.insert(0, U)
try:
    from CavaLiquide import conf, palette, melange, hexrgb
    CS = palette(conf(), pour_waybar=True) or [hexrgb('#c678dd')]
except Exception:
    CS = [(0.78, 0.47, 0.87)]
    def melange(cs, f): return cs[0]
if len(CS) == 1: CS = [CS[0], tuple(x + (1 - x) * 0.45 for x in CS[0])]


def sgr(c): return '38;2;%d;%d;%d' % tuple(int(max(0, min(1, x)) * 255) for x in c)


def textes():
    d = {}
    for l in open(F + '/textes.conf', encoding='utf-8'):
        if '=' in l and not l.lstrip().startswith('#'):
            k, v = l.rstrip('\n').split('=', 1); d[k.strip()] = v.strip()
    return d


def photos():
    """Copies arrondie et ronde de ta photo (refaites si la photo change)."""
    out = {}
    for nom, forme in (('arrondie', 'roundrectangle 0,0,599,599,90,90'), ('ronde', 'circle 300,300 300,0')):
        p = '%s/.cache/photo-%s.png' % (F, nom); out[nom] = p
        if os.path.exists(p) and os.path.getmtime(p) > os.path.getmtime(PHOTO): continue
        os.makedirs(F + '/.cache', exist_ok=True)
        try:
            w, h = map(int, subprocess.run(['identify', '-format', '%w %h', PHOTO], capture_output=True, text=True).stdout.split()[:2])
        except Exception:
            out[nom] = PHOTO; continue
        s = min(w, h)
        subprocess.run(['magick', PHOTO, '-gravity', 'center', '-crop', '%dx%d+0+0' % (s, s), '+repage', '-resize', '600x600!',
                        '(', '-size', '600x600', 'xc:none', '-fill', 'white', '-draw', forme, ')',
                        '-compose', 'DstIn', '-composite', p], capture_output=True)
        if not os.path.exists(p): out[nom] = PHOTO
    return out


def musique():
    try:
        o = subprocess.run(['playerctl', '-p', 'mpv,%any', 'metadata', '--format', '{{artist}} – {{title}}'],
                           capture_output=True, text=True, timeout=1).stdout.strip()
    except Exception:
        o = ''
    return o or 'rien en ce moment'


def esc(c): return '\033[%sm' % sgr(c)


def banniere(L, rendu, nb):
    """Affiche le gros pseudo au-dessus de la fiche, selon le rendu du style."""
    import shutil
    w = max(map(len, L)) or 1; cols = shutil.get_terminal_size((100, 30)).columns
    zone = min(cols, 72)                                # largeur de la fiche : on centre là-dedans
    centre = lambda l: ' ' * max(3, (zone - len(l)) // 2) if rendu in ('contour', 'arcade') else '   '
    marge = centre(L[0])
    sombre = tuple(x * 0.32 for x in CS[-1])
    print()
    if rendu == 'arcade':
        h = '1UP  SICA      HI-SCORE %03d      CREDIT 01' % nb
        print(centre(h) + '\033[%sm%s\033[0m' % (sgr(CS[-1]), h)); print()
    if rendu == 'ombre':                                   # ombre décalée d'une case vers le bas et la droite
        G = [l.ljust(w + 1) for l in L] + [' ' * (w + 1)]
        for r, l in enumerate(G):
            out = ''
            for c, ch in enumerate(l):
                if ch.strip(): out += esc(melange(CS, c / w)) + ch
                elif r > 0 and c > 0 and G[r - 1][c - 1].strip(): out += esc(sombre) + '▒'
                else: out += ' '
            print(marge + out + '\033[0m')
    else:
        for r, l in enumerate(L):
            if rendu == 'neon':                             # dégradé de haut en bas, en gras
                print(marge + '\033[1;%sm' % sgr(melange(CS, r / max(len(L) - 1, 1))) + l + '\033[0m')
            elif rendu in ('contour', 'arcade'):
                print(marge + '\033[1;%sm' % sgr(CS[0] if rendu == 'contour' else CS[-1]) + l + '\033[0m')
            else:                                           # dégradé de gauche à droite (style C)
                print(marge + ''.join(esc(melange(CS, i / w)) + ch for i, ch in enumerate(l)) + '\033[0m')
    if rendu == 'contour':
        t = textes(); e = t.get('EMOJI', '')
        trait = '━' * max(4, (w - len(e) - 4) // 2)
        print(marge + '\033[%sm%s  %s  %s\033[0m' % (sgr(CS[-1]), trait, e, trait))
    print()


def main():
    choix = (open(F + '/choix.txt').read().strip() or 'C')[0].upper()
    st = (glob.glob('%s/styles/%s-*.jsonc' % (F, choix)) or glob.glob(F + '/styles/C-*.jsonc'))[0]
    t = textes(); ph = photos()
    nb = len([f for f in glob.glob(U + '/**/*', recursive=True)
              if f.endswith(('.sh', '.py')) and '.bak' not in f and '__pycache__' not in f and '/clips/' not in f])
    pal = ''.join('{#%s}███{#}' % sgr(melange(CS, i / 7)) for i in range(8))
    mini = ''.join('{#%s}%s{#}' % (sgr(melange(CS, i / 6)), ch) for i, ch in enumerate('▂▄▆█▆▄▂'))
    rep = {'C1': sgr(CS[0]), 'C2': sgr(CS[-1]), 'PALETTE': pal, 'MINICAVA': mini, 'NB': str(nb),
           'MUSIQUE': musique(), 'PHOTO_ARRONDIE': ph['arrondie'], 'PHOTO_RONDE': ph['ronde']}
    rep.update(t)
    s = open(st, encoding='utf-8').read()
    s = re.sub(r'@([A-Z_0-9]+)@', lambda m: json.dumps(rep.get(m.group(1), ''), ensure_ascii=False)[1:-1], s)
    tmp = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'fiche-perso.jsonc')
    open(tmp, 'w', encoding='utf-8').write(s)
    meta = dict(re.findall(r'^//\s*(banniere|rendu):\s*(\S+)', open(st, encoding='utf-8').read(), re.M))
    if choix == 'C': meta.setdefault('banniere', 'sica.txt'); meta.setdefault('rendu', 'degrade')
    ban = os.path.join(F, meta.get('banniere', ''))
    if meta.get('banniere') and os.path.isfile(ban):
        banniere(open(ban, encoding='utf-8').read().rstrip('\n').split('\n'), meta.get('rendu', 'degrade'), nb)
    sys.stdout.flush()
    os.execvp('fastfetch', ['fastfetch', '-c', tmp])


if __name__ == '__main__':
    main()
