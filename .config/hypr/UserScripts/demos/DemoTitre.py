#!/usr/bin/env python3
# Grand titre au centre de l'écran pour les démos vidéo (fondu, couleur de la Cava).
# Usage : DemoTitre.py "Titre" ["sous-titre"] [durée en s]
import os, sys, math, time
import gi, cairo
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False
U = os.path.expanduser('~/.config/hypr/UserScripts'); sys.path.insert(0, U)
try:
    from CavaLiquide import conf, palette, hexrgb
    CS = palette(conf(), pour_waybar=True) or [hexrgb('#c678dd')]
except Exception:
    CS = [(0.78, 0.47, 0.87)]

TITRE = sys.argv[1] if len(sys.argv) > 1 else ''
SOUS = sys.argv[2] if len(sys.argv) > 2 else ''
DUREE = float(sys.argv[3]) if len(sys.argv) > 3 else 2.5
FONDU = 0.35
t0 = time.time()

win = Gtk.Window(title='demo-titre')
v = win.get_screen().get_rgba_visual()
if v: win.set_visual(v)
win.set_app_paintable(True)
if LS:
    GtkLayerShell.init_for_window(win); GtkLayerShell.set_namespace(win, 'demo-titre')
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    for e in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
        GtkLayerShell.set_anchor(win, e, True)
    GtkLayerShell.set_exclusive_zone(win, -1)
    try: GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.NONE)
    except Exception: pass
area = Gtk.DrawingArea(); win.add(area)


def texte(cr, s, taille, poids, y, w, alpha, grad):
    cr.select_font_face('Sans', cairo.FONT_SLANT_NORMAL, poids)
    cr.set_font_size(taille)
    e = cr.text_extents(s); x = (w - e.width) / 2 - e.x_bearing
    cr.move_to(x + 3, y + 3); cr.set_source_rgba(0, 0, 0, 0.55 * alpha); cr.show_text(s)   # ombre
    if grad and len(CS) > 1:
        g = cairo.LinearGradient(x, 0, x + e.width, 0)
        for i, c in enumerate(CS): g.add_color_stop_rgba(i / (len(CS) - 1), *c, alpha)
        cr.set_source(g)
    else:
        c = CS[0] if grad else (0.95, 0.94, 1.0); cr.set_source_rgba(*c, alpha)
    cr.move_to(x, y); cr.show_text(s)


def dessin(w_, cr):
    w, h = w_.get_allocated_width(), w_.get_allocated_height()
    cr.set_operator(cairo.OPERATOR_SOURCE); cr.set_source_rgba(0, 0, 0, 0); cr.paint()
    cr.set_operator(cairo.OPERATOR_OVER)
    t = time.time() - t0
    a = min(1, t / FONDU, max(0, (DUREE - t) / FONDU))
    a = a * a * (3 - 2 * a)
    monte = (1 - a) * 18
    # bandeau sombre derrière le texte
    bh = 190 if SOUS else 140
    cr.set_source_rgba(0.07, 0.06, 0.1, 0.55 * a); cr.rectangle(0, h / 2 - bh / 2 + monte, w, bh); cr.fill()
    taille = 76 if len(TITRE) < 24 else 56
    texte(cr, TITRE, taille, cairo.FONT_WEIGHT_BOLD, h / 2 + (0 if SOUS else 26) + monte, w, a, True)
    if SOUS:
        texte(cr, SOUS, 28, cairo.FONT_WEIGHT_NORMAL, h / 2 + 62 + monte, w, a, False)


def tick():
    area.queue_draw()
    if time.time() - t0 > DUREE:
        Gtk.main_quit(); return False
    return True


area.connect('draw', dessin)
win.show_all()
try: win.get_window().input_shape_combine_region(cairo.Region(), 0, 0)    # les clics passent à travers
except Exception: pass
GLib.timeout_add(16, tick)
Gtk.main()
