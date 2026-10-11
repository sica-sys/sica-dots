#!/usr/bin/env python3
# Bordure Cava : contour de la fenêtre active en dégradé aux couleurs de la Cava (menu Bureau),
# qui tourne (animation « borderangle » d'Hyprland) et/ou bat au rythme des basses.
# Réglage : bordure_cava = off | rotation | battement | les2   (bureau.conf, menu Bureau)
# Usage : CavaBordure.py            → démon (un seul à la fois)
#         CavaBordure.py --test     → applique une fois et affiche ce qu'Hyprland a retenu
import os, sys, time, subprocess, select, signal
U = os.path.expanduser('~/.config/hypr/UserScripts'); sys.path.insert(0, U)
from CavaLiquide import conf, palette, hexrgb

CONF = U + '/bureau.conf'
WALLUST = os.path.expanduser('~/.config/hypr/wallust/wallust-hyprland.conf')
PID = '/tmp/cava-bordure-%d.pid' % os.getuid()
HALO = 30                             # taille du halo autour de la fenêtre active (px)
CAVA_CONF = os.path.expanduser('~/.cache/cava-bordure.conf')
EPAISSEUR = 3                         # la bordure de base (1 px) est trop fine pour voir le battement

RESTAURE = '''
local home = os.getenv("HOME") or ""
local ok = pcall(dofile, home .. "/.config/hypr/UserConfigs/user_decorations.lua")
if not ok then pcall(dofile, home .. "/.config/hypr/lua/decorations.lua") end
'''


def hypr(lua):
    try:
        return subprocess.run(['hyprctl', 'eval', lua], capture_output=True, text=True, timeout=2).stdout
    except Exception:
        return ''


def hx(c, a=1.0):
    return 'rgba(%02x%02x%02x%02x)' % tuple(int(max(0, min(1, x)) * 255) for x in (*c, a))


def couleurs(m='les2'):
    cs = palette(conf(), pour_waybar=True) or [hexrgb('#c678dd')]
    if m == 'battement': return [cs[0], cs[0]]          # couleur unie : le dégradé ne se voit pas tourner
    if len(cs) == 1:                  # une seule couleur : clair → couleur → sombre, sinon la rotation ne se voit pas
        c = cs[0]; cs = [tuple(x + (1 - x) * 0.75 for x in c), c, tuple(x * 0.3 for x in c), c]
    return cs


def degrade(cs, b):
    """b = battement 0…1 (1 = pas de battement : couleurs pleines). Renvoie un HL.Gradient Lua."""
    out = []
    for c in cs:
        k = 0.25 + 0.75 * b; blanc = 0.45 * b * b
        out.append('"%s"' % hx(tuple(x * k + (1 - x * k) * blanc for x in c)))
    return '{ colors = { %s }, angle = 45 }' % ', '.join(out + [out[0]])


def poser(cs, b, epaisseur=None):
    """Bordure en dégradé + halo (ombre colorée de la fenêtre active) qui s'allume sur les basses."""
    g = degrade(cs, b)
    extra = (', border_size = %d' % epaisseur) if epaisseur else ''
    c = cs[1] if len(cs) > 1 else cs[0]
    c = tuple(x + (1 - x) * 0.35 * b * b for x in c)               # s'éclaircit sur les basses
    halo = hx(c, 0.55 + 0.45 * b)                                    # toujours visible, plein sur les basses
    return hypr('hl.config({ general = { col = { active_border = %s }%s }, '
                'decoration = { shadow = { enabled = true, range = %d, render_power = 1, color = "%s", '
                'color_inactive = "rgba(00000055)" } } })' % (g, extra, HALO, halo))


def rotation_on():
    """Garantit la rotation du dégradé, même si le preset d'animations choisi la coupe."""
    hypr('hl.curve("cavaLin", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } }) '
         'hl.animation({ leaf = "borderangle", enabled = true, speed = 40, bezier = "cavaLin", style = "loop" })')


def rapide():
    """Changement de couleur de bordure quasi instantané (certains presets le rendent très lent = battement invisible)."""
    hypr('hl.curve("cavaLin", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } }) '
         'hl.animation({ leaf = "border", enabled = true, speed = 0.5, bezier = "cavaLin" })')


def recharge():
    """Vrai si Hyprland a été rechargé (preset d'animations, reload…) : la bordure est revenue à la normale."""
    try:
        o = subprocess.run(['hyprctl', 'getoption', 'general:border_size'], capture_output=True, text=True, timeout=2).stdout
        return ('int: %d' % EPAISSEUR) not in o
    except Exception:
        return False


def mode():
    m = conf().get('bordure_cava', 'off')
    return m if m in ('rotation', 'battement', 'les2') else 'off'


def mtimes():
    r = []
    for f in (CONF, WALLUST):
        try: r.append(os.path.getmtime(f))
        except OSError: r.append(0)
    return r


def lancer_cava():
    os.makedirs(os.path.dirname(CAVA_CONF), exist_ok=True)
    open(CAVA_CONF, 'w').write('[general]\nbars = 8\nframerate = 30\nsleep_timer = 2\nlower_cutoff_freq = 40\nhigher_cutoff_freq = 4000\n'
                               '[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 1000\n')
    try:
        return subprocess.Popen(['cava', '-p', CAVA_CONF], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
    except FileNotFoundError:
        return None


def fin(*_):
    hypr(RESTAURE)
    try: os.remove(PID)
    except OSError: pass
    sys.exit(0)


def main():
    if '--test' in sys.argv:
        rapide(); rotation_on()
        print('eval :', poser(couleurs(), 1.0, EPAISSEUR).strip() or '(sans retour = OK)')
        for o in ('general:col.active_border', 'general:border_size', 'animations:enabled'):
            print(o, '→', subprocess.run(['hyprctl', 'getoption', o], capture_output=True, text=True).stdout.strip().replace('\n', ' | '))
        print('démon :', subprocess.run(['pgrep', '-af', 'CavaBordure'], capture_output=True, text=True).stdout.strip() or 'aucun')
        print('conf :', conf().get('bordure_cava'), '| couleurs :', degrade(couleurs(), 1.0))
        return
    try:                              # un seul démon
        old = int(open(PID).read())
        os.kill(old, signal.SIGTERM); time.sleep(0.3)
    except Exception:
        pass
    open(PID, 'w').write(str(os.getpid()))
    signal.signal(signal.SIGTERM, fin); signal.signal(signal.SIGINT, fin)

    m = mode()
    if m == 'off': fin()
    cs = couleurs(m); vu = mtimes()
    rapide()
    if m != 'battement': rotation_on()
    poser(cs, 1.0 if m == 'rotation' else 0.0, EPAISSEUR)
    cava = lancer_cava() if m != 'rotation' else None
    niv, envoye, calme, verif, pic = 0.0, -1.0, 0.0, time.time(), 0.15

    while True:
        now = time.time()
        if now - verif > 1:           # changement de réglage, de couleur ou de fond (Wallust réécrit la bordure)
            verif = now; mt = mtimes()
            if mt == vu and int(now) % 3 == 0 and recharge():
                mt = None                                             # force la remise en place
            if mt == vu and couleurs(m) != cs:                          # couleur changée sans toucher au fichier
                mt = None
            if mt != vu:
                vu = mtimes() if mt is None else mt; time.sleep(0.8)
                nm = mode()
                if nm != m:
                    if cava: cava.kill()
                    os.execv(sys.executable, [sys.executable] + sys.argv)
                rapide()
                if m != 'battement': rotation_on()
                cs = couleurs(m); poser(cs, 1.0 if m == 'rotation' else max(niv, 0.0), EPAISSEUR); envoye = -1
        if not cava:
            time.sleep(0.5); continue
        r, _, _ = select.select([cava.stdout], [], [], 0.5)
        if not r:
            if cava.poll() is not None: cava = lancer_cava(); time.sleep(1)
            continue
        line = cava.stdout.readline()
        if not line: continue
        try: v = [int(x) for x in line.strip().strip(';').split(';') if x]
        except ValueError: continue
        if not v: continue
        bass = min(1.0, (v[0] + v[1]) / 2000 * 1.3) if len(v) > 1 else v[0] / 1000
        pic = max(pic * 0.997, bass, 0.15)                            # gain auto : suit le volume
        bass = min(1.0, (bass / pic) ** 1.6)                          # contraste : les basses ressortent
        niv = bass if bass > niv else niv * 0.78 + bass * 0.22      # monte vite, redescend doucement
        calme = calme + 1 / 30 if niv < 0.03 else 0
        if calme > 2 and envoye <= 0.05: continue                     # silence : on n'envoie plus rien
        if abs(niv - envoye) > 0.04:
            poser(cs, niv); envoye = niv


if __name__ == '__main__':
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        import traceback
        open(os.path.expanduser('~/.cache/cava-bordure.log'), 'a').write(time.ctime() + '\n' + traceback.format_exc())
        time.sleep(2); os.execv(sys.executable, [sys.executable] + sys.argv)   # relance tout seul après une erreur
