#!/usr/bin/env python3
# Platine vinyle sur le bureau : pochette en cours + disque qui tourne pendant la lecture
# Styles (menu Bureau → Style de la platine) : classique · verre · neon · pochette — couleur = couleur Cava
import os, sys, signal, subprocess, hashlib, urllib.parse, math, time, fcntl
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
import cairo
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False

HOME = os.path.expanduser('~'); U = HOME + '/.config/hypr/UserScripts'
sys.path.insert(0, U)
try:
    from CavaLiquide import conf as cava_conf, palette
except Exception:
    cava_conf = palette = None
CONF = U + '/bureau.conf'; CACHE = HOME + '/.cache/album-covers'
PID = '/tmp/platine-%d.pid' % os.getuid()
P = ['playerctl', '-p', 'mpv,%any']
DBL = getattr(Gdk.EventType, 'DOUBLE_BUTTON_PRESS', None) or getattr(Gdk.EventType, '_2BUTTON_PRESS', None)

def conf():
    d = {'platine_pos': 'bas-droite', 'platine_taille': 'moyenne', 'platine_style': 'classique'}
    try:
        for l in open(CONF, encoding='utf-8'):
            if '=' in l:
                k, v = l.strip().split('=', 1); d[k] = v
    except Exception:
        pass
    return d

def pc(*a):
    try: return subprocess.run(P + list(a), capture_output=True, text=True, timeout=1).stdout.strip()
    except Exception: return ''

def spawn(cmd):
    subprocess.Popen(cmd, start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def rrect(cr, x, y, w, h, r):
    r = min(r, w / 2, h / 2); cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -math.pi / 2, 0); cr.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    cr.arc(x + r, y + h - r, r, math.pi / 2, math.pi); cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2); cr.close_path()

def soft_shadow(cr, x, y, w, h, r, layers=7, spread=3.0, alpha=0.05):
    for i in range(layers, 0, -1):
        e = i * spread
        rrect(cr, x - e, y - e * 0.4, w + 2 * e, h + e * 1.4, r + e)
        cr.set_source_rgba(0.08, 0.04, 0.0, alpha); cr.fill()

# Dimensions de base (taille "moyenne")
BW, BH = 780, 340
SIZES = {'petite': 0.7, 'moyenne': 1.0, 'grande': 1.3}
COVER = (24, 30, 236)            # x, y, côté de la pochette
PLINTH = (300, 150, 450, 150)    # x, y, w, h du dessus de la platine
REC = (500, 225, 170, 62)        # centre x, centre y, rayon x, rayon y
LABEL = 0.30                     # rayon de l'étiquette / rayon du disque
PIVOT = (708, 172)

TAILLES = {'classique': (BW, BH), 'verre': (400, 420), 'neon': (300, 345), 'pochette': (420, 170)}
NBARRES = 16
CAVA_CONF = HOME + '/.cache/cava-platine.conf'


def couleur_cava():
    try: cs = palette(cava_conf(), pour_waybar=True) if palette else None
    except Exception: cs = None
    return cs[0] if cs else (0.03, 0.73, 0.66)


def texte(cr, t, x, y, taille, rgba, gras=False, maxw=9999, centre=False):
    cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD if gras else cairo.FONT_WEIGHT_NORMAL)
    cr.set_font_size(taille); t = t or ''
    while t and cr.text_extents(t)[4] > maxw: t = t[:-2] + '…' if not t.endswith('…') else t[:-2] + '…'
    w = cr.text_extents(t)[4]
    cr.move_to(x - w / 2 if centre else x, y); cr.set_source_rgba(*rgba); cr.show_text(t)


def mmss(us):
    s = int(us // 1e6) if us else 0; return '%d:%02d' % divmod(s, 60)


class Platine(Gtk.Window):
    def __init__(self):
        super().__init__(title='Platine')
        c = conf(); self.s = SIZES.get(c.get('platine_taille'), 1.0); pos = c.get('platine_pos', 'bas-droite')
        self.style = c.get('platine_style', 'classique'); self.style = self.style if self.style in TAILLES else 'classique'
        self.W, self.H = TAILLES[self.style]
        v = self.get_screen().get_rgba_visual()
        if v: self.set_visual(v)
        self.set_app_paintable(True)
        self.set_size_request(int(self.W * self.s), int(self.H * self.s))
        if LS:
            GtkLayerShell.init_for_window(self); GtkLayerShell.set_namespace(self, 'platine')
            GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BOTTOM)
            E = GtkLayerShell.Edge
            anchors = {'bas-droite': (E.BOTTOM, E.RIGHT), 'bas-gauche': (E.BOTTOM, E.LEFT), 'bas-centre': (E.BOTTOM,),
                       'haut-droite': (E.TOP, E.RIGHT), 'haut-gauche': (E.TOP, E.LEFT), 'centre': ()}
            for e in anchors.get(pos, (E.BOTTOM, E.RIGHT)):
                GtkLayerShell.set_anchor(self, e, True)
                GtkLayerShell.set_margin(self, e, 70 if e == E.TOP else 40)
            try: GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.NONE)
            except Exception: pass
        else:
            self.set_decorated(False)
        prov = Gtk.CssProvider(); prov.load_from_data(b'window { background-color: transparent; }')
        Gtk.StyleContext.add_provider_for_screen(self.get_screen(), prov, 800)
        self.area = Gtk.DrawingArea(); self.add(self.area)
        self.area.connect('draw', self.draw)
        self.area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.area.connect('button-press-event', self.click)
        self.playing = False; self.angle = 0.0; self.arm = 0.0
        self.cover = None; self.old = None; self.fade = 1.0; self.cover_path = 0
        self.title = ''; self.artist = ''; self.pos = 0; self.len = 0; self.zones = {}
        self.c = couleur_cava(); self.niv = [0.0] * NBARRES; self.cible = [0.0] * NBARRES; self.proc = None; self.buf = b''
        if self.style in ('neon', 'pochette'): self.lancer_cava()
        self.anim = None; self.last = time.monotonic()
        self.update(); GLib.timeout_add(1000, self.update)
        self.connect('destroy', self.quit)

    # ---------- données ----------
    def load(self, path):
        if not (path and os.path.isfile(path)): return None
        try:
            p = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 512, 512, True)
            n = min(p.get_width(), p.get_height())
            return p.new_subpixbuf((p.get_width() - n) // 2, (p.get_height() - n) // 2, n, n).copy()
        except Exception:
            return None

    def update(self):
        o = pc('metadata', '--format', '{{status}}\t{{title}}\t{{artist}}\t{{mpris:artUrl}}\t{{xesam:url}}\t{{position}}\t{{mpris:length}}')
        st, ti, ar, art, url, po, ln = (o.split('\t') + [''] * 7)[:7]
        try: self.pos, self.len = float(po or 0), float(ln or 0)
        except ValueError: self.pos, self.len = 0, 0
        self.c = couleur_cava()
        path = urllib.parse.unquote(url[7:]) if url.startswith('file://') else ''
        cov = urllib.parse.unquote(art[7:]) if art.startswith('file://') else None
        if not (cov and os.path.isfile(cov)) and path:
            cov = '%s/%s.jpg' % (CACHE, hashlib.md5(os.path.dirname(path).encode()).hexdigest()[:16])
        if not o: cov = None
        if cov != self.cover_path:
            self.cover_path = cov; self.old = self.cover; self.cover = self.load(cov); self.fade = 0.0
        self.title = ti or os.path.splitext(os.path.basename(path))[0]
        self.artist = ar or os.path.basename(os.path.dirname(path))
        self.playing = (st == 'Playing')
        self.kick()
        return True

    def kick(self):
        if self.anim is None:
            self.last = time.monotonic(); self.anim = GLib.timeout_add(66, self.tick)

    def tick(self):
        now = time.monotonic(); dt = min(0.1, now - self.last); self.last = now
        target = 1.0 if self.playing else 0.0
        self.arm += (target - self.arm) * min(1, dt * 3)
        if self.playing: self.angle = (self.angle + dt * 2 * math.pi * 33.3 / 60) % (2 * math.pi)
        if self.fade < 1: self.fade = min(1.0, self.fade + dt * 2)
        if self.playing: self.pos += dt * 1e6
        self.niv = [a + (b - a) * min(1, dt * 12) for a, b in zip(self.niv, self.cible if self.playing else [0.0] * NBARRES)]
        self.area.queue_draw()
        busy = self.playing or self.fade < 1 or abs(target - self.arm) > 0.01
        if not busy: self.anim = None
        return busy

    # ---------- dessin ----------
    def paint_cover(self, cr, pix, x, y, n, alpha):
        if pix is None:
            rrect(cr, x, y, n, n, 3); cr.set_source_rgba(0.16, 0.16, 0.19, alpha); cr.fill()
            cr.set_source_rgba(1, 1, 1, 0.5 * alpha); cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
            cr.set_font_size(n * 0.3); ext = cr.text_extents('♫'); cr.move_to(x + (n - ext[4]) / 2, y + n * 0.62); cr.show_text('♫')
            return
        cr.save(); rrect(cr, x, y, n, n, 3); cr.clip()
        cr.translate(x, y); sc = n / pix.get_width(); cr.scale(sc, sc)
        Gdk.cairo_set_source_pixbuf(cr, pix, 0, 0); cr.paint_with_alpha(alpha); cr.restore()

    # ---------- cava (barres et halo qui suivent la musique) ----------
    def lancer_cava(self):
        try:
            open(CAVA_CONF, 'w').write('[general]\nbars = %d\nframerate = 25\nsleep_timer = 2\n'
                '[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 1000\n'
                'bar_delimiter = 59\nframe_delimiter = 10\n[smoothing]\nnoise_reduction = 70\n' % NBARRES)
            self.proc = subprocess.Popen(['cava', '-p', CAVA_CONF], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        except Exception:
            self.proc = None; return False
        fd = self.proc.stdout.fileno(); fcntl.fcntl(fd, fcntl.F_SETFL, fcntl.fcntl(fd, fcntl.F_GETFL) | os.O_NONBLOCK)
        GLib.io_add_watch(fd, GLib.PRIORITY_DEFAULT, GLib.IO_IN | GLib.IO_HUP, self.lire_cava)
        return False

    def lire_cava(self, fd, cond):
        try: data = os.read(fd, 65536)
        except BlockingIOError: return True
        except OSError: data = b''
        if not data: GLib.timeout_add_seconds(3, self.lancer_cava); return False
        self.buf += data; l = self.buf.split(b'\n'); self.buf = l[-1]
        if len(l) > 1:
            try: v = [int(x) / 1000 for x in l[-2].decode().strip(';').split(';') if x]
            except ValueError: v = []
            if v: self.cible = (v + [0.0] * NBARRES)[:NBARRES]
        return True

    # ---------- dessin ----------
    def disque(self, cr, cx, cy, r, halo=0.0):
        rr, g, b = self.c
        if halo:
            for k in range(6, 0, -1):
                cr.arc(cx, cy, r + k * 4 * (0.6 + halo), 0, 2 * math.pi)
                cr.set_source_rgba(rr, g, b, 0.05 + 0.05 * halo); cr.fill()
        cr.arc(cx, cy, r + 3, 0, 2 * math.pi); cr.set_source_rgba(0, 0, 0, 0.45); cr.fill()
        cr.arc(cx, cy, r, 0, 2 * math.pi); cr.set_source_rgb(0.05, 0.05, 0.06); cr.fill()
        cr.set_line_width(1.1)
        for k in range(1, 22):
            rk = r * (1 - k * 0.032)
            if rk <= r * 0.36: break
            cr.arc(cx, cy, rk, 0, 2 * math.pi); gg = 0.13 if k % 2 else 0.09; cr.set_source_rgb(gg, gg, gg + 0.01); cr.stroke()
        for a0 in (200, 20):                                   # reflets fixes
            cr.move_to(cx, cy); cr.arc(cx, cy, r, math.radians(a0), math.radians(a0 + 28)); cr.close_path()
            cr.set_source_rgba(1, 1, 1, 0.06); cr.fill()
        if halo:
            cr.arc(cx, cy, r, 0, 2 * math.pi); cr.set_line_width(3); cr.set_source_rgb(rr, g, b); cr.stroke()
        lr = r * 0.34
        cr.save(); cr.translate(cx, cy); cr.rotate(self.angle); cr.arc(0, 0, lr, 0, 2 * math.pi); cr.clip()
        src = self.cover or self.old
        if src is not None:
            sc = 2 * lr / src.get_width(); cr.scale(sc, sc)
            Gdk.cairo_set_source_pixbuf(cr, src, -src.get_width() / 2, -src.get_height() / 2); cr.paint()
        else:
            cr.set_source_rgb(rr, g, b); cr.paint()
        cr.restore()
        cr.arc(cx, cy, 4, 0, 2 * math.pi); cr.set_source_rgb(0.9, 0.9, 0.92); cr.fill()
        self.zones['disque'] = (cx, cy, r)

    def barres(self, cr, x, yb, n, larg, ecart, hmax):
        rr, g, b = self.c
        for i in range(n):
            v = self.niv[i * NBARRES // n] if self.playing else 0
            h = max(3, hmax * min(1, v)); rrect(cr, x + i * (larg + ecart), yb - h, larg, h, 2)
            cr.set_source_rgba(rr, g, b, 0.92); cr.fill()

    def progression(self, cr, x, y, w, h=5):
        rr, g, b = self.c; f = min(1, self.pos / self.len) if self.len else 0
        rrect(cr, x, y, w, h, h / 2); cr.set_source_rgba(1, 1, 1, 0.12); cr.fill()
        if f: rrect(cr, x, y, max(h, w * f), h, h / 2); cr.set_source_rgb(rr, g, b); cr.fill()

    def carte(self, cr, x, y, w, h, r, fond, bord=None, glow=False):
        rr, g, b = self.c
        if glow:
            for k in range(5, 0, -1):
                rrect(cr, x - k * 2, y - k * 2, w + k * 4, h + k * 4, r + k * 2); cr.set_source_rgba(rr, g, b, 0.035); cr.fill()
        rrect(cr, x, y, w, h, r); cr.set_source_rgba(*fond); cr.fill()
        if bord:
            rrect(cr, x, y, w, h, r); cr.set_line_width(bord[0]); cr.set_source_rgba(*bord[1]); cr.stroke()

    def pochette(self, cr, x, y, n):
        soft_shadow(cr, x, y + 4, n, n + 6, 6, layers=5, spread=2.5, alpha=0.08)
        self.paint_cover(cr, self.old, x, y, n, 1 - self.fade); self.paint_cover(cr, self.cover, x, y, n, self.fade)
        self.zones['pochette'] = (x, y, n, n)

    def draw_verre(self, cr):
        rr, g, b = self.c; W, H = self.W, self.H
        self.carte(cr, 14, 14, W - 28, H - 28, 20, (0.055, 0.047, 0.094, 0.80), (2, (rr, g, b, 1)), glow=True)
        self.disque(cr, 34 + 95 + 90 * self.arm, 34 + 95, 91)
        self.pochette(cr, 34, 34, 190)
        ax, ay = W - 50, 46                                    # bras
        cr.arc(ax, ay, 13, 0, 2 * math.pi); cr.set_source_rgb(0.16, 0.16, 0.2); cr.fill()
        cr.arc(ax, ay, 13, 0, 2 * math.pi); cr.set_line_width(2); cr.set_source_rgb(rr, g, b); cr.stroke()
        a = math.radians(96 + 18 * self.arm); ex, ey = ax + math.cos(a) * 110, ay + math.sin(a) * 110
        cr.set_line_cap(cairo.LINE_CAP_ROUND); cr.set_line_width(5); cr.move_to(ax, ay); cr.line_to(ex, ey)
        cr.line_to(ex - 18, ey + 26); cr.set_source_rgb(0.85, 0.85, 0.9); cr.stroke()
        cr.save(); cr.translate(ex - 18, ey + 26); cr.rotate(math.radians(35)); rrect(cr, -10, -6, 20, 12, 3)
        cr.set_source_rgb(rr, g, b); cr.fill(); cr.restore()
        texte(cr, self.title, 34, 268, 19, (0.93, 0.9, 1, 1), True, W - 68)
        texte(cr, self.artist, 34, 292, 14, (0.73, 0.70, 0.84, 1), False, W - 68)
        self.progression(cr, 34, 308, W - 68)
        texte(cr, mmss(self.pos), 34, 330, 11, (0.6, 0.58, 0.72, 1))
        t = mmss(self.len); cr.set_font_size(11); texte(cr, t, W - 34 - cr.text_extents(t)[4], 330, 11, (0.6, 0.58, 0.72, 1))
        cy = 366; cx = W / 2                                   # boutons ⏮ ⏯ ⏭
        cr.arc(cx, cy, 21, 0, 2 * math.pi); cr.set_source_rgb(rr, g, b); cr.fill()
        cr.set_source_rgb(0.04, 0.08, 0.1)
        if self.playing:
            cr.rectangle(cx - 7, cy - 8, 5, 16); cr.rectangle(cx + 2, cy - 8, 5, 16); cr.fill()
        else:
            cr.move_to(cx - 5, cy - 9); cr.line_to(cx + 9, cy); cr.line_to(cx - 5, cy + 9); cr.close_path(); cr.fill()
        cr.set_source_rgba(0.93, 0.9, 1, 0.9)
        for sx, d in ((cx - 62, -1), (cx + 62, 1)):
            cr.move_to(sx - 6 * d, cy - 8); cr.line_to(sx + 6 * d, cy); cr.line_to(sx - 6 * d, cy + 8); cr.close_path(); cr.fill()
            cr.rectangle(sx + 6 * d - (2 if d > 0 else 0), cy - 8, 2, 16); cr.fill()
        self.zones.update(prev=(cx - 82, cy - 20, 40, 40), play=(cx - 22, cy - 22, 44, 44), next=(cx + 42, cy - 20, 40, 40))

    def draw_neon(self, cr):
        rr, g, b = self.c; W = self.W
        moy = sum(self.niv) / NBARRES if self.playing else 0
        self.disque(cr, W / 2, 140, 108, halo=0.25 + min(1, moy * 2.5))
        n, larg, ec = 15, 5, 4; x0 = W / 2 - (n * (larg + ec) - ec) / 2
        self.barres(cr, x0, 300, n, larg, ec, 34)
        for k, a in ((3, 0.25), (0, 1)):                        # titre lumineux
            texte(cr, self.title, W / 2, 324, 18, (rr, g, b, 0.35) if k else (0.95, 1, 1, a), True, W - 30, True)
        texte(cr, self.artist, W / 2, 342, 13, (0.84, 0.96, 0.95, 0.9), False, W - 30, True)

    def draw_pochette(self, cr):
        rr, g, b = self.c; W, H = self.W, self.H
        self.carte(cr, 4, 4, W - 8, H - 8, 16, (0.055, 0.047, 0.094, 0.62), (1, (1, 1, 1, 0.10)))
        self.disque(cr, 16 + 73 + 58 * self.arm, H / 2, 72)
        self.pochette(cr, 16, (H - 146) / 2, 146)
        texte(cr, self.title, 236, 52, 16, (0.93, 0.9, 1, 1), True, W - 250)
        texte(cr, self.artist, 236, 73, 13, (0.73, 0.70, 0.84, 1), False, W - 250)
        self.barres(cr, 236, 124, 12, 5, 4, 34)
        self.progression(cr, 18, H - 7, W - 36, 3)

    def draw(self, w, cr):
        cr.set_operator(cairo.OPERATOR_CLEAR); cr.paint(); cr.set_operator(cairo.OPERATOR_OVER)
        cr.scale(self.s, self.s)
        if self.style != 'classique':
            self.zones = {}; getattr(self, 'draw_' + self.style)(cr); return
        self.draw_classique(cr)

    def draw_classique(self, cr):
        x, y, n = COVER
        # présentoir
        soft_shadow(cr, x, y + 6, n, n + 30, 6)
        self.paint_cover(cr, self.old, x, y, n, 1 - self.fade)
        self.paint_cover(cr, self.cover, x, y, n, self.fade)
        rrect(cr, x, y, n, n, 3); cr.set_source_rgba(1, 0.98, 0.94, 0.9); cr.set_line_width(3); cr.stroke()
        rrect(cr, x - 22, y + n - 6, n + 44, 40, 8); cr.set_source_rgb(0.52, 0.32, 0.18); cr.fill()
        cr.rectangle(x - 22, y + n - 6, n + 44, 8); cr.set_source_rgb(0.63, 0.41, 0.24); cr.fill()
        # titre gravé sur le présentoir
        t = (self.title or '')[:34]
        cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL); cr.set_font_size(12)
        ext = cr.text_extents(t); cr.move_to(x + (n - ext[4]) / 2, y + n + 22)
        cr.set_source_rgba(1, 0.93, 0.85, 0.85); cr.show_text(t)
        # platine
        px, py, pw, ph = PLINTH
        soft_shadow(cr, px, py + 10, pw, ph + 24, 18)
        rrect(cr, px, py + ph - 10, pw, 36, 14); cr.set_source_rgb(0.55, 0.36, 0.21); cr.fill()
        rrect(cr, px, py, pw, ph, 18); cr.set_source_rgb(0.84, 0.77, 0.66); cr.fill()
        rx0, ry0, rxr, ryr = REC
        # plateau
        cr.save(); cr.translate(rx0, ry0 + 3); cr.scale(1, ryr / rxr)
        cr.arc(0, 0, rxr + 8, 0, 2 * math.pi); cr.restore(); cr.set_source_rgb(0.66, 0.66, 0.68); cr.fill()
        # disque + sillons
        cr.save(); cr.translate(rx0, ry0); cr.scale(1, ryr / rxr)
        cr.arc(0, 0, rxr, 0, 2 * math.pi); cr.set_source_rgb(0.08, 0.08, 0.09); cr.fill()
        cr.set_line_width(1.2)
        for k in range(1, 15):
            r = rxr * (1 - k * 0.045)
            if r <= rxr * LABEL: break
            cr.arc(0, 0, r, 0, 2 * math.pi)
            g = 0.17 if k % 2 else 0.12; cr.set_source_rgb(g, g, g + 0.01); cr.stroke()
        # reflet fixe
        cr.move_to(0, 0); cr.arc(0, 0, rxr, math.radians(200), math.radians(232)); cr.close_path()
        cr.set_source_rgba(1, 1, 1, 0.07); cr.fill()
        # étiquette = pochette (tourne)
        lr = rxr * LABEL
        cr.rotate(self.angle)
        cr.arc(0, 0, lr, 0, 2 * math.pi); cr.clip()
        src = self.cover or self.old
        if src is not None:
            sc = 2 * lr / src.get_width(); cr.save(); cr.scale(sc, sc)
            Gdk.cairo_set_source_pixbuf(cr, src, -src.get_width() / 2, -src.get_height() / 2); cr.paint(); cr.restore()
        else:
            cr.set_source_rgb(0.85, 0.35, 0.19); cr.paint()
        cr.restore()
        cr.save(); cr.translate(rx0, ry0); cr.scale(1, ryr / rxr)
        cr.arc(0, 0, 4, 0, 2 * math.pi); cr.set_source_rgb(0.92, 0.92, 0.92); cr.fill(); cr.restore()
        # bras (se pose quand ça joue)
        ax, ay = PIVOT
        cr.arc(ax, ay, 22, 0, 2 * math.pi); cr.set_source_rgb(0.7, 0.7, 0.72); cr.fill()
        cr.arc(ax, ay, 12, 0, 2 * math.pi); cr.set_source_rgb(0.45, 0.45, 0.48); cr.fill()
        rest, play = math.radians(100), math.radians(128)
        a = rest + (play - rest) * self.arm
        ex, ey = ax + math.cos(a) * 125, ay + math.sin(a) * 125 * 0.75
        hx, hy = ex - 30, ey + 8
        cr.set_line_cap(cairo.LINE_CAP_ROUND); cr.set_line_width(6)
        cr.move_to(ax, ay); cr.line_to(ex, ey); cr.line_to(hx, hy); cr.set_source_rgb(0.82, 0.82, 0.85); cr.stroke()
        rrect(cr, hx - 10, hy - 7, 18, 14, 3); cr.set_source_rgb(0.24, 0.24, 0.26); cr.fill()
        # pieds / boutons
        for bx in (px + 26, px + pw - 26):
            cr.arc(bx, py + ph + 6, 9, 0, 2 * math.pi); cr.set_source_rgb(0.32, 0.32, 0.34); cr.fill()

    # ---------- clics ----------
    def click(self, w, ev):
        x, y = ev.x / self.s, ev.y / self.s
        if ev.button == 3:
            spawn([U + '/BureauMenu.sh']); return True
        if ev.button != 1: return False
        if self.style != 'classique': return self.click_style(ev, x, y)
        rx0, ry0, rxr, ryr = REC; cx, cy, n = COVER
        on_rec = ((x - rx0) / rxr) ** 2 + ((y - ry0) / ryr) ** 2 <= 1.2
        on_cov = cx <= x <= cx + n and cy <= y <= cy + n
        if DBL is not None and ev.type == DBL and on_rec:
            spawn([U + '/AlbumPicker.sh']); return True
        if ev.type != Gdk.EventType.BUTTON_PRESS: return True
        if on_rec:
            subprocess.Popen(P + ['play-pause']); GLib.timeout_add(250, self.update)
        elif on_cov:
            spawn(['python3', U + '/NowPlaying.py'])
        return True

    def click_style(self, ev, x, y):
        def dans(z):
            if z is None: return False
            if len(z) == 3: return (x - z[0]) ** 2 + (y - z[1]) ** 2 <= z[2] ** 2
            return z[0] <= x <= z[0] + z[2] and z[1] <= y <= z[1] + z[3]
        Z = self.zones
        if DBL is not None and ev.type == DBL and dans(Z.get('disque')):
            spawn([U + '/AlbumPicker.sh']); return True
        if ev.type != Gdk.EventType.BUTTON_PRESS: return True
        for k, cmd in (('prev', 'previous'), ('next', 'next'), ('play', 'play-pause')):
            if dans(Z.get(k)): subprocess.Popen(P + [cmd]); GLib.timeout_add(250, self.update); return True
        if dans(Z.get('pochette')): spawn(['python3', U + '/NowPlaying.py'])
        elif dans(Z.get('disque')): subprocess.Popen(P + ['play-pause']); GLib.timeout_add(250, self.update)
        return True

    def quit(self, *_):
        try: self.proc and self.proc.terminate()
        except Exception: pass
        try: os.remove(PID)
        except Exception: pass
        Gtk.main_quit(); return False

if __name__ == '__main__':
    if os.path.exists(PID):
        try:
            os.kill(int(open(PID).read().strip()), 0); sys.exit(0)   # déjà lancée
        except (ProcessLookupError, ValueError, PermissionError):
            pass
    open(PID, 'w').write(str(os.getpid()))
    w = Platine(); w.show_all()
    for sg in (signal.SIGTERM, signal.SIGINT):
        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, sg, w.quit)
    Gtk.main()
