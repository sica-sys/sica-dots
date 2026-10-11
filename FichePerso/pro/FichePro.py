#!/usr/bin/env python3
# Fiche pro (clic droit sur le bouton profil de la Waybar). Tout le contenu vient de pro.conf (même dossier).
# Échap ou « Fermer » pour quitter ; relancer le script la referme si elle est déjà ouverte.
import os, sys, subprocess, html
D = os.path.dirname(os.path.abspath(__file__))
PID = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'fiche-pro.pid')
try:                                                  # déjà ouverte → on la ferme (bascule)
    p = int(open(PID).read())
    if 'FichePro' in open('/proc/%d/cmdline' % p).read():
        os.kill(p, 15); os.remove(PID); sys.exit(0)
except (OSError, ValueError):
    pass
open(PID, 'w').write(str(os.getpid()))

import gi
gi.require_version('Gtk', '3.0'); gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk, GdkPixbuf, Pango
try:
    gi.require_version('GtkLayerShell', '0.1'); from gi.repository import GtkLayerShell; LS = True
except Exception:
    LS = False
sys.path.insert(0, os.path.expanduser('~/.config/hypr/UserScripts'))
try:
    from CavaLiquide import conf, palette, hexrgb, rgbhex
    CS = [rgbhex(c) for c in (palette(conf(), pour_waybar=True) or [hexrgb('#c678dd')])]
except Exception:
    CS = ['#c678dd']
C1, C2 = CS[0], CS[-1]


def lire():
    d = {}
    for l in open(os.path.join(D, 'pro.conf'), encoding='utf-8'):
        if '=' in l and not l.lstrip().startswith('#'):
            k, v = l.rstrip('\n').split('=', 1); d.setdefault(k.strip(), []).append(v.strip())
    return d


P = lire()
CHOIX = os.path.join(D, 'choix.txt')
try: STYLE = (open(CHOIX).read().strip() or 'A')[0].upper()
except OSError: STYLE = 'A'
if STYLE not in 'ABC': STYLE = 'A'   # A = classique (2 colonnes) · B = carte de visite · C = néon
un = lambda k: (P.get(k) or [''])[0]
liste = lambda k: [x for x in P.get(k, []) if x]

CSS = '''
window { background: transparent; }
#carte { background: rgba(21,18,31,0.94); border: 2px solid %(c1)s; border-radius: 18px; padding: 26px 30px; }
#nom { font-size: 26px; font-weight: bold; color: #f4f1ff; }
#titre { font-size: 14px; color: #c9c3e6; }
#contact { font-size: 13px; color: %(c2)s; }
.sect { font-size: 12px; font-weight: bold; color: %(c1)s; margin-top: 14px; margin-bottom: 4px; }
.txt { font-size: 13px; color: #d9d4ee; }
.petit { font-size: 12px; color: #9f97c4; }
.tag { background: alpha(%(c1)s, 0.16); color: #ece6ff; border-radius: 999px; padding: 3px 10px; font-size: 12px; }
#initiales { background: alpha(%(c1)s, 0.25); border: 3px solid %(c1)s; border-radius: 999px; color: #f4f1ff; font-size: 30px; font-weight: bold; min-width: 92px; min-height: 92px; }
button { background: transparent; color: #ece6ff; border: 1px solid #4a4466; border-radius: 10px; padding: 6px 14px; box-shadow: none; }
button:hover { background: alpha(%(c1)s, 0.22); border-color: %(c1)s; }
#ok { color: %(c2)s; font-size: 12px; }
#aide { color: #6f6a88; font-size: 11px; }
''' % {'c1': C1, 'c2': C2}
if STYLE == 'B':      # carte de visite : compacte, centrée
    CSS += '''
#carte { padding: 30px 40px; border-radius: 24px; }
#nom { font-size: 30px; } #titre, #contact { font-size: 14px; }
#initiales { min-width: 110px; min-height: 110px; font-size: 36px; }
'''
if STYLE == 'C':      # néon : noir profond, contours lumineux, titres en mono
    CSS += '''
#carte { background: rgba(6,6,10,0.96); border: 2px solid %(c1)s; border-radius: 6px; box-shadow: 0 0 22px alpha(%(c1)s,0.55); }
#nom { font-family: monospace; color: %(c1)s; letter-spacing: 2px; }
.sect { font-family: monospace; color: %(c2)s; border-bottom: 1px solid alpha(%(c1)s,0.5); padding-bottom: 2px; }
.tag { background: transparent; border: 1px solid %(c1)s; color: %(c1)s; border-radius: 3px; }
#initiales { border-radius: 6px; background: transparent; color: %(c1)s; font-family: monospace; }
button { border-radius: 3px; border-color: %(c1)s; color: %(c1)s; font-family: monospace; }
''' % {'c1': C1, 'c2': C2}


def lab(t, cls=None, name=None, wrap=False, sel=False):
    l = Gtk.Label(); l.set_markup(t); l.set_xalign(0)
    if wrap: l.set_line_wrap(True); l.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR); l.set_max_width_chars(60)
    if cls: l.get_style_context().add_class(cls)
    if name: l.set_name(name)
    l.set_selectable(sel)
    return l


def tags(items):
    f = Gtk.FlowBox(); f.set_selection_mode(Gtk.SelectionMode.NONE); f.set_max_children_per_line(4)
    f.set_column_spacing(6); f.set_row_spacing(6); f.set_homogeneous(False)
    for t in items:
        f.add(lab(html.escape(t), 'tag'))
    return f


def bloc(boite, titre, lignes):
    if not lignes: return
    boite.pack_start(lab(titre.upper(), 'sect'), False, False, 0)
    for x in lignes:
        p = [s.strip() for s in x.split('|')] + ['', '']
        boite.pack_start(lab('<b>%s</b>' % html.escape(p[0]), 'txt', wrap=True), False, False, 0)
        sous = ' · '.join(s for s in (p[2], p[1]) if s)
        if sous: boite.pack_start(lab(html.escape(sous), 'petit', wrap=True), False, False, 2)


win = Gtk.Window(title='fiche-pro')
win.set_app_paintable(True)
v = win.get_screen().get_rgba_visual()
if v: win.set_visual(v)
if LS:
    GtkLayerShell.init_for_window(win); GtkLayerShell.set_namespace(win, 'fiche-pro')
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    try: GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.EXCLUSIVE)
    except Exception: GtkLayerShell.set_keyboard_interactivity(win, True)
prov = Gtk.CssProvider(); prov.load_from_data(CSS.encode())
Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

carte = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4); carte.set_name('carte')
carte.set_size_request(860, -1)

# en-tête : photo ou initiales, nom, titre, contact
haut = Gtk.Box(spacing=20)
photo = os.path.expanduser(un('PHOTO'))
if photo and os.path.exists(photo):
    try:
        pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(photo, 96, 96, True)
        haut.pack_start(Gtk.Image.new_from_pixbuf(pb), False, False, 0)
    except Exception:
        photo = ''
if not (photo and os.path.exists(photo)):
    ini = ''.join(w[0] for w in un('NOM').split()[:2]).upper() or '?'
    i = lab(ini, name='initiales'); i.set_xalign(0.5); i.set_valign(Gtk.Align.CENTER)
    haut.pack_start(i, False, False, 0)
tete = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4); tete.set_valign(Gtk.Align.CENTER)
tete.pack_start(lab(html.escape(un('NOM')), name='nom'), False, False, 0)
if un('TITRE'): tete.pack_start(lab(html.escape(un('TITRE')), name='titre', wrap=True), False, False, 0)
contact = '   ·   '.join(html.escape(x) for x in (un('EMAIL'), un('TELEPHONE'), un('VILLE')) if x)
if contact: tete.pack_start(lab(contact, name='contact', sel=True), False, False, 0)
haut.pack_start(tete, True, True, 0)
carte.pack_start(haut, False, False, 0)

if STYLE == 'B':
    haut.set_halign(Gtk.Align.CENTER)
if un('PROFIL') and STYLE != 'B':
    carte.pack_start(lab('PROFIL', 'sect'), False, False, 0)
    carte.pack_start(lab(html.escape(un('PROFIL')), 'txt', wrap=True), False, False, 0)

if STYLE == 'B':
    certs = [x.split('|')[0].strip() for x in liste('CERTIFICAT')]
    if certs:
        carte.pack_start(lab('CERTIFICATIONS', 'sect'), False, False, 0); carte.pack_start(tags(certs), False, False, 0)
    if liste('COMPETENCE'):
        carte.pack_start(lab('COMPÉTENCES', 'sect'), False, False, 0); carte.pack_start(tags(liste('COMPETENCE')), False, False, 0)
    carte.set_size_request(640, -1)
cols = Gtk.Box(spacing=36, homogeneous=True)
g = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
d_ = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
if liste('COMPETENCE'):
    g.pack_start(lab('COMPÉTENCES', 'sect'), False, False, 0); g.pack_start(tags(liste('COMPETENCE')), False, False, 0)
bloc(g, 'Certifications', liste('CERTIFICAT'))
bloc(g, 'Formation', liste('FORMATION'))
bloc(d_, 'Expérience', liste('EXPERIENCE'))
if liste('INTERET'):
    d_.pack_start(lab("CENTRES D'INTÉRÊT", 'sect'), False, False, 0); d_.pack_start(tags(liste('INTERET')), False, False, 0)
cols.pack_start(g, True, True, 0); cols.pack_start(d_, True, True, 0)
if STYLE != 'B': carte.pack_start(cols, False, False, 0)

# boutons
bas = Gtk.Box(spacing=8); bas.set_margin_top(18)
ok = lab('', name='ok')


def bouton(txt, fn):
    b = Gtk.Button(label=txt); b.connect('clicked', lambda *_: fn()); bas.pack_start(b, False, False, 0)


def ouvrir(u):
    subprocess.Popen(['xdg-open', u], start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


if un('EMAIL'):
    def copier():
        subprocess.run(['wl-copy'], input=un('EMAIL').encode()); ok.set_text('  ✓ email copié')
    bouton('✉  Copier mon email', copier)
cv = un('CV')
if cv:
    cvp = cv if os.path.isabs(os.path.expanduser(cv)) else os.path.join(D, cv)
    cvp = os.path.expanduser(cvp)
    if os.path.exists(cvp): bouton('📄  Mon CV', lambda: ouvrir(cvp))
for k, t in (('LINKEDIN', 'LinkedIn'), ('GITHUB', 'GitHub'), ('SITE', 'Site')):
    if un(k): bouton('🔗  ' + t, (lambda u: lambda: ouvrir(u))(un(k)))
bas.pack_start(ok, False, False, 0)
fermer = Gtk.Button(label='Fermer  (Échap)'); fermer.connect('clicked', lambda *_: Gtk.main_quit())
bas.pack_end(fermer, False, False, 0)
bas.pack_end(lab('A · B · C = style   ', name='aide'), False, False, 0)
carte.pack_start(bas, False, False, 0)

win.add(carte)
def touche(w, e):
    if e.keyval == Gdk.KEY_Escape: Gtk.main_quit(); return
    k = Gdk.keyval_name(e.keyval) or ''
    if k.upper() in ('A', 'B', 'C'):                 # changer de style : mémorisé, la fiche se rouvre
        open(CHOIX, 'w').write(k.upper())
        try: os.remove(PID)
        except OSError: pass
        os.execv(sys.executable, [sys.executable, os.path.abspath(__file__)])
win.connect('key-press-event', touche)
win.connect('destroy', Gtk.main_quit)
win.show_all()
try:
    Gtk.main()
finally:
    try: os.remove(PID)
    except OSError: pass
