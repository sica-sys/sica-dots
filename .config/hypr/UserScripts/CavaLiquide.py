#!/usr/bin/env python3
# Cava liquide : forme qui coule sous la Waybar (haut) + barre Cava en bas de l'écran.
# Style et couleur partagés avec le widget Cava de la Waybar (CavaTooltip.py).
# Réglages dans bureau.conf, via le menu Bureau (clic molette sur la barre d'ambiance).
import os, sys, signal, subprocess, math, time, re, glob, fcntl, random

HOME = os.path.expanduser('~'); U = HOME + '/.config/hypr/UserScripts'
CONF = U + '/bureau.conf'
PID = '/tmp/cava-liquide-%d.pid' % os.getuid()
CAVA_CONF = HOME + '/.cache/cava-liquide.conf'
NB = 48                                   # nombre de bandes demandées à cava
TOP_W, TOP_H = 620, 150                   # zone de la goutte du haut
HAUTEURS = {'petite': 70, 'moyenne': 110, 'grande': 160}
STYLES = ['blocs', 'braille', 'ondes', 'fines', 'ombre', 'liquide', 'bulles', 'sica', 'collines', 'pluie']
COULEURS = {'vert': '#39ff6a', 'rose': '#c678dd', 'bleu': '#4f9cf9', 'turquoise': '#56d6c0',
            'corail': '#f0997b', 'or': '#f5c66d', 'blanc': '#e8e6f0'}
DEGRADE = ['#4f9cf9', '#c678dd', '#f0997b']
WALLUST_FICHIERS = ['~/.config/hypr/waybar/wallust/*', '~/.config/waybar/wallust/*', '~/.config/rofi/wallust/*',
                    '~/.config/hypr/wallust/*', '~/.config/kitty/kitty-themes/*wallust*', '~/.cache/wal/colors.json']
POLICE = {'S': ['01111', '10000', '10000', '01110', '00001', '00001', '11110'],
          'I': ['11111', '00100', '00100', '00100', '00100', '00100', '11111'],
          'C': ['01111', '10000', '10000', '10000', '10000', '10000', '01111'],
          'A': ['01110', '10001', '10001', '11111', '10001', '10001', '10001']}
MOT = 'SICA'


# ---------------------------------------------------------------- réglages et couleurs
def conf():
    d = {'cava_haut': 'off', 'cava_bas': 'off', 'cava_couleur': 'wallust', 'cava_opacite': '90',
         'cava_style': 'blocs', 'cava_bas_hauteur': 'moyenne'}
    try:
        for l in open(CONF, encoding='utf-8'):
            if '=' in l:
                k, v = l.strip().split('=', 1); d[k] = v
    except Exception:
        pass
    if d['cava_style'] not in STYLES:
        d['cava_style'] = {'vague': 'liquide'}.get(d['cava_style'], 'blocs')
    return d


def hexrgb(h):
    h = h.strip().lstrip('#')
    if not re.fullmatch(r'[0-9a-fA-F]{6}', h): return None
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def rgbhex(c):
    return '#%02x%02x%02x' % tuple(int(max(0, min(1, x)) * 255) for x in c)


def wallust():
    """Couleurs générées par Wallust (le fichier le plus récent trouvé)."""
    fichiers = []
    for motif in WALLUST_FICHIERS:
        fichiers += [f for f in glob.glob(os.path.expanduser(motif)) if os.path.isfile(f)]
    fichiers.sort(key=lambda f: os.path.getmtime(f), reverse=True)
    for f in fichiers:
        try: s = open(f, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        d = {}
        for k, v in re.findall(r'(color\d{1,2}|background|foreground)\W{1,6}(#[0-9a-fA-F]{6})\b', s):
            d.setdefault(k.lower(), v)
        if len(d) >= 4: return d, f
    return {}, None


def palette(c, pour_waybar=False):
    """Liste de couleurs (r, g, b) : une seule = uni, plusieurs = dégradé de gauche à droite.
    None = garder la couleur par défaut (le mode « sombre » dans la Waybar serait invisible)."""
    choix = c.get('cava_couleur', 'wallust')
    if choix.startswith('grad:'):
        cs = [hexrgb(x) for x in choix[5:].split(',')]
        cs = [x for x in cs if x]
        if len(cs) >= 2: return cs
    if choix == 'degrade': return [hexrgb(x) for x in DEGRADE]
    if choix.startswith('#') and hexrgb(choix): return [hexrgb(choix)]
    if choix in COULEURS: return [hexrgb(COULEURS[choix])]
    w, _ = wallust()
    if choix == 'sombre':
        if pour_waybar: return None
        for k in ('color0', 'background'):
            if k in w and hexrgb(w[k]): return [hexrgb(w[k])]
        return [hexrgb('#1b1a2b')]
    return [couleur_du_fond() or vive(w) or hexrgb('#c678dd')]             # wallust = couleur du fond d'écran


def couleur_du_fond():
    """Couleur dominante et vive du fond d'écran actuel (calculée une fois par fond, gardée en cache)."""
    import colorsys
    img = os.path.realpath(os.path.expanduser('~/.config/hypr/rofi/.current_wallpaper'))
    if not os.path.isfile(img): return None
    cache = os.path.expanduser('~/.cache/cava-couleur-fond.txt')
    cle = '%s|%d' % (img, int(os.path.getmtime(img)))
    try:
        c, h = open(cache).read().split('\n')[:2]
        if c == cle: return hexrgb(h)
    except Exception:
        pass
    try:
        out = subprocess.run(['magick', img, '-resize', '96x96!', '-colors', '10', '-format', '%c', 'histogram:info:-'],
                             capture_output=True, text=True, timeout=8).stdout
    except Exception:
        return None
    best, score = None, -1
    for l in out.splitlines():
        m = re.match(r'\s*(\d+):.*?#([0-9A-Fa-f]{6})', l)
        if not m: continue
        n, c = int(m.group(1)), hexrgb(m.group(2))
        hh, sat, val = colorsys.rgb_to_hsv(*c)
        if val < 0.2 or sat < 0.2: continue
        sc = n * sat ** 1.5 * (0.4 + val)
        if sc > score: best, score = (hh, sat, val), sc
    if not best: return None
    hh, sat, val = best
    c = colorsys.hsv_to_rgb(hh, min(1, sat * 1.05), max(val, 0.78))     # assez lumineuse pour être bien visible
    try: open(cache, 'w').write(cle + '\n' + rgbhex(c) + '\n')
    except Exception: pass
    return c


def vive(w):
    """La couleur Wallust la plus vive (saturée et lumineuse) = celle qui ressemble le plus au fond d'écran."""
    import colorsys
    best, score = None, -1
    for i in range(1, 16):
        c = hexrgb(w.get('color%d' % i, '') or '')
        if not c: continue
        h, sat, val = colorsys.rgb_to_hsv(*c)
        if val < 0.35: continue
        sc = sat * (0.6 + 0.4 * val)
        if sc > score: best, score = c, sc
    return best


def melange(cs, f):
    """Couleur à la position f (0…1) du dégradé."""
    if len(cs) == 1: return cs[0]
    f = max(0.0, min(1.0, f)) * (len(cs) - 1); i = min(int(f), len(cs) - 2); k = f - i
    return tuple(cs[i][j] * (1 - k) + cs[i + 1][j] * k for j in range(3))


# ---------------------------------------------------------------- formes (pures, testables)
def interp(vals, x):
    if not vals: return 0.0
    x = max(0.0, min(len(vals) - 1.0, x)); i = int(x); f = x - i
    return vals[i] * (1 - f) + vals[min(i + 1, len(vals) - 1)] * f


def basses(vals):
    n = max(1, len(vals) // 8)
    return sum(vals[:n]) / n if vals else 0.0


def niveau(vals, p, centre=False):
    """Niveau à la position p (0…1) de la largeur. Par défaut basses sur les côtés (miroir)."""
    zone = max(1, int(len(vals) * 0.75)) - 1
    d = math.sqrt((2 * p - 1) ** 2 + 0.004)            # 0 au centre, 1 aux bords (sans pointe)
    return interp(vals, (d if centre else 1 - min(1, d)) * zone)


def contour_haut(vals, t, w=TOP_W, h=TOP_H, pas=6):
    b = basses(vals); pts = []
    zone = max(1, int(len(vals) * 0.6)) - 1
    for x in range(0, w + 1, pas):
        u = (x - w / 2) / (w / 2)
        env = math.cos(u * math.pi / 2) ** 2
        v = interp(vals, math.sqrt(u * u + 0.004) * zone)
        goutte = math.exp(-(u / 0.42) ** 2)
        prof = 10 + 38 * v + 62 * b * goutte + 4 * math.sin(t * 2.1 + u * 6) * goutte
        pts.append((x, max(0.0, min(h - 4, env * prof))))
    return pts


def barres_bas(vals, w, h, pas=13, ratio=0.62):
    n = max(8, w // pas); larg = (w / n) * ratio; res = []
    for i in range(n):
        v = niveau(vals, i / (n - 1))
        res.append((i * w / n + (w / n - larg) / 2, larg, 4 + (h - 8) * v))
    return res


def vague_bas(vals, w, h, pas=8):
    return [(x, h - (4 + (h - 8) * niveau(vals, x / w, centre=True))) for x in range(0, w + 1, pas)]


def courbe(cr, pts):
    for i in range(len(pts) - 1):
        p0 = pts[max(i - 1, 0)]; p1 = pts[i]; p2 = pts[i + 1]; p3 = pts[min(i + 2, len(pts) - 1)]
        cr.curve_to(p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6,
                    p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6, p2[0], p2[1])


class Particules:
    """Bulles, étincelles et gouttes de pluie (styles bulles, collines, pluie)."""
    def __init__(self): self.l = []

    def avance(self, style, vals, w, h):
        rnd = random.random
        if style == 'bulles' and rnd() < 0.08 + 0.5 * basses(vals):
            v = niveau(vals, rnd()); self.l.append([20 + rnd() * (w - 40), 12 + rnd() * (h - 24), 3 + v * h * 0.22, 0, 0, 1.0])
        elif style == 'collines' and rnd() < 0.15 + 0.6 * basses(vals):
            self.l.append([rnd() * w, h * (0.15 + 0.4 * rnd()), 0, 0, 0, 1.0])
        elif style == 'pluie':
            for _ in range(4):
                p = rnd(); v = niveau(vals, p)
                if rnd() < v: self.l.append([p * w, h - 3, 0, -(1 + v * h * 0.05), 0, 1.0])
        vie = {'bulles': 0.012, 'collines': 0.03, 'pluie': 0.015}.get(style, 0.05)
        for q in self.l:
            q[5] -= vie
            if style == 'pluie': q[1] += q[3]; q[3] += h * 0.0012
        self.l = [q for q in self.l if q[5] > 0][-400:]


# ---------------------------------------------------------------- lecture de cava
def ecrire_conf_cava():
    os.makedirs(os.path.dirname(CAVA_CONF), exist_ok=True)
    open(CAVA_CONF, 'w').write(
        '[general]\nbars = %d\nframerate = 30\nsleep_timer = 2\n'
        '[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 1000\n'
        'bar_delimiter = 59\nframe_delimiter = 10\n'
        '[smoothing]\nnoise_reduction = 70\n' % NB)


def lire_trame(ligne):
    try:
        return [min(1.0, int(v) / 1000) for v in ligne.decode(errors='ignore').strip().split(';') if v.strip()]
    except ValueError:
        return None


# ---------------------------------------------------------------- dessin (cairo)
class Peintre:
    def __init__(self, cairo): self.cairo = cairo; self.cs = [(1, 1, 1)]; self.alpha = 0.9; self.w = 1

    def source(self, cr, a=1.0, w=None):
        """Couleur unie ou dégradé horizontal sur toute la largeur."""
        w = w or self.w
        if len(self.cs) == 1:
            r, g, b = self.cs[0]; cr.set_source_rgba(r, g, b, self.alpha * a); return
        gr = self.cairo.LinearGradient(0, 0, w, 0)
        for i, (r, g, b) in enumerate(self.cs): gr.add_color_stop_rgba(i / (len(self.cs) - 1), r, g, b, self.alpha * a)
        cr.set_source(gr)

    def point(self, cr, x, y, r):
        cr.new_sub_path(); cr.arc(x, y, r, 0, 2 * math.pi)

    def bas(self, cr, style, vals, W, H, t, parts):
        self.w = W; S = self.source
        if style in ('blocs', 'fines'):
            pas, ratio, rmax = (13, 0.62, 5) if style == 'blocs' else (6, 0.5, 0)
            for x, lw, hh in barres_bas(vals, W, H, pas, ratio):
                r = min(rmax, lw / 2); y = H - hh
                if r:
                    cr.new_sub_path(); cr.arc(x + r, y + r, r, math.pi, 1.5 * math.pi); cr.arc(x + lw - r, y + r, r, 1.5 * math.pi, 2 * math.pi)
                    cr.line_to(x + lw, H); cr.line_to(x, H); cr.close_path()
                else:
                    cr.rectangle(x, y, lw, hh)
            S(cr); cr.fill()
        elif style == 'ombre':
            for x, lw, hh in barres_bas(vals, W, H, 15, 0.72):
                for y in range(0, int(hh), 6):
                    cr.rectangle(x, H - y - 5, lw, 5); S(cr, 0.25 + 0.75 * y / max(hh, 1)); cr.fill()
        elif style == 'braille':
            n = W // 8
            for i in range(n):
                hh = niveau(vals, i / (n - 1)) * (H - 6)
                for y in range(0, int(hh), 7):
                    for k in (0, 3.5): self.point(cr, i * 8 + 2 + k, H - 4 - y, 1.5)
            S(cr); cr.fill()
        elif style == 'ondes':
            cr.set_line_width(3); cr.set_line_cap(self.cairo.LINE_CAP_ROUND)
            pts = [(x, H / 2 - (niveau(vals, x / W, True) * 0.85 + 0.05) * H * 0.45 * math.sin(x * 0.028 + t * 2.4))
                   for x in range(0, W + 1, 6)]
            cr.move_to(*pts[0]); courbe(cr, pts); S(cr); cr.stroke()
        elif style == 'liquide':
            pts = vague_bas(vals, W, H)
            cr.move_to(0, H); cr.line_to(*pts[0]); courbe(cr, pts); cr.line_to(W, H); cr.close_path(); S(cr); cr.fill()
        elif style == 'collines':
            n = W // 5
            for i in range(n):
                k = int(niveau(vals, i / (n - 1)) * (H * 0.55) / 5)
                for y in range(k + 1): self.point(cr, i * 5 + 2, H - 3 - y * 5, 1.3)
            S(cr); cr.fill()
            for x, y, _, _, _, a in parts.l:
                cr.rectangle(x - 4, y - 0.8, 8, 1.6); cr.rectangle(x - 0.8, y - 4, 1.6, 8); S(cr, a); cr.fill()
        elif style == 'pluie':
            for x, y, _, _, _, a in parts.l:
                cr.rectangle(x, y, 2, 2); S(cr, a); cr.fill()
        elif style == 'bulles':
            for x, y, r, _, _, a in parts.l:
                n = max(8, int(r * 1.2))
                for k in range(n):
                    ang = k / n * 2 * math.pi; self.point(cr, x + math.cos(ang) * r, y + math.sin(ang) * r, 1.4)
                S(cr, a); cr.fill()
        elif style == 'sica':                       # SICA géant : les barres bougent partout, les lettres s'allument
            for x, lw, hh in barres_bas(vals, W, H, 13, 0.62):
                cr.rectangle(x, H - hh, lw, hh)
            S(cr, 0.16); cr.fill()
            px = (H - 8) / 7.5; lw = 5 * px; gap = 2.2 * px; tot = len(MOT) * lw + (len(MOT) - 1) * gap
            x0 = (W - tot) / 2; y0 = (H - 7 * px) / 2 + 2
            basse = niveau(vals, 0.06)
            for li, ch in enumerate(MOT):
                for ry, row in enumerate(POLICE[ch]):
                    for rx, bit in enumerate(row):
                        if bit != '1': continue
                        x = x0 + li * (lw + gap) + rx * px
                        v = niveau(vals, x / max(W, 1))
                        a = 0.45 + 0.55 * max(v, basse)
                        m = px * (0.10 - 0.06 * basse)              # les cases grossissent sur les basses
                        cr.rectangle(x + m, y0 + ry * px + m, px - 2 * m, px - 2 * m)
                        S(cr, a); cr.fill()


# ---------------------------------------------------------------- fenêtres
def main():
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, GLib
    import cairo
    try:
        gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
    except Exception:
        LS = False

    c = conf()
    if c['cava_haut'] != 'on' and c['cava_bas'] != 'on': sys.exit(0)
    if not LS: print('gtk-layer-shell introuvable'); sys.exit(1)

    P = Peintre(cairo); parts = Particules()
    etat = {'cible': [0.0] * NB, 'vals': [0.0] * NB, 'derniere': 0.0, 'buf': b'', 'proc': None,
            'timer': None, 't': 0.0, 'mtimes': None, 'style': c['cava_style'], 'W': 1, 'H': 1}
    fenetres = []

    def regler(cc):
        P.cs = palette(cc); etat['style'] = cc['cava_style']
        P.alpha = max(0.2, min(1.0, int(cc.get('cava_opacite', '90') or 90) / 100))

    def couche(nom, layer, edges, w, h):
        win = Gtk.Window(title=nom)
        v = win.get_screen().get_rgba_visual()
        if v: win.set_visual(v)
        win.set_app_paintable(True); win.set_size_request(w, h)
        GtkLayerShell.init_for_window(win); GtkLayerShell.set_namespace(win, nom)
        GtkLayerShell.set_layer(win, layer)
        for e in edges: GtkLayerShell.set_anchor(win, e, True)
        try: GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.NONE)
        except Exception: pass
        area = Gtk.DrawingArea(); win.add(area); win.show_all()
        try: win.get_window().input_shape_combine_region(cairo.Region(), 0, 0)   # les clics passent à travers
        except Exception as e: print('zone de clic :', e)
        fenetres.append(area)
        return area

    def effacer(cr):
        cr.set_operator(cairo.OPERATOR_CLEAR); cr.paint(); cr.set_operator(cairo.OPERATOR_OVER)

    def dessin_haut(w, cr):
        effacer(cr); W = w.get_allocated_width()
        pts = contour_haut(etat['vals'], etat['t'], W, w.get_allocated_height())
        cr.move_to(0, 0); cr.line_to(*pts[0]); courbe(cr, pts); cr.line_to(pts[-1][0], 0); cr.close_path()
        P.w = W; P.source(cr, w=W); cr.fill()

    def dessin_bas(w, cr):
        effacer(cr); W, H = w.get_allocated_width(), w.get_allocated_height()
        etat['W'], etat['H'] = W, H
        P.bas(cr, etat['style'], etat['vals'], W, H, etat['t'], parts)

    regler(c)
    if c['cava_haut'] == 'on':
        couche('cava-liquide-haut', GtkLayerShell.Layer.TOP, [GtkLayerShell.Edge.TOP], TOP_W, TOP_H).connect('draw', dessin_haut)
    if c['cava_bas'] == 'on':
        E = GtkLayerShell.Edge
        couche('cava-liquide-bas', GtkLayerShell.Layer.BOTTOM, [E.BOTTOM, E.LEFT, E.RIGHT], 1,
               HAUTEURS.get(c.get('cava_bas_hauteur'), 110)).connect('draw', dessin_bas)

    def tick():
        etat['t'] += 0.033
        bouge = False
        for i, cible in enumerate(etat['cible']):
            v = etat['vals'][i]
            nv = v + (cible - v) * (0.55 if cible > v else 0.16)
            if abs(nv - v) > 0.002: bouge = True
            etat['vals'][i] = nv
        parts.avance(etat['style'], etat['vals'], etat['W'], etat['H'])
        if parts.l: bouge = True
        for a in fenetres: a.queue_draw()
        if time.monotonic() - etat['derniere'] > 0.6:
            etat['cible'] = [0.0] * NB
            if not bouge:
                etat['timer'] = None; return False
        return True

    def reveil():
        if etat['timer'] is None: etat['timer'] = GLib.timeout_add(33, tick)

    def lire(fd, cond):
        try: data = os.read(fd, 65536)
        except BlockingIOError: return True
        except OSError: data = b''
        if not data:
            GLib.timeout_add_seconds(3, lancer_cava); return False
        etat['buf'] += data
        lignes = etat['buf'].split(b'\n'); etat['buf'] = lignes[-1]
        if len(lignes) > 1:
            v = lire_trame(lignes[-2])
            if v and max(v) > 0.003:
                etat['cible'] = (v + [0.0] * NB)[:NB]; etat['derniere'] = time.monotonic(); reveil()
        return True

    def lancer_cava():
        ecrire_conf_cava()
        try:
            p = subprocess.Popen(['cava', '-p', CAVA_CONF], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        except FileNotFoundError:
            print('cava introuvable'); return False
        etat['proc'] = p; fd = p.stdout.fileno()
        fcntl.fcntl(fd, fcntl.F_SETFL, fcntl.fcntl(fd, fcntl.F_GETFL) | os.O_NONBLOCK)
        GLib.io_add_watch(fd, GLib.PRIORITY_DEFAULT, GLib.IO_IN | GLib.IO_HUP, lire)
        return False

    def surveiller():                                               # couleur, style ou Wallust changés
        _, f = wallust(); m = []
        for x in (CONF, f):
            try: m.append(os.path.getmtime(x) if x else 0)
            except OSError: m.append(0)
        if m != etat['mtimes']:
            etat['mtimes'] = m; regler(conf()); parts.l = []
            for a in fenetres: a.queue_draw()
        return True

    def quitter(*_):
        try: etat['proc'] and etat['proc'].terminate()
        except Exception: pass
        try: os.remove(PID)
        except Exception: pass
        Gtk.main_quit(); return False

    lancer_cava(); surveiller(); GLib.timeout_add_seconds(1, surveiller)
    for a in fenetres: a.queue_draw()
    for sg in (signal.SIGTERM, signal.SIGINT): GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, sg, quitter)
    Gtk.main()


if __name__ == '__main__':
    if os.path.exists(PID):
        try:
            os.kill(int(open(PID).read().strip()), 0); sys.exit(0)      # déjà lancé
        except (ProcessLookupError, ValueError, PermissionError):
            pass
    open(PID, 'w').write(str(os.getpid()))
    try: main()
    finally:
        try: os.remove(PID)
        except Exception: pass
