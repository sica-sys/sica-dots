#!/usr/bin/env python3
# Affiche une image de la vidéo en plein écran pour y encadrer la zone à flouter (slurp par-dessus).
# Usage : FlouCadre.py image.png     (fermé par DemoFlou.py une fois la zone choisie)
import sys
import gi, cairo
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False

pix = GdkPixbuf.Pixbuf.new_from_file(sys.argv[1])
win = Gtk.Window(title='demo-flou-cadre')
if LS:
    GtkLayerShell.init_for_window(win); GtkLayerShell.set_namespace(win, 'demo-flou-cadre')
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    for e in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
        GtkLayerShell.set_anchor(win, e, True)
    GtkLayerShell.set_exclusive_zone(win, -1)
else:
    win.fullscreen()
area = Gtk.DrawingArea(); win.add(area)


def dessin(w_, cr):
    w, h = w_.get_allocated_width(), w_.get_allocated_height()
    cr.save(); cr.scale(w / pix.get_width(), h / pix.get_height())
    Gdk.cairo_set_source_pixbuf(cr, pix, 0, 0); cr.paint(); cr.restore()
    cr.set_source_rgba(0.07, 0.06, 0.1, 0.8); cr.rectangle(0, 0, w, 44); cr.fill()
    cr.set_source_rgba(1, 1, 1, 1); cr.select_font_face('Sans', 0, 1); cr.set_font_size(18)
    cr.move_to(16, 29); cr.show_text("Encadre la zone à flouter (clic simple = tout l'écran · Échap = annuler)")


area.connect('draw', dessin)
win.show_all()
GLib.timeout_add_seconds(120, Gtk.main_quit)
Gtk.main()
