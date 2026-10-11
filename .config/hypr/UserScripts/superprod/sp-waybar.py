#!/usr/bin/env python3
# Module Waybar Super Productivity — status | toggle | menu
import sys, os, json, subprocess, urllib.request, datetime as dt
BASE = "http://127.0.0.1:3876"
HDR = os.path.expanduser("~/.config/superprod/api-header")
LAST = os.path.expanduser("~/.cache/sp-waybar-last")
opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))

def token():
    try: return open(HDR).read().strip().split("Bearer ", 1)[1]
    except Exception: return ""

def api(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(BASE + path, data=data, method=method,
          headers={"Authorization": "Bearer " + token(), "Content-Type": "application/json"})
    with opener.open(req, timeout=3) as r: j = json.load(r)
    return j.get("data") if j.get("ok") else None

def tache(d):
    if isinstance(d, dict) and not d.get("title") and isinstance(d.get("task"), dict): d = d["task"]
    return d if isinstance(d, dict) and d.get("title") else None

def chrono(ms):
    s = int((ms or 0) / 1000); h, m = divmod(s // 60, 60)
    return f"{h}:{m:02d}:{s % 60:02d}" if h else f"{m:02d}:{s % 60:02d}"

def court(ms):
    h, m = divmod(int((ms or 0) / 60000), 60)
    return f"{h}h{m:02d}" if h else f"{m}m"

def derniere():
    try: return open(LAST).read().strip()
    except Exception: return ""

def rafraichir(): subprocess.run(["pkill", "-RTMIN+9", "waybar"])
def notif(msg): subprocess.run(["notify-send", "Super Productivity", msg])

def status():
    try: cur = tache(api("GET", "/task-control/current"))
    except Exception:
        print(json.dumps({"text": "SP fermé", "class": "off", "tooltip": "Clic du milieu : ouvrir Super Productivity"})); return
    if cur:
        open(LAST, "w").write(cur["id"])
        est = f" / {court(cur.get('timeEstimate'))}" if cur.get("timeEstimate") else ""
        out = {"text": f"▶  {cur['title'][:28]}  {chrono(cur.get('timeSpent'))}", "class": "running",
               "tooltip": f"{cur['title']}\nTemps : {court(cur.get('timeSpent'))}{est}\nGauche : pause · Droit : tâches · Milieu : ouvrir"}
    else:
        t = None
        if derniere():
            try: t = tache(api("GET", f"/tasks/{derniere()}"))
            except Exception: t = None
        if t and not t.get("isDone"):
            out = {"text": f"⏸  {t['title'][:28]}  {chrono(t.get('timeSpent'))}", "class": "paused",
                   "tooltip": "En pause — clic gauche pour reprendre"}
        else:
            try: n = len(api("GET", "/tasks?tagId=TODAY") or [])
            except Exception: n = 0
            out = {"text": f"✓  {n} tâche{'s' if n > 1 else ''}", "class": "idle",
                   "tooltip": "Aucune tâche en cours — clic droit pour en choisir une"}
    print(json.dumps(out))

def menu():
    taches = [t for t in (api("GET", "/tasks?tagId=TODAY") or []) if not t.get("parentId")]
    cur = tache(api("GET", "/task-control/current")); cid = cur["id"] if cur else None
    lignes = []
    for t in taches:
        est = f" / {court(t.get('timeEstimate'))}" if t.get("timeEstimate") else ""
        lignes.append(f"{'▶' if t['id'] == cid else '○'}  {t['title']}    {court(t.get('timeSpent'))}{est}")
    lignes.append("+  Nouvelle tâche…")
    r = subprocess.run(["rofi", "-theme", os.path.expanduser("~/.config/rofi/verre.rasi"), "-dmenu", "-i", "-p", "Tâches du jour", "-format", "i"],
                       input="\n".join(lignes), capture_output=True, text=True)
    if r.returncode != 0 or not r.stdout.strip(): return
    i = int(r.stdout.strip())
    if i == len(taches):
        titre = subprocess.run(["rofi", "-theme", os.path.expanduser("~/.config/rofi/verre.rasi"), "-dmenu", "-p", "Nouvelle tâche"], input="", capture_output=True, text=True).stdout.strip()
        if titre: api("POST", "/tasks", {"title": titre, "dueDay": dt.date.today().isoformat()}); notif(f"« {titre} » ajoutée à aujourd'hui")
    else:
        api("POST", f"/tasks/{taches[i]['id']}/start", {})
    rafraichir()

def toggle():
    cur = tache(api("GET", "/task-control/current"))
    if cur:
        open(LAST, "w").write(cur["id"]); api("POST", "/task-control/stop", {})
    elif derniere():
        api("POST", f"/tasks/{derniere()}/start", {})
    else:
        return menu()
    rafraichir()

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "status"
    if mode == "status": status()
    else:
        try: {"toggle": toggle, "menu": menu}[mode]()
        except Exception: notif("Super Productivity n'est pas ouvert, ou l'API locale est désactivée")
