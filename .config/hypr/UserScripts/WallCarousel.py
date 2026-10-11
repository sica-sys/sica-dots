#!/usr/bin/env python3
# Carrousel 3D de fonds d'écran (façon Caelestia) pour Hyprland + awww/swww + wallust
import os, sys, signal, subprocess, hashlib, math, shutil
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
import cairo
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False

HOME = os.path.expanduser('~')
PID = '/tmp/wallcarousel-%d.pid' % os.getuid()
THUMBS = HOME + '/.cache/wallcarousel'
WALLUST = HOME + '/.config/hypr/scripts/WallustSwww.sh'
EXT = ('.png', '.jpg', '.jpeg', '.webp', '.bmp', '.gif')
CW, CH = 250, 370   # carte centrale

def wall_dirs():
    out = []
    try:
        pics = subprocess.run(['xdg-user-dir', 'PICTURES'], capture_output=True, text=True, timeout=2).stdout.strip()
    except Exception:
        pics = ''
    for d in (pics + '/wallpapers' if pics else '', HOME + '/Images/wallpapers', HOME + '/Pictures/wallpapers'):
        if d and os.path.isdir(d) and os.path.realpath(d) not in [os.path.realpath(x) for x in out]:
            out.append(d)
    return out

def list_walls():
    files = []
    for d in wall_dirs():
        for root, _, names in os.walk(d):
            for n in names:
                if n.lower().endswith(EXT): files.append(os.path.join(root, n))
    return sorted(set(files), key=lambda p: os.path.basename(p).lower())

def www():
    return shutil.which('awww') or shutil.which('swww')

def current_wall():
    w = www()
    if not w: return ''
    try:
        o = subprocess.run([w, 'query'], capture_output=True, text=True, timeout=2).stdout
        for l in o.splitlines():
            if 'image: ' in l: return l.split('image: ', 1)[1].strip()
    except Exception:
        pass
    return ''

def rrect(cr, x, y, w, h, r):
    r = min(r, w / 2, h / 2); cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -math.pi / 2, 0); cr.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    cr.arc(x + r, y + h - r, r, math.pi / 2, math.pi); cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2); cr.close_path()

def thumb(path):
    os.makedirs(THUMBS, exist_ok=True)
    try: st = os.stat(path)
    except OSError: return None
    key = hashlib.md5(('%s|%d|%d' % (path, st.st_size, int(st.st_mtime))).encode()).hexdigest()[:20]
    f = '%s/%s.jpg' % (THUMBS, key)
    if os.path.isfile(f):
        try: return GdkPixbuf.Pixbuf.new_from_file(f)
        except Exception: pass
    try:
        info = GdkPixbuf.Pixbuf.get_file_info(path)
        iw, ih = info[1], info[2]
        if iw * CH > ih * CW: p = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, -1, CH, True)
        else: p = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, CW, -1, True)
        w, h = p.get_width(), p.get_height()
        cw, ch = min(CW, w), min(CH, h)
        p = p.new_subpixbuf((w - cw) // 2, (h - ch) // 2, cw, ch).copy()
        if p.get_has_alpha():
            p = p.composite_color_simple(cw, ch, GdkPixbuf.InterpType.BILINEAR, 255, 32, 0x202020, 0x202020)
        p.savev(f, 'jpeg', ['quality'], ['88'])
        return p
    except Exception:
        return None

class Carousel(Gtk.Window):
    def __init__(self):
        super().__init__(title='WallCarousel')
        v = self.get_screen().get_rgba_visual()
        if v: self.set_visual(v)
        self.set_app_paintable(True)
        if LS:
            GtkLayerShell.init_for_window(self); GtkLayerShell.set_namespace(self, 'wallcarousel')
            GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
            for e in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
                GtkLayerShell.set_anchor(self, e, True)
            GtkLayerShell.set_exclusive_zone(self, -1)
            try: GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
            except Exception:
                try: GtkLayerShell.set_keyboard_interactivity(self, True)
                except Exception: pass
        else:
            self.fullscreen()
        css = b"""
        window { background-color: transparent; }
        entry { background-color: rgba(255,255,255,0.08); color: #eaeaea; border: 1px solid rgba(255,255,255,0.14);
                border-radius: 12px; padding: 8px 14px; font-family: "JetBrainsMono Nerd Font"; font-size: 13px;
                box-shadow: none; background-image: none; caret-color: #ffffff; }
        entry:focus { border-color: rgba(255,255,255,0.32); }
        """
        prov = Gtk.CssProvider(); prov.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(self.get_screen(), prov, 800)

        self.all = list_walls(); self.items = list(self.all)
        self.cache = {}; self.queue = []
        cur = current_wall()
        self.target = self.items.index(cur) if cur in self.items else 0
        self.pos = float(self.target); self.anim = None; self.rects = []

        ov = Gtk.Overlay(); self.add(ov)
        self.area = Gtk.DrawingArea(); ov.add(self.area)
        self.area.connect('draw', self.draw)
        self.area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.SCROLL_MASK | Gdk.EventMask.SMOOTH_SCROLL_MASK)
        self.area.connect('button-press-event', self.click)
        self.area.connect('scroll-event', self.scroll)
        self.entry = Gtk.Entry(); self.entry.set_placeholder_text('  Rechercher un fond d\'écran…')
        self.entry.set_width_chars(38); self.entry.set_halign(Gtk.Align.CENTER); self.entry.set_valign(Gtk.Align.START)
        self.entry.set_margin_top(48); self.entry.connect('changed', self.filter)
        self.entry.connect('activate', lambda *_: self.apply())
        ov.add_overlay(self.entry)
        self.connect('key-press-event', self.key)
        self.connect('destroy', self.quit)
        self.schedule_thumbs()

    # ---------- vignettes chargées petit à petit, les plus proches d'abord ----------
    def schedule_thumbs(self):
        c = int(round(self.target))
        order = sorted(range(len(self.items)), key=lambda i: abs(i - c))
        self.queue = [self.items[i] for i in order if self.items[i] not in self.cache]
        GLib.idle_add(self.load_next)

    def load_next(self):
        if not self.queue: return False
        p = self.queue.pop(0)
        if p not in self.cache:
            self.cache[p] = thumb(p); self.area.queue_draw()
        return bool(self.queue)

    # ---------- navigation ----------
    def go(self, idx):
        if not self.items: return
        self.target = max(0, min(len(self.items) - 1, idx))
        if self.anim is None: self.anim = GLib.timeout_add(16, self.step)

    def step(self):
        d = self.target - self.pos
        if abs(d) < 0.002:
            self.pos = float(self.target); self.anim = None; self.area.queue_draw(); return False
        self.pos += d * 0.2; self.area.queue_draw(); return True

    def filter(self, *_):
        q = self.entry.get_text().strip().lower()
        cur = self.items[self.target] if self.items else None
        self.items = [p for p in self.all if q in os.path.basename(p).lower()] if q else list(self.all)
        idx = self.items.index(cur) if cur in self.items else 0
        self.target = idx; self.pos = float(idx); self.schedule_thumbs(); self.area.queue_draw()

    def key(self, w, ev):
        k = ev.keyval
        if k == Gdk.KEY_Escape: self.quit(); return True
        if k in (Gdk.KEY_Left, Gdk.KEY_Up, Gdk.KEY_ISO_Left_Tab): self.go(self.target - 1); return True
        if k in (Gdk.KEY_Right, Gdk.KEY_Down, Gdk.KEY_Tab): self.go(self.target + 1); return True
        if k in (Gdk.KEY_Page_Up,): self.go(self.target - 5); return True
        if k in (Gdk.KEY_Page_Down,): self.go(self.target + 5); return True
        if k in (Gdk.KEY_Return, Gdk.KEY_KP_Enter): self.apply(); return True
        return False

    def scroll(self, w, ev):
        if ev.direction == Gdk.ScrollDirection.UP: self.go(self.target - 1)
        elif ev.direction == Gdk.ScrollDirection.DOWN: self.go(self.target + 1)
        elif ev.direction == Gdk.ScrollDirection.SMOOTH:
            ok, dx, dy = ev.get_scroll_deltas()
            if ok and abs(dy) + abs(dx) > 0.3: self.go(self.target + (1 if (dy + dx) > 0 else -1))
        return True

    def click(self, w, ev):
        if ev.button != 1: return False
        for i, (x, y, cw, ch) in reversed(self.rects):
            if x <= ev.x <= x + cw and y <= ev.y <= y + ch:
                if i == self.target: self.apply()
                else: self.go(i)
                return True
        self.quit(); return True

    # ---------- dessin ----------
    def draw(self, w, cr):
        W, H = w.get_allocated_width(), w.get_allocated_height()
        cr.set_operator(cairo.OPERATOR_SOURCE); cr.set_source_rgba(0.03, 0.04, 0.06, 0.62); cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD); cr.set_font_size(13)
        cr.set_source_rgba(1, 1, 1, 0.75); cr.move_to(28, 40); cr.show_text('FONDS D\'ÉCRAN')
        cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL); cr.set_font_size(12)
        n = len(self.items)
        info = '%d / %d' % (self.target + 1, n) if n else 'Aucun fond trouvé'
        ext = cr.text_extents(info); cr.set_source_rgba(1, 1, 1, 0.55); cr.move_to(W - 28 - ext[4], 40); cr.show_text(info)
        hint = '←  →  molette : tourner    ·    Entrée / clic : appliquer    ·    Échap : fermer'
        ext = cr.text_extents(hint); cr.move_to((W - ext[4]) / 2, H - 34); cr.show_text(hint)
        self.rects = []
        if not n: return
        cx, cy = W / 2, H / 2 + 30
        R = min(W * 0.40, 760)
        cards = []
        for i in range(max(0, int(self.pos) - 8), min(n, int(self.pos) + 9)):
            d = i - self.pos
            a = d * 0.30
            if abs(a) > 1.45: continue
            z = math.cos(a)
            sc = 0.55 + 0.45 * z
            x = cx + R * math.sin(a)
            y = cy - (1 - z) * 110
            cards.append((z, i, x, y, sc))
        cards.sort()
        for z, i, x, y, sc in cards:
            cw, ch = CW * sc, CH * sc
            x0, y0 = x - cw / 2, y - ch / 2
            alpha = max(0.15, min(1.0, 0.25 + 0.75 * z ** 3))
            # ombre
            for k in range(6, 0, -1):
                e = k * 3 * sc
                rrect(cr, x0 - e, y0 - e * 0.3 + 10 * sc, cw + 2 * e, ch + 2 * e, 16 * sc + e)
                cr.set_source_rgba(0, 0, 0, 0.05 * alpha); cr.fill()
            cr.save(); rrect(cr, x0, y0, cw, ch, 16 * sc); cr.clip()
            pix = self.cache.get(self.items[i])
            if pix is not None:
                k = max(cw / pix.get_width(), ch / pix.get_height())
                cr.save(); cr.translate(x0 + (cw - pix.get_width() * k) / 2, y0 + (ch - pix.get_height() * k) / 2); cr.scale(k, k)
                Gdk.cairo_set_source_pixbuf(cr, pix, 0, 0); cr.paint_with_alpha(alpha); cr.restore()
            else:
                cr.set_source_rgba(1, 1, 1, 0.06 * alpha); cr.paint()
            # bandeau du nom
            g = cairo.LinearGradient(0, y0 + ch * 0.68, 0, y0 + ch)
            g.add_color_stop_rgba(0, 0, 0, 0, 0); g.add_color_stop_rgba(1, 0, 0, 0, 0.75 * alpha)
            cr.rectangle(x0, y0, cw, ch); cr.set_source(g); cr.fill()
            name = os.path.splitext(os.path.basename(self.items[i]))[0].replace('_', ' ')
            cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD); cr.set_font_size(max(9, 13 * sc))
            while len(name) > 4 and cr.text_extents(name)[4] > cw - 24 * sc: name = name[:-2]
            cr.set_source_rgba(1, 1, 1, 0.92 * alpha); cr.move_to(x0 + 12 * sc, y0 + ch - 16 * sc); cr.show_text(name)
            cr.restore()
            rrect(cr, x0, y0, cw, ch, 16 * sc)
            if i == self.target: cr.set_source_rgba(1, 1, 1, 0.85); cr.set_line_width(2.5)
            else: cr.set_source_rgba(1, 1, 1, 0.12 * alpha); cr.set_line_width(1)
            cr.stroke()
            self.rects.append((i, (x0, y0, cw, ch)))

    # ---------- appliquer ----------
    def demo(self, n):
        """Mode démo (--demo N) : défile tout seul et applique N fonds à la suite, puis se ferme."""
        import random
        etapes = []
        for _ in range(n):
            etapes += [('go', random.choice((2, 3, 4)))] * 1 + [('pause', 0)] + [('apply', 0)]
        def suite():
            if not etapes: self.quit(); return False
            a, v = etapes.pop(0)
            if a == 'go':
                for k in range(v): GLib.timeout_add(380 * (k + 1), lambda: (self.go(self.target + 1), False)[1])
                GLib.timeout_add(380 * v + 900, suite)
            elif a == 'pause':
                GLib.timeout_add(500, suite)
            else:
                self.apply(garder=True); GLib.timeout_add(2600, suite)
            return False
        GLib.timeout_add(1200, suite)

    def apply(self, garder=False):
        if not self.items: return
        path = self.items[self.target]; w = www()
        subprocess.run(['pkill', '-x', 'mpvpaper'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if w:
            subprocess.Popen([w, 'img', path, '--transition-type', 'grow', '--transition-pos', '0.5,0.5',
                              '--transition-duration', '1.2', '--transition-fps', '60'],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.isfile(WALLUST):
            subprocess.Popen([os.path.expanduser('~/.config/hypr/UserScripts/MemoFond.sh'), path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)  # fond mémorisé pour le démarrage
            subprocess.Popen(['bash', '-c', 'sleep 0.6; "$0" "$1"', WALLUST, path], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if garder: return                                       # mode démo : on reste ouvert
        subprocess.Popen(['notify-send', '-i', path, 'Fond d\'écran', os.path.basename(path)],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.quit()

    def quit(self, *_):
        if getattr(self, 'done', False): return False
        self.done = True
        try: os.remove(PID)
        except Exception: pass
        Gtk.main_quit(); return False

if __name__ == '__main__':
    if os.path.exists(PID):   # 2e appui sur le raccourci = fermer
        try:
            os.kill(int(open(PID).read().strip()), signal.SIGTERM); sys.exit(0)
        except (ProcessLookupError, ValueError, PermissionError):
            pass
    open(PID, 'w').write(str(os.getpid()))
    w = Carousel(); w.show_all(); w.entry.grab_focus()
    if '--demo' in sys.argv:
        try: w.demo(int(sys.argv[sys.argv.index('--demo') + 1]))
        except (IndexError, ValueError): w.demo(3)
    for sg in (signal.SIGTERM, signal.SIGINT):
        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, sg, w.quit)
    Gtk.main()
