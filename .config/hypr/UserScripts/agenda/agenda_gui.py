#!/usr/bin/env python3
# Agenda / Météo pour Waybar — modes : mini | grand [AAAA-MM-JJ] | meteo
import sys, os, json, threading, subprocess, calendar, urllib.request, datetime as dt
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib, Pango

MODE = sys.argv[1] if len(sys.argv) > 1 else "mini"
GLib.set_prgname({"mini": "agenda-mini", "grand": "agenda-grand", "meteo": "meteo-carte"}.get(MODE, "agenda-mini"))
HERE = os.path.dirname(os.path.realpath(__file__))
V = Gtk.Orientation.VERTICAL
MOIS = ["janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]
JOURS = ["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"]

def css():
    p = Gtk.CssProvider()
    try: p.load_from_path(os.path.join(HERE, "style.css"))
    except Exception as e: print("CSS :", e)
    Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), p, Gtk.STYLE_PROVIDER_PRIORITY_USER)

def cls(w, *noms):
    for n in noms: w.get_style_context().add_class(n)
    return w

def label(txt, *noms, x=0.5):
    return cls(Gtk.Label(label=txt, xalign=x), *noms)

def carte(inner, *noms, marge=10):
    inner.set_border_width(marge); e = cls(Gtk.EventBox(), *noms); e.add(inner); return e

def fenetre(titre, w, h):
    win = Gtk.Window(title=titre); win.set_default_size(w, h)
    v = win.get_screen().get_rgba_visual()
    if v: win.set_visual(v)
    win.connect("destroy", Gtk.main_quit)
    win.connect("key-press-event", lambda w, e: Gtk.main_quit() if e.keyval == Gdk.KEY_Escape else False)
    return win

def evenements(debut, fin):
    res = {}
    try:
        out = subprocess.run(["khal", "list", "--day-format", "", "--format", "{start-date-long}|{start-time}|{title}",
                              debut.strftime("%d/%m/%Y"), fin.strftime("%d/%m/%Y")],
                             capture_output=True, text=True, timeout=10).stdout
    except Exception as e:
        print("khal :", e); return res
    for ligne in out.splitlines():
        p = ligne.split("|", 2)
        if len(p) < 3: continue
        try: d = dt.datetime.strptime(p[0].strip(), "%d/%m/%Y").date()
        except ValueError: continue
        h = p[1].strip()
        res.setdefault(d, []).append((h + "  " if h else "") + p[2].strip())
    return res

class Mini:
    def __init__(self):
        self.auj = dt.date.today(); self.a, self.m = self.auj.year, self.auj.month
        self.win = fenetre("Calendrier", 320, 340)
        box = Gtk.Box(orientation=V, spacing=8); box.set_border_width(14)
        tete = Gtk.Box(spacing=6)
        b1 = cls(Gtk.Button(label="‹"), "nav"); b2 = cls(Gtk.Button(label="›"), "nav")
        self.titre = label("", "title")
        b1.connect("clicked", lambda *_: self.decale(-1)); b2.connect("clicked", lambda *_: self.decale(1))
        tete.pack_start(b1, False, False, 0); tete.pack_start(self.titre, True, True, 0); tete.pack_start(b2, False, False, 0)
        self.grille = Gtk.Grid(column_homogeneous=True, row_spacing=3, column_spacing=3)
        ev = evenements(self.auj, self.auj + dt.timedelta(days=1)).get(self.auj, [])
        pied = label("Aujourd'hui · " + (", ".join(ev) if ev else "aucun événement"), "foot", x=0); pied.set_line_wrap(True)
        for w in (tete, self.grille, Gtk.Separator(), pied): box.pack_start(w, False, False, 0)
        self.win.add(box); self.remplir(); self.win.show_all()
    def decale(self, n):
        m = self.m - 1 + n; self.a += m // 12; self.m = m % 12 + 1; self.remplir()
    def remplir(self):
        for c in self.grille.get_children(): self.grille.remove(c)
        self.titre.set_text(f"{MOIS[self.m-1]} {self.a}")
        for i, j in enumerate(["lu","ma","me","je","ve","sa","di"]): self.grille.attach(label(j, "dow"), i, 0, 1, 1)
        premier = dt.date(self.a, self.m, 1); n = calendar.monthrange(self.a, self.m)[1]
        ev = evenements(premier, premier + dt.timedelta(days=n))
        for d in range(1, n + 1):
            jour = dt.date(self.a, self.m, d); pos = premier.weekday() + d - 1
            b = cls(Gtk.Button(label=str(d)), "day")
            if jour == self.auj: cls(b, "today")
            if jour in ev: cls(b, "has-event"); b.set_tooltip_text("\n".join(ev[jour]))
            b.connect("clicked", self.ouvrir, jour)
            self.grille.attach(b, pos % 7, 1 + pos // 7, 1, 1)
        self.grille.show_all()
    def ouvrir(self, _b, jour):
        subprocess.Popen([sys.executable, os.path.realpath(__file__), "grand", jour.isoformat()], start_new_session=True)
        Gtk.main_quit()

class Grand:
    def __init__(self, sel):
        self.auj = dt.date.today(); self.sel = sel; self.ev = {}
        self.win = fenetre("Agenda", 1100, 720)
        box = Gtk.Box(orientation=V, spacing=10); box.set_border_width(16)
        tete = Gtk.Box(spacing=6)
        prec = cls(Gtk.Button(label="‹"), "nav"); suiv = cls(Gtk.Button(label="›"), "nav")
        self.titre = label("", "title-big", x=0)
        auj = Gtk.Button(label="Aujourd'hui"); nouv = cls(Gtk.Button(label="+ Nouveau"), "accent")
        prec.connect("clicked", lambda *_: self.mois(-1)); suiv.connect("clicked", lambda *_: self.mois(1))
        auj.connect("clicked", lambda *_: self.choisir(self.auj)); nouv.connect("clicked", lambda *_: self.nouveau(self.sel))
        tete.pack_start(prec, False, False, 0); tete.pack_start(self.titre, False, False, 8); tete.pack_start(suiv, False, False, 0)
        tete.pack_end(nouv, False, False, 0); tete.pack_end(auj, False, False, 0)
        corps = Gtk.Box(spacing=12)
        self.grille = Gtk.Grid(column_homogeneous=True, row_spacing=4, column_spacing=4, hexpand=True, vexpand=True)
        cote = Gtk.Box(orientation=V, spacing=8)
        self.cote_titre = label("", "title", x=0); self.cote_liste = Gtk.Box(orientation=V, spacing=6)
        ajout = Gtk.Button(label="+ Ajouter ce jour"); ajout.connect("clicked", lambda *_: self.nouveau(self.sel))
        cote.pack_start(self.cote_titre, False, False, 0); cote.pack_start(self.cote_liste, False, False, 0); cote.pack_end(ajout, False, False, 0)
        c = carte(cote, "side", marge=12); c.set_size_request(270, -1)
        corps.pack_start(self.grille, True, True, 0); corps.pack_start(c, False, False, 0)
        box.pack_start(tete, False, False, 0); box.pack_start(corps, True, True, 0)
        self.win.add(box); self.remplir(); self.win.show_all()
    def mois(self, n):
        m = self.sel.month - 1 + n; self.choisir(dt.date(self.sel.year + m // 12, m % 12 + 1, 1))
    def choisir(self, j): self.sel = j; self.remplir()
    def remplir(self):
        for c in self.grille.get_children(): self.grille.remove(c)
        a, m = self.sel.year, self.sel.month
        self.titre.set_text(f"{MOIS[m-1].capitalize()} {a}")
        for i, j in enumerate(JOURS): self.grille.attach(label(j[:3] + ".", "dow"), i, 0, 1, 1)
        premier = dt.date(a, m, 1); n = calendar.monthrange(a, m)[1]
        self.ev = evenements(premier, premier + dt.timedelta(days=n))
        for d in range(1, n + 1):
            jour = dt.date(a, m, d); pos = premier.weekday() + d - 1
            b = cls(Gtk.Button(), "cell"); b.set_size_request(-1, 92)
            if jour == self.auj: cls(b, "today")
            if jour == self.sel: cls(b, "selected")
            v = Gtk.Box(orientation=V, spacing=2); v.set_valign(Gtk.Align.START)
            v.pack_start(label(str(d), "num", x=0), False, False, 0)
            evs = self.ev.get(jour, [])
            for e in evs[:3]:
                l = label(e, "chip", x=0); l.set_ellipsize(Pango.EllipsizeMode.END); v.pack_start(l, False, False, 0)
            if len(evs) > 3: v.pack_start(label(f"+{len(evs)-3}", "more", x=0), False, False, 0)
            b.add(v); b.connect("clicked", lambda _b, j=jour: self.choisir(j))
            self.grille.attach(b, pos % 7, 1 + pos // 7, 1, 1)
        self.grille.show_all(); self.remplir_cote()
    def remplir_cote(self):
        for c in self.cote_liste.get_children(): self.cote_liste.remove(c)
        j = self.sel
        self.cote_titre.set_text(f"{JOURS[j.weekday()].capitalize()} {j.day} {MOIS[j.month-1]}")
        evs = self.ev.get(j, [])
        if not evs: self.cote_liste.pack_start(label("Aucun événement", "muted", x=0), False, False, 0)
        for e in evs:
            l = label(e, x=0); l.set_line_wrap(True); self.cote_liste.pack_start(carte(l, "event", marge=7), False, False, 0)
        self.cote_liste.show_all()
    def nouveau(self, jour):
        d = Gtk.Dialog(title="Nouvel événement", transient_for=self.win, modal=True)
        d.add_buttons("Annuler", Gtk.ResponseType.CANCEL, "Ajouter", Gtk.ResponseType.OK)
        d.set_default_response(Gtk.ResponseType.OK)
        g = Gtk.Grid(row_spacing=8, column_spacing=10); g.set_border_width(14)
        ch = {}
        for i, (k, t, val) in enumerate([("titre", "Titre", ""), ("date", "Date (jj/mm/aaaa)", jour.strftime("%d/%m/%Y")),
                                         ("debut", "Début (hh:mm, vide = journée)", ""), ("fin", "Fin (hh:mm, optionnel)", "")]):
            e = Gtk.Entry(text=val, activates_default=True, hexpand=True); ch[k] = e
            g.attach(label(t, x=0), 0, i, 1, 1); g.attach(e, 1, i, 1, 1)
        d.get_content_area().add(g); d.show_all()
        if d.run() == Gtk.ResponseType.OK and ch["titre"].get_text().strip():
            date, deb, fin = (ch[k].get_text().strip() for k in ("date", "debut", "fin"))
            args = ["khal", "new", date] + ([deb] if deb else []) + ([fin] if deb and fin else []) + [ch["titre"].get_text().strip()]
            r = subprocess.run(args, capture_output=True, text=True)
            if r.returncode: print(r.stderr)
            try: self.sel = dt.datetime.strptime(date, "%d/%m/%Y").date()
            except ValueError: pass
        d.destroy(); self.remplir()

def icone(code):
    c = int(code)
    if c == 113: return "☀️"
    if c == 116: return "⛅"
    if c in (119, 122): return "☁️"
    if c in (143, 248, 260): return "🌫️"
    if c in (200, 386, 389, 392, 395): return "⛈️"
    if c in (179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371): return "❄️"
    return "🌧️"

class Meteo:
    def __init__(self):
        self.win = fenetre("Météo", 720, 340)
        self.box = Gtk.Box(spacing=18); self.box.set_border_width(18)
        self.box.pack_start(label("Chargement de la météo…", "muted"), True, True, 0)
        self.win.add(self.box); self.win.show_all()
        threading.Thread(target=self.charger, daemon=True).start()
    def charger(self):
        try:
            req = urllib.request.Request("https://wttr.in/?format=j1&lang=fr", headers={"User-Agent": "curl/8"})
            GLib.idle_add(self.afficher, json.load(urllib.request.urlopen(req, timeout=12)))
        except Exception as e:
            GLib.idle_add(self.erreur, str(e))
    def vider(self):
        for c in self.box.get_children(): self.box.remove(c)
    def erreur(self, msg):
        self.vider(); self.box.pack_start(label("Météo indisponible\n" + msg, "muted"), True, True, 0); self.box.show_all()
    def afficher(self, d):
        self.vider()
        cur = d["current_condition"][0]; auj = dt.date.today()
        lieu = d.get("nearest_area", [{}])[0].get("areaName", [{"value": ""}])[0]["value"]
        desc = (cur.get("lang_fr") or cur["weatherDesc"])[0]["value"]
        g = Gtk.Box(orientation=V, spacing=4); g.set_valign(Gtk.Align.CENTER)
        g.pack_start(label(f"{lieu} · {JOURS[auj.weekday()]} {auj.day} {MOIS[auj.month-1]}", "muted", x=0), False, False, 0)
        ligne = Gtk.Box(spacing=10)
        ligne.pack_start(label(icone(cur["weatherCode"]), "icon-big"), False, False, 0)
        ligne.pack_start(label(f'{cur["temp_C"]}°', "big-temp"), False, False, 0)
        g.pack_start(ligne, False, False, 0)
        g.pack_start(label(f'{desc} · ressenti {cur["FeelsLikeC"]}°', "info", x=0), False, False, 0)
        g.pack_start(label(f'Vent {cur["windspeedKmph"]} km/h · humidité {cur["humidity"]} %', "muted", x=0), False, False, 0)
        dr = Gtk.Box(spacing=10, homogeneous=True)
        for j in d["weather"][:3]:
            date = dt.date.fromisoformat(j["date"]); h = j["hourly"][len(j["hourly"]) // 2]
            pluie = max(int(x.get("chanceofrain", 0)) for x in j["hourly"])
            nom = "Aujourd'hui" if date == auj else f"{JOURS[date.weekday()][:3]}. {date.day}"
            c = Gtk.Box(orientation=V, spacing=4)
            for t, k in ((nom, "muted"), (icone(h["weatherCode"]), "icon"), (f'{j["maxtempC"]}° / {j["mintempC"]}°', "info"),
                         ((h.get("lang_fr") or h["weatherDesc"])[0]["value"], "muted"), (f"pluie {pluie} %", "muted")):
                l = label(t, k); l.set_line_wrap(True); c.pack_start(l, False, False, 0)
            dr.pack_start(carte(c, "card"), True, True, 0)
        self.box.pack_start(g, False, False, 0); self.box.pack_start(dr, True, True, 0); self.box.show_all()

css()
if MODE == "grand":
    try: j = dt.date.fromisoformat(sys.argv[2])
    except (IndexError, ValueError): j = dt.date.today()
    Grand(j)
elif MODE == "meteo": Meteo()
else: Mini()
Gtk.main()
