#!/usr/bin/env python3
# Flou des passages perso dans les vidéos (démos ou n'importe quel enregistrement wf-recorder).
#   DemoFlou.py                 → Super+Alt+F : début / fin d'un passage à flouter (pendant l'enregistrement)
#   DemoFlou.py --debut [plein] → début (zone à la souris, ou tout l'écran avec « plein »)
#   DemoFlou.py --fin           → fin du passage en cours
#   DemoFlou.py --appliquer VID → crée VID-flou.mp4 à partir des marques VID.flou (l'original reste intact)
#   DemoFlou.py --attacher VID  → range les marques de l'enregistrement qui vient de finir dans VID.flou
#   DemoFlou.py --apres         → « Flouter la dernière vidéo » : ajouter un passage après coup
#   DemoFlou.py --progres       → où en est le floutage (pourcentage, temps restant)
#   DemoFlou.py --ranger        → range les anciennes vidéos (numéros + originaux dans .originaux)
# Rangement : NN-nom.mp4 = vidéo sans flou · NN-nom-floutee.mp4 = version floutée à partager.
#             .originaux/NN-nom.mp4 (+ .flou = liste des passages) = l'original jamais modifié, pour refaire le flou.
import os, sys, glob, json, time, subprocess, re
RUN = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'demo'); os.makedirs(RUN, exist_ok=True)
D = os.path.dirname(os.path.abspath(__file__))
HOME = os.path.expanduser('~')
DOSSIERS = [HOME + '/Videos/Recordings', HOME + '/Videos/Demos', HOME + '/Vidéos', HOME + '/Videos']
MARGE = 0.4                                   # secondes ajoutées avant/après chaque passage


def notif(t, b=''):
    subprocess.run(['notify-send', '-a', 'Flou', '-t', '2500', t, b])


def sh(cmd, **k):
    return subprocess.run(cmd, capture_output=True, text=True, **k)


def rofi(prompt, lignes=(), mesg=None):
    rasi = HOME + '/.config/hypr/rofi/config-kitty-theme.rasi'
    c = ['rofi', '-dmenu', '-i', '-p', prompt]
    if os.path.exists(rasi): c += ['-config', rasi]
    if mesg: c += ['-mesg', mesg]
    return sh(c, input='\n'.join(lignes)).stdout.strip()


def ecran():
    """(largeur logique, hauteur logique, échelle) de l'écran actif."""
    try:
        for m in json.loads(sh(['hyprctl', 'monitors', '-j']).stdout):
            if m.get('focused'):
                s = float(m.get('scale', 1) or 1)
                return m['width'] / s, m['height'] / s, s, m.get('x', 0), m.get('y', 0)
    except Exception:
        pass
    return 1920, 1080, 1.0, 0, 0


def zone_souris(fond=None):
    """Zone encadrée avec slurp → 'x y w h' en pixels logiques, 'plein', ou None si annulé."""
    viewer = None
    if fond:
        viewer = subprocess.Popen(['python3', D + '/FlouCadre.py', fond]); time.sleep(0.8)
    r = sh(['slurp', '-f', '%x %y %w %h'])
    if viewer: viewer.terminate()
    if r.returncode != 0: return None
    try: x, y, w, h = map(int, r.stdout.split())
    except ValueError: return 'plein'
    if w < 20 or h < 20: return 'plein'
    _, _, _, ox, oy = ecran()
    return '%d %d %d %d' % (x - ox, y - oy, w, h)


# ------------------------------------------------------------------ pendant l'enregistrement
def enregistrement():
    """(identifiant, instant de départ) de l'enregistrement en cours."""
    try:
        d = open(RUN + '/rec').read().split()          # enregistrement lancé par Demo.sh
        if os.path.exists('/proc/' + d[0]): return d[0], float(d[1])
    except Exception:
        pass
    r = sh(['pgrep', '-x', 'wf-recorder']).stdout.split()   # n'importe quel autre enregistrement
    if r:
        pid = r[0]; et = sh(['ps', '-o', 'etimes=', '-p', pid]).stdout.strip()
        if et: return pid, time.time() - float(et)
    return None, None


def fichier_marques(pid):
    return '%s/marques-%s.txt' % (RUN, pid)


def debut(zone=None):
    pid, t0 = enregistrement()
    if not pid: notif('Flou', "Aucun enregistrement en cours"); return
    t = time.time() - t0; interactif = zone is None
    if zone is None:
        notif('Flou', "Encadre la zone · clic simple = tout l'écran")
        zone = zone_souris()
        if zone is None: notif('Flou', 'Annulé'); return
        t = min(t, time.time() - t0)
    w, h, s, _, _ = ecran()
    with open(fichier_marques(pid), 'a') as f:
        f.write('%.2f - %s | %g %g\n' % (t, zone, w, h))
    if interactif: notif('Flou ●', 'Début du passage flouté (refais Super+Alt+F pour la fin)')


def fin():
    pid, t0 = enregistrement()
    if not pid: return False
    p = fichier_marques(pid)
    try: L = open(p).read().splitlines()
    except Exception: return False
    for i in range(len(L) - 1, -1, -1):
        if ' - ' in L[i].split('|')[0]:
            L[i] = L[i].replace(' - ', ' %.2f ' % (time.time() - t0), 1)
            open(p, 'w').write('\n'.join(L) + '\n')
            if len(sys.argv) == 1: notif('Flou ○', 'Fin du passage flouté')
            return True
    return False


def ouvert():
    pid, _ = enregistrement()
    try: return pid and any(' - ' in l.split('|')[0] for l in open(fichier_marques(pid)))
    except Exception: return False


def attacher(video, pid=None):
    """Range les marques d'un enregistrement terminé à côté de la vidéo (VIDEO.flou)."""
    if pid is None:
        fs = sorted(glob.glob(RUN + '/marques-*.txt'), key=os.path.getmtime)
        if not fs: return False
        f = fs[-1]
    else:
        f = fichier_marques(pid)
    if not os.path.exists(f): return False
    o, _ = ranger(video)
    dur = duree(o)
    with open(o + '.flou', 'a') as out:
        for l in open(f):
            if ' - ' in l.split('|')[0]: l = l.replace(' - ', ' %.2f ' % dur, 1)   # passage jamais fermé
            out.write(l)
    os.remove(f)
    return True


# ------------------------------------------------------------------ ffmpeg
def duree(video):
    try: return float(sh(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', video]).stdout)
    except ValueError: return 0.0


def taille(video):
    r = sh(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height', '-of', 'csv=p=0', video])
    w, h = r.stdout.strip().split(',')[:2]
    return int(w), int(h)


CACHE = '.originaux'                               # sous-dossier caché : originaux + listes .flou


def chemins(video):
    """(original, vidéo à partager) pour une vidéo, quel que soit le fichier donné."""
    video = os.path.abspath(video)
    d, b = os.path.split(video)
    if os.path.basename(d) == CACHE: return video, os.path.join(os.path.dirname(d), b)
    if b.endswith('-flou.mp4'): b = b[:-9] + '.mp4'                # ancien nom
    if b.endswith('-floutee.mp4'): b = b[:-12] + '.mp4'
    o = os.path.join(d, CACHE, b)
    if not os.path.exists(o):                          # vidéo déplacée dans un autre dossier ?
        for r in DOSSIERS:
            p = os.path.join(r, CACHE, b)
            if os.path.exists(p): o = p; break
    return o, os.path.join(d, b)


def floutee(f):
    return f[:-4] + '-floutee.mp4'


def ranger(video):
    """Met l'original (et sa liste .flou) de côté dans .originaux, s'il n'y est pas déjà."""
    o, f = chemins(video)
    if not os.path.exists(o) and os.path.exists(f):
        os.makedirs(os.path.dirname(o), exist_ok=True)
        os.replace(f, o)
        if os.path.exists(f + '.flou'): os.replace(f + '.flou', o + '.flou')
    return o, f


def appliquer(video):
    o, f = chemins(video)
    marques = o + '.flou' if os.path.exists(o + '.flou') else f + '.flou'
    try: L = [l.strip() for l in open(marques) if l.strip()]
    except Exception: notif('Flou', 'Aucun passage à flouter pour cette vidéo'); return
    o, f = ranger(f)
    if not os.path.exists(o): notif('Flou', 'Vidéo introuvable'); return
    try: flouter(o, f, L)
    except Exception as ex:                            # quoi qu'il arrive, la vidéo reste à sa place
        if not os.path.exists(f) and not os.path.exists(floutee(f)):
            os.replace(o, f)
            if os.path.exists(o + '.flou'): os.replace(o + '.flou', f + '.flou')
        notif('Flou ✗', str(ex))


def flouter(video, f, L):
    VW, VH = taille(video); dur = duree(video)
    segs = []
    for l in L:
        try:
            a, ref = (l.split('|') + [''])[:2]
            p = a.split(); s, e = float(p[0]), float(p[1]); z = p[2:]
            rw, rh = (list(map(float, ref.split())) + [VW, VH])[:2] if ref.strip() else (VW, VH)
        except Exception:
            continue
        s, e = max(0, s - MARGE), min(dur or e + MARGE, e + MARGE)
        if e <= s: continue
        if z and z[0] != 'plein':
            kx, ky = VW / rw, VH / rh
            x, y, w, h = [int(float(v)) for v in z[:4]]
            x, y, w, h = int(x * kx), int(y * ky), int(w * kx), int(h * ky)
            x, y = max(0, min(VW - 4, x)), max(0, min(VH - 4, y))
            w, h = max(4, min(VW - x, w)) // 2 * 2, max(4, min(VH - y, h)) // 2 * 2
            segs.append((s, e, (x, y, w, h)))
        else:
            segs.append((s, e, None))
    if not segs: notif('Flou', 'Aucun passage valide'); return
    filtres, cur, n = [], '0:v', 0
    for s, e, z in segs:
        n += 1; en = "enable='between(t,%.2f,%.2f)'" % (s, e)
        if z is None:
            filtres.append('[%s]boxblur=30:3:%s[v%d]' % (cur, en, n))
        else:
            x, y, w, h = z; r = max(2, min(25, min(w, h) // 6))
            filtres.append('[%s]split[a%d][b%d];[b%d]crop=%d:%d:%d:%d,boxblur=%d:5:%s[c%d];[a%d][c%d]overlay=%d:%d:%s[v%d]'
                     % (cur, n, n, n, w, h, x, y, r, en, n, n, n, x, y, en, n))   # flou calculé seulement pendant le passage
        cur = 'v%d' % n
    out = f[:-4] + '.en-cours.mp4'
    notif('Flou', 'Floutage en cours… (%d passage%s)' % (len(segs), 's' if len(segs) > 1 else ''))
    open(RUN + '/flou-info.txt', 'w').write('%s\n%.2f\n%.2f\n' % (os.path.basename(floutee(f)), dur, time.time()))
    r = sh(['ffmpeg', '-y', '-v', 'error', '-progress', RUN + '/flou-progres.txt', '-i', video, '-filter_complex', ';'.join(filtres), '-map', '[%s]' % cur,
            '-map', '0:a?', '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '20', '-c:a', 'copy', out])
    if r.returncode == 0 and os.path.getsize(out) > 0:
        os.replace(out, floutee(f))
        for vieux in (f[:-4] + '-flou.mp4', f if os.path.exists(video) else ''):   # anciennes copies floutées
            if vieux and os.path.exists(vieux) and os.path.abspath(vieux) != os.path.abspath(video): os.remove(vieux)
        notif('Flou ✓', 'Vidéo floutée : ' + os.path.basename(floutee(f)))
    else:
        try: os.remove(out)
        except Exception: pass
        if not os.path.exists(f) and not os.path.exists(floutee(f)):   # on remet l'original à sa place
            os.replace(o, f)
            if os.path.exists(o + '.flou'): os.replace(o + '.flou', f + '.flou')
        open(RUN + '/flou-erreur.txt', 'w').write(r.stderr); notif('Flou ✗', 'Échec (détails : %s/flou-erreur.txt)' % RUN)


# ------------------------------------------------------------------ après coup
def temps(s):
    s = s.strip().replace(',', '.')
    if ':' in s:
        m, sec = s.rsplit(':', 1); return int(m) * 60 + float(sec)
    return float(s)


def videos():
    """Vidéos à partager (sous-dossiers compris, sans les originaux mis de côté)."""
    vs = {os.path.abspath(v) for d in DOSSIERS for v in glob.glob(d + '/**/*.mp4', recursive=True)}
    return [v for v in vs if not v.endswith(('-flou.mp4', '.en-cours.mp4'))]


def apres():
    if not sh(['pgrep', '-x', 'wf-recorder']).stdout.strip() and glob.glob(RUN + '/marques-*.txt'):
        vids = videos()
        if vids:                                   # passages marqués (Super+Alt+F) pendant ton dernier enregistrement
            v = max(vids, key=os.path.getmtime)
            if attacher(v): appliquer(v); return
    vids = sorted(videos(), key=os.path.getmtime, reverse=True)[:30]
    if not vids: notif('Flou', 'Aucune vidéo trouvée'); return
    noms = [os.path.relpath(v, HOME + '/Videos') + ('   (déjà floutée)' if os.path.exists(chemins(v)[0]) else '') for v in vids]
    c = rofi('Vidéo à flouter', noms)
    if not c: return
    video = vids[noms.index(c)] if c in noms else vids[0]
    o, _ = chemins(video); src = o if os.path.exists(o) else video        # on travaille toujours sur l'original
    t = rofi('Passages', [], mesg='Début et fin de chaque passage, séparés par une virgule — ex. : 3:26 3:28, 4:10 4:15'
             '   (durée de la vidéo : %d:%02d)' % divmod(int(duree(src)), 60))
    m = re.findall(r'\d+(?::\d+)?(?:\.\d+)?', t)
    if not m or len(m) % 2: notif('Flou', 'Format attendu : 3:26 3:28, 4:10 4:15'); return
    passages = [(temps(m[k]), temps(m[k + 1])) for k in range(0, len(m), 2)]
    for s, e in passages:
        if e <= s: notif('Flou', 'Un passage a sa fin avant son début (%d:%02d)' % divmod(int(s), 60)); return
    w, h, _, _, _ = ecran(); lignes = []; zone = None
    for k, (s, e) in enumerate(passages, 1):
        titre = 'Passage %d/%d : %d:%02d → %d:%02d' % ((k, len(passages)) + divmod(int(s), 60) + divmod(int(e), 60))
        choix = ["Encadrer une zone sur l'image", "Tout l'écran"] + (['Même zone que le passage précédent'] if zone else [])
        q = rofi('Zone', choix, mesg=titre)
        if not q: notif('Flou', 'Annulé'); return
        if q.startswith('Même'): pass
        elif q.startswith('Tout'): zone = 'plein'
        else:
            img = RUN + '/cadre.png'
            sh(['ffmpeg', '-y', '-v', 'error', '-ss', str((s + e) / 2), '-i', src, '-frames:v', '1', img])
            zone = zone_souris(img)
            if zone is None: notif('Flou', 'Annulé'); return
        lignes.append('%.2f %.2f %s | %g %g\n' % (s, e, zone, w, h))
    with open(src + '.flou', 'a') as f:                # tous les passages, puis un seul calcul
        f.writelines(lignes)
    appliquer(video)


def ranger_tout():
    """Range les vidéos faites avant : numéros pour les démos, originaux dans .originaux, flou manquant refait."""
    for racine, motif in ((HOME + '/Videos/Demos', r'^demo-(.+)-(\d{8})-(\d{6})\.mp4$'),
                          (HOME + '/Videos/Recordings', None)):
        if not os.path.isdir(racine): continue
        tous = [v for v in glob.glob(racine + '/**/*.mp4', recursive=True) if not v.endswith('-flou.mp4')]
        if motif:                                      # demo-visite-complete-20261010-222116.mp4 → 01-visite-complete.mp4
            nums = [int(m.group(1)) for v in glob.glob(racine + '/**/*.mp4', recursive=True) + glob.glob(racine + '/**/.originaux/*.mp4', recursive=True)
                    for m in [re.match(r'^(\d+)-', os.path.basename(v))] if m]
            n = max(nums or [0])
            for v in sorted(tous, key=lambda x: re.sub(r'.*-(\d{8}-\d{6})\.mp4$', r'\1', x)):
                m = re.match(motif, os.path.basename(v))
                if not m: continue
                n += 1; d = os.path.dirname(v); neuf = os.path.join(d, '%02d-%s.mp4' % (n, m.group(1)))
                for a, b in ((v, neuf), (v + '.flou', neuf + '.flou'), (v[:-4] + '-flou.mp4', neuf[:-4] + '-flou.mp4')):
                    if os.path.exists(a): os.replace(a, b)
            tous = [v for v in glob.glob(racine + '/**/*.mp4', recursive=True) if not v.endswith('-flou.mp4')]
        for v in tous:
            fl = v[:-4] + '-flou.mp4'
            if os.path.exists(fl):                     # ancienne paire : original de côté, copie floutée = la vidéo
                o, f = ranger(v); os.replace(fl, floutee(f))
            elif os.path.exists(v + '.flou') and not os.path.exists(chemins(v)[0]):
                appliquer(v)                           # liste de flou sans copie floutée : on la fabrique
    notif('Vidéos rangées ✓', 'Originaux dans le dossier caché .originaux (Ctrl+H dans Thunar)')


def progres():
    try: nom, dur, t0 = open(RUN + '/flou-info.txt').read().split('\n')[:3]; dur, t0 = float(dur), float(t0)
    except Exception: print('Aucun floutage lancé.'); return
    if not sh(['pgrep', '-x', 'ffmpeg']).stdout.strip():
        print('Aucun floutage en cours (dernier : %s).' % nom); return
    fait = 0.0
    try:
        for l in open(RUN + '/flou-progres.txt'):
            if l.startswith('out_time_us=') and l.strip()[12:].isdigit(): fait = int(l.strip()[12:]) / 1e6
    except Exception: pass
    pc = min(100, 100 * fait / dur) if dur else 0; ecoule = time.time() - t0
    reste = ecoule * (100 - pc) / pc if pc > 1 else None
    vitesse = fait / ecoule if ecoule > 0 else 0
    print('%s : %d %%  (%d:%02d / %d:%02d de vidéo)' % ((nom, pc) + divmod(int(fait), 60) + divmod(int(dur), 60)))
    print('vitesse : x%.1f %s' % (vitesse, '(rapide ✓)' if vitesse >= 0.8 else '(lent ✗ — préviens Claude)'))
    if reste is not None: print('reste environ %d min %02d s' % divmod(int(reste), 60))


if __name__ == '__main__':
    a = sys.argv[1:]
    if not a:
        if not fin(): debut()
    elif a[0] == '--debut':
        z = a[1] if a[1:] else None
        debut('plein' if z == 'plein' else (z if z and len(z.split()) == 4 else None))
    elif a[0] == '--fin': fin()
    elif a[0] == '--appliquer' and a[1:]: appliquer(a[1])
    elif a[0] == '--attacher' and a[1:]: attacher(a[1], a[2] if a[2:] else None)
    elif a[0] == '--apres': apres()
    elif a[0] == '--progres': progres()
    elif a[0] == '--ranger': ranger_tout()
