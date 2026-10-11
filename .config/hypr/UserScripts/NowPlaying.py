#!/usr/bin/env python3
import os, sys, signal, subprocess, hashlib, urllib.parse, time, math
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False
PID = '/tmp/nowplaying-%d.pid' % os.getuid()
if os.path.exists(PID):
    try:
        os.kill(int(open(PID).read().strip()), signal.SIGTERM); sys.exit(0)
    except (ProcessLookupError, ValueError, PermissionError):
        pass
open(PID, 'w').write(str(os.getpid()))
HOME = os.path.expanduser('~'); CACHE = HOME + '/.cache/album-covers'
PICKER = HOME + '/.config/hypr/UserScripts/AlbumPicker.sh'
P = ['playerctl', '-p', 'mpv,%any']
I = dict(prev='󰒮', next='󰒭', play='󰐊', pause='󰏤', shuf='󰒟', rep='󰑖', rep1='󰑘', vol='󰕾', back='󰁍', close='󰅖')
def pc(*a):
    try: return subprocess.run(P + list(a), capture_output=True, text=True, timeout=1).stdout.strip()
    except Exception: return ''
def run(*a): subprocess.Popen(P + list(a), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
CAVA_CONF = HOME + '/.config/cava/config'
def cava_rgb():
    import re
    try: txt = open(CAVA_CONF).read()
    except Exception: return (0.91, 0.91, 0.91)
    for key in ('foreground', 'gradient_color_1'):
        m = re.search(r"^\s*%s\s*=\s*['\"]?#([0-9a-fA-F]{6})" % key, txt, re.M)
        if m: h = m.group(1); return tuple(int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
    return (0.91, 0.91, 0.91)
def fmt(s): s = int(s); return '%d:%02d' % (s // 60, s % 60)
CSS = b"""
window { background-color: transparent; }
#card { background-color: rgba(18,18,22,0.55); border-radius: 18px; border: 1px solid rgba(255,255,255,0.10); padding: 16px 18px; }
label { color: #e8e8e8; font-family: "JetBrainsMono Nerd Font"; }
#title { font-size: 15px; font-weight: bold; }
#sub, #time, #state { color: #a0a0a0; font-size: 12px; }
button { background: transparent; background-image: none; border: none; box-shadow: none; color: #d6d6d6; padding: 4px 8px; border-radius: 10px; font-size: 18px; }
button label { color: inherit; }
button:hover { background-color: rgba(255,255,255,0.10); }
#back { font-size: 13px; border: 1px solid rgba(255,255,255,0.14); }
#play { font-size: 22px; border: 1px solid rgba(255,255,255,0.22); border-radius: 24px; min-width: 44px; min-height: 44px; padding: 0; }
.on { color: #8fd0ff; }
scale trough { background-color: rgba(255,255,255,0.14); min-height: 4px; border-radius: 4px; border: none; }
scale highlight { background-color: #e8e8e8; border-radius: 4px; border: none; }
scale slider { background-color: #ffffff; background-image: none; min-width: 12px; min-height: 12px; border-radius: 6px; border: none; box-shadow: none; }
"""
def rrect(cr, x, y, w, h, r):
    r = min(r, w / 2, h / 2); cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -math.pi / 2, 0); cr.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    cr.arc(x + r, y + h - r, r, math.pi / 2, math.pi); cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2); cr.close_path()
class NP(Gtk.Window):
    def __init__(self):
        super().__init__(title='NowPlaying'); self.done = False
        v = self.get_screen().get_rgba_visual()
        if v: self.set_visual(v)
        self.set_app_paintable(True)
        if LS:
            GtkLayerShell.init_for_window(self); GtkLayerShell.set_namespace(self, 'nowplaying')
            GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
            for e, m in ((GtkLayerShell.Edge.TOP, 6), (GtkLayerShell.Edge.LEFT, 10)):
                GtkLayerShell.set_anchor(self, e, True); GtkLayerShell.set_margin(self, e, m)
            try: GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)
            except Exception:
                try: GtkLayerShell.set_keyboard_interactivity(self, True)
                except Exception: pass
        else:
            self.set_decorated(False)
        prov = Gtk.CssProvider(); prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(self.get_screen(), prov, 800)
        self.connect('key-press-event', lambda w, e: self.quit() if e.keyval == Gdk.KEY_Escape else False)
        self.connect('destroy', self.quit)
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10); card.set_name('card'); card.set_size_request(380, -1); self.add(card)
        head = Gtk.Box(spacing=8)
        self.state = Gtk.Label(); self.state.set_name('state')
        head.pack_start(self.btn(I['back'] + '  Albums', self.albums, 'back'), False, False, 0)
        head.pack_start(self.state, True, True, 0)
        head.pack_end(self.btn(I['close'], self.quit), False, False, 0); card.add(head)
        mid = Gtk.Box(spacing=14)
        self.cover = Gtk.DrawingArea(); self.cover.set_size_request(96, 96); self.cover.connect('draw', self.draw_cover)
        self.pix = None; self.cover_path = 0
        info = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        self.title = Gtk.Label(xalign=0); self.title.set_name('title'); self.title.set_ellipsize(3); self.title.set_max_width_chars(24)
        self.sub = Gtk.Label(xalign=0); self.sub.set_name('sub'); self.sub.set_ellipsize(3); self.sub.set_max_width_chars(30)
        self.viz = Gtk.DrawingArea(); self.viz.set_size_request(240, 36); self.viz.connect('draw', self.draw_viz)
        info.pack_start(self.title, False, False, 0); info.pack_start(self.sub, False, False, 0); info.pack_end(self.viz, False, False, 0)
        mid.pack_start(self.cover, False, False, 0); mid.pack_start(info, True, True, 0); card.add(mid)
        self.prog = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 1); self.prog.set_draw_value(False)
        self.seek = None; self.L = 0
        self.prog.connect('change-value', self.on_seek); self.prog.connect('button-release-event', self.on_seek_done); card.add(self.prog)
        times = Gtk.Box(); self.t0 = Gtk.Label(xalign=0); self.t1 = Gtk.Label(xalign=1)
        for l in (self.t0, self.t1): l.set_name('time')
        times.pack_start(self.t0, True, True, 0); times.pack_end(self.t1, True, True, 0); card.add(times)
        ctl = Gtk.Box(spacing=14); ctl.set_halign(Gtk.Align.CENTER)
        self.bshuf = self.btn(I['shuf'], lambda *_: run('shuffle', 'toggle'))
        self.bplay = self.btn(I['play'], lambda *_: run('play-pause'), 'play')
        self.brep = self.btn(I['rep'], self.cycle_loop)
        for b in (self.bshuf, self.btn(I['prev'], lambda *_: run('previous')), self.bplay, self.btn(I['next'], lambda *_: run('next')), self.brep):
            ctl.pack_start(b, False, False, 0)
        card.add(ctl)
        vb = Gtk.Box(spacing=10); vl = Gtk.Label(label=I['vol']); vl.set_name('sub')
        self.vol = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 0.01); self.vol.set_draw_value(False); self.vol_t = 0
        self.vol.connect('change-value', self.on_vol)
        vb.pack_start(vl, False, False, 0); vb.pack_start(self.vol, True, True, 0); card.add(vb)
        self.bars = [0] * 24; self.buf = b''; self.cava = None
        conf = '/tmp/nowplaying-cava-%d.conf' % os.getuid()
        open(conf, 'w').write('[general]\nbars = 24\nframerate = 30\n[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 100\nbar_delimiter = 59\nframe_delimiter = 10\n')
        try:
            self.cava = subprocess.Popen(['cava', '-p', conf], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            GLib.io_add_watch(self.cava.stdout.fileno(), GLib.PRIORITY_DEFAULT, GLib.IO_IN | GLib.IO_HUP, self.on_cava)
        except Exception: self.cava = None
        self.cprov = Gtk.CssProvider(); Gtk.StyleContext.add_provider_for_screen(self.get_screen(), self.cprov, 801)
        self.cm = None; self.rgb = (0.91, 0.91, 0.91); self.recolor()
    def recolor(self):
        try: m = os.path.getmtime(CAVA_CONF)
        except OSError: m = 0
        if m == self.cm: return
        self.cm = m; self.rgb = cava_rgb(); h = '#%02x%02x%02x' % tuple(round(c * 255) for c in self.rgb)
        self.cprov.load_from_data(('scale highlight { background-color: %s; } scale slider { background-color: %s; } .on { color: %s; } #play { border-color: %s; }' % (h, h, h, h)).encode())
        self.viz.queue_draw()
    def btn(self, label, cb, name=None):
        b = Gtk.Button(label=label); b.set_relief(Gtk.ReliefStyle.NONE)
        if name: b.set_name(name)
        b.connect('clicked', cb); return b
    def toggle(self, b, on):
        c = b.get_style_context(); c.add_class('on') if on else c.remove_class('on')
    def on_seek(self, r, s, v): self.seek = v; return False
    def on_seek_done(self, *_):
        if self.seek is not None: run('position', str(int(self.seek)))
        self.seek = None; return False
    def on_vol(self, r, s, v): self.vol_t = time.time(); run('volume', '%.2f' % max(0, min(1, v))); return False
    def cycle_loop(self, *_): run('loop', {'None': 'Playlist', 'Playlist': 'Track'}.get(pc('loop'), 'None'))
    def albums(self, *_): subprocess.Popen([PICKER], start_new_session=True); self.quit()
    def on_cava(self, fd, cond):
        if cond & GLib.IO_HUP: return False
        data = os.read(fd, 8192)
        if not data: return False
        self.buf += data; parts = self.buf.split(b'\n'); self.buf = parts[-1]
        if len(parts) > 1:
            vals = [int(x) for x in parts[-2].split(b';') if x.strip().isdigit()]
            if vals: self.bars = vals; self.viz.queue_draw()
        return True
    def draw_viz(self, w, cr):
        W, H = w.get_allocated_width(), w.get_allocated_height(); n = len(self.bars) or 1; gap = 3
        bw = (W - gap * (n - 1)) / n; cr.set_source_rgba(*self.rgb, 0.85)
        for i, v in enumerate(self.bars):
            h = max(2, v / 100 * H); rrect(cr, i * (bw + gap), H - h, bw, h, 2); cr.fill()
    def draw_cover(self, w, cr):
        rrect(cr, 0, 0, 96, 96, 12); cr.clip()
        if self.pix: Gdk.cairo_set_source_pixbuf(cr, self.pix, 0, 0)
        else: cr.set_source_rgba(1, 1, 1, 0.08)
        cr.paint()
    def set_cover(self, path):
        if path == self.cover_path: return
        self.cover_path = path; self.pix = None
        if path and os.path.isfile(path):
            try:
                p = GdkPixbuf.Pixbuf.new_from_file(path); s = 96 / min(p.get_width(), p.get_height())
                w, h = max(96, round(p.get_width() * s)), max(96, round(p.get_height() * s))
                p = p.scale_simple(w, h, GdkPixbuf.InterpType.BILINEAR); self.pix = p.new_subpixbuf((w - 96) // 2, (h - 96) // 2, 96, 96)
            except Exception: pass
        self.cover.queue_draw()
    def update(self):
        if self.done: return False
        self.recolor()
        o = pc('metadata', '--format', '{{status}}\t{{title}}\t{{artist}}\t{{album}}\t{{mpris:artUrl}}\t{{position}}\t{{mpris:length}}\t{{xesam:url}}\t{{volume}}')
        if not o:
            self.title.set_text('Rien en lecture'); self.sub.set_text('Choisis un album'); self.state.set_text('')
            self.bplay.set_label(I['play']); self.set_cover(None); self.bars = [0] * 24; self.viz.queue_draw(); return True
        st, ti, ar, al, art, pos, ln, url, vol = (o.split('\t') + [''] * 9)[:9]
        path = urllib.parse.unquote(url[7:]) if url.startswith('file://') else ''
        self.title.set_text(ti or os.path.splitext(os.path.basename(path))[0] or 'Sans titre')
        self.sub.set_text(' · '.join(x for x in (ar, al) if x) or os.path.basename(os.path.dirname(path)))
        self.state.set_text({'Playing': 'En lecture', 'Paused': 'En pause'}.get(st, st))
        self.bplay.set_label(I['pause'] if st == 'Playing' else I['play'])
        cover = urllib.parse.unquote(art[7:]) if art.startswith('file://') else None
        if not (cover and os.path.isfile(cover)) and path:
            cover = '%s/%s.jpg' % (CACHE, hashlib.md5(os.path.dirname(path).encode()).hexdigest()[:16])
        self.set_cover(cover)
        try: p, L = float(pos) / 1e6, float(ln) / 1e6
        except ValueError: p = L = 0
        if L > 0 and L != self.L: self.L = L; self.prog.set_range(0, L)
        if self.seek is None: self.prog.set_value(p)
        self.t0.set_text(fmt(p)); self.t1.set_text(fmt(L))
        if vol and time.time() - self.vol_t > 1:
            try: self.vol.set_value(float(vol))
            except ValueError: pass
        lp = pc('loop'); self.toggle(self.bshuf, pc('shuffle') == 'On')
        self.toggle(self.brep, lp in ('Playlist', 'Track')); self.brep.set_label(I['rep1'] if lp == 'Track' else I['rep'])
        if st != 'Playing': self.bars = [0] * 24; self.viz.queue_draw()
        return True
    def quit(self, *_):
        if self.done: return False
        self.done = True
        if self.cava:
            try: self.cava.kill()
            except Exception: pass
        try: os.remove(PID)
        except Exception: pass
        Gtk.main_quit(); return False
w = NP(); w.show_all(); w.update(); GLib.timeout_add(500, w.update)
for sg in (signal.SIGTERM, signal.SIGINT): GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, sg, w.quit)
Gtk.main()
