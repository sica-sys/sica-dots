-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- Default keybindings for KoolDots Hyprland Lua configuration.
-- Helper internals live in keybind_helpers.lua so this file stays focused on bindings you may edit.
-- To add a binding, copy an existing bind(...) line and change:
--   1) modifiers (e.g. "SUPER SHIFT")
--   2) key (e.g. "Return", "code:10", "mouse_down")
--   3) action (exec_cmd(...) or dispatch(...))
--   4) description text
local keybind_helpers = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/keybind_helpers.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/keybind_helpers.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/keybind_helpers.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.unbind_default_keys then
          keybind_helpers = loaded_helpers
          break
        end
      end
    end
  end

  if not keybind_helpers then
    error("Failed to load keybind_helpers.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local window_api = keybind_helpers.window_api
local exec_cmd = keybind_helpers.exec_cmd
local raw_dispatch_cmd = keybind_helpers.raw_dispatch_cmd
local dispatch = keybind_helpers.dispatch
local bind = keybind_helpers.bind
local bindm = keybind_helpers.bindm

-- Mass unbind defaults before rebuilding the Lua keymap.
keybind_helpers.unbind_default_keys()

-- ==================================================
-- User-editable bindings
-- ==================================================
-- Section: Application launchers and utility scripts
local app_binds = {
  {
    "SUPER",
    "D",
    "pkill rofi || true; $HOME/.config/hypr/scripts/RofiFocusedWallpaperLink.sh >/dev/null 2>&1 || true; rofi -show drun -modi drun,filebrowser,run,window -config $HOME/.config/hypr/rofi/config.rasi",
    "app launcher",
  },
  { "SUPER", "B", 'xdg-open "https://"', "open default browser" },
  { "SUPER", "A", "$HOME/.config/hypr/scripts/OverviewToggle.sh", "desktop overview" },
  { "SUPER CTRL", "A", "pkill rofi || true && ags -t 'overview'", "Ags overview" },
  { "SUPER", "Return", "$HOME/.config/hypr/scripts/LaunchTerminal.sh '$term'", "Open terminal" },
  {
    "SUPER",
    "E",
    "$HOME/.config/hypr/scripts/LaunchFileManager.sh '$files' '$term'",
    "file manager",
  },
  { "SUPER", "C", "$HOME/.config/hypr/scripts/rofi-ssh-menu.sh", "SSH session manager" },
  { "SUPER", "T", "$HOME/.config/hypr/scripts/ThemeChanger.sh", "Global theme switcher using Wallust" },
  { "SUPER", "H", "$HOME/.config/hypr/scripts/KeyHints.sh", "help / cheat sheet" },
  { "SUPER ALT", "R", "$HOME/.config/hypr/scripts/Refresh.sh", "refresh bar and menus" },
  { "SUPER ALT", "E", "$HOME/.config/hypr/scripts/RofiEmoji.sh", "emoji menu" },
  { "SUPER", "S", "$HOME/.config/hypr/scripts/RofiSearch.sh", "web search" },
  {
    "SUPER CTRL",
    "S",
    "$HOME/.config/hypr/scripts/RofiFocusedWallpaperLink.sh >/dev/null 2>&1 || true; rofi -show window -config $HOME/.config/hypr/rofi/config.rasi",
    "window switcher",
  },
  { "SUPER ALT", "O", "$HOME/.config/hypr/scripts/ChangeBlur.sh", "toggle blur" },
  { "SUPER SHIFT", "G", "$HOME/.config/hypr/scripts/GameMode.sh", "toggle game mode" },
  { "SUPER ALT", "L", "$HOME/.config/hypr/scripts/ChangeLayout.sh toggle", "toggle layouts" },
  { "SUPER ALT", "V", "$HOME/.config/hypr/scripts/ClipManager.sh", "clipboard manager" },
  { "CTRL ALT", "D", "$HOME/.config/hypr/scripts/Dock.sh", "toggle dock" },
  { "SUPER CTRL", "R", "$HOME/.config/hypr/scripts/RofiThemeSelector.sh", "rofi theme selector" },
  {
    "SUPER CTRL SHIFT",
    "R",
    "pkill rofi || true && $HOME/.config/hypr/scripts/RofiThemeSelector-modified.sh",
    "rofi theme selector (modified)",
  },
  { "SUPER CTRL", "K", "$HOME/.config/hypr/scripts/Kitty_themes.sh", "Kitty theme selector" },
  { "SUPER CTRL", "G", "$HOME/.config/hypr/scripts/Ghostty_themes.sh", "Ghostty theme selector" },
  { "SUPER CTRL", "W", "$HOME/.config/hypr/scripts/RofiWlogoutTheme.sh", "wlogout theme selector" },
  { "SUPER CTRL SHIFT", "W", "$HOME/.config/hypr/scripts/RofiWlogoutWallust.sh", "wlogout dynamic wallpaper selector" },
  {
    "SUPER SHIFT",
    "B",
    "$HOME/.config/hypr/UserScripts/RainbowBorders-low-cpu.sh  --run-once",
    "Set static Rainbow Border",
  },
  {
    "SUPER SHIFT",
    "H",
    "$HOME/.config/hypr/scripts/Toggle-Active-Window-Audio.sh",
    "Toggle Mute/Unmute for Active-Window",
  },
  {
    "ALT SHIFT",
    "S",
    "$HOME/.config/hypr/scripts/hyprshot.sh -m region -o $HOME/Pictures/Screenshots",
    "Hyprshot Screen Capture",
  },
  { "SUPER ALT", "SPACE", "$HOME/.config/hypr/scripts/Float-all-Windows.sh", "Float all windows" },
  { "SUPER CTRL", "SPACE", "$HOME/.config/hypr/scripts/float.all.samesize.lua", "Float all windows same size" },
  -- NOTE: Dropterminal is currently certified only with kitty. Not all terminals behave correctly as a dropdown.
  { "SUPER SHIFT", "Return", "$HOME/.config/hypr/scripts/Dropterminal.sh kitty", "DropDown terminal" },
  {
    "SUPER ALT",
    "mouse_down",
    function()
      local factor = (hl and hl.get_config and (hl.get_config("cursor.zoom_factor") or hl.get_config("cursor:zoom_factor"))) or 1.0
      if factor < 1.0 then factor = 1.0 end
      local new_factor = factor * 1.5
      if new_factor > 16.0 then new_factor = 16.0 end
      if hl and hl.config then
        hl.config({ cursor = { zoom_factor = new_factor } })
      end
    end,
    "zoom in",
  },
  {
    "SUPER ALT",
    "mouse_up",
    function()
      local factor = (hl and hl.get_config and (hl.get_config("cursor.zoom_factor") or hl.get_config("cursor:zoom_factor"))) or 1.0
      local new_factor = factor / 1.5
      if new_factor < 1.0 then new_factor = 1.0 end
      if hl and hl.config then
        hl.config({ cursor = { zoom_factor = new_factor } })
      end
    end,
    "zoom out",
  },
  { "SUPER CTRL ALT", "B", "pkill -SIGUSR1 waybar", "toggle waybar on/off" },
  { "SUPER CTRL", "B", "$HOME/.config/hypr/scripts/WaybarStyles.sh", "waybar styles menu" },
  { "SUPER ALT", "B", "$HOME/.config/hypr/scripts/WaybarLayout.sh", "waybar layout menu" },
  { "SUPER", "N", "$HOME/.config/hypr/scripts/Hyprsunset.sh toggle", "Toggle Hyprsunset - night light" },
  { "SUPER SHIFT", "M", "$HOME/.config/hypr/UserScripts/RofiBeats.sh", "online music" },
  { "SUPER", "W", "$HOME/.config/hypr/UserScripts/WallCarousel.py", "select wallpaper" },
  { "SUPER SHIFT", "W", "/home/hote/.config/hypr/UserScripts/EffetsPlus.sh", "wallpaper effects" },
  { "CTRL ALT", "W", "$HOME/.config/hypr/scripts/WallpaperRandom.sh", "random wallpaper" },
  { "SUPER SHIFT", "K", "$HOME/.config/hypr/scripts/KeyBinds.sh", "search keybinds" },
  { "SUPER SHIFT", "A", "$HOME/.config/hypr/scripts/Animations.sh", "animations menu" },
  { "SUPER SHIFT", "O", "$HOME/.config/hypr/scripts/ZshChangeTheme.sh", "change oh-my-zsh theme" },
  { "SUPER ALT", "C", "$HOME/.config/hypr/UserScripts/RofiCalc.sh", "calculator" },
}
for _, app in ipairs(app_binds) do
  bind(app[1], app[2], exec_cmd(app[3]), { description = app[4] })
end
--
--
-- These are examples of how to bind to a TUI/CLI apps
-- The specific keybinds are just examples
-- Do not user as-is as it will break exisitng keybinds
--
--
-- TUI Apps Configuration (commented options from LUA-files/hyprland-key-bindings-example.lua).
-- local terminal = "uwsm-app -- " .. (os.getenv("TERMINAL") or "")
-- local browser = "omarchy-launch-browser"
-- local tui_apps = {
--   { "CTRL + ALT + O", "opencode", "a opencode", "OpenCode" },
--   { "CTRL + ALT + SHIFT + A", "cline", "-e cline", "OpenCode" },
--   { "CTRL + ALT + B", "btop", "-e btop", "Task Manager" },
--   { "CTRL + ALT + SHIFT + B", "bluetui", "-e bluetui", "BlueTUI" },
--   { "CTRL + ALT + E", "spf", "-e spf", "SuperFile Manager" },
--   { "CTRL + ALT + L", "lazygit", "-e lazygit", "LazyGit" },
--   { "CTRL + ALT + N", "nvtop", "-e nvtop", "Nvtop" },
--   { "CTRL + ALT + SHIFT + N", "ncdu", "-e ncdu", "Ncdu" },
--   { "CTRL + ALT + W", "impala", "-e impala", "Impala Wi-Fi" },
--   { "CTRL + ALT + P", "pacseek", "-e pacseek", "PacSeek" },
--   { "CTRL + ALT + SHIFT + P", "pacsea", "-e pacsea", "PacSea" },
--   { "CTRL + ALT + R", "fzf-uninstall", "-e ~/.config/hypr/fzfpurge", "Fzf Uninstaller" },
--   { "CTRL + ALT + V", "wiremix", "-e wiremix", "WireMix Volume" },
--   { "CTRL + ALT + SHIFT + H", "htop", "-e htop", "Htop" },
-- }
-- for _, app in ipairs(tui_apps) do
--   hl.bind(app[1], hl.dsp.exec_cmd(terminal .. " --title=" .. app[2] .. " " .. app[3]), { description = app[4] })
-- end

--
--
-- These are examples of how to bind webpages
-- The specific keybinds are just examples
-- Do not user as-is as it will break exisitng keybinds
--
--
-- Web Apps Configuration (commented options from LUA-files/hyprland-key-bindings-example.lua).
-- local web_apps = {
--   { "SUPER + A", "https://gemini.google.com", "Gemini AI" },
--   { "SUPER + Y", "https://youtube.com", "YouTube" },
--   { "SUPER + T", "https://tiktok.com", "TikTok" },
--   { "SUPER + X", "https://x.com", "X.com" },
--   { "SUPER + U", "http://10.24.1.1", "Unifi" },
--   { "SUPER + I", "https://instagram.com", "Instagram" },
--   { "SUPER + P", "https://mail.proton.me", "Proton Mail" },
-- }
-- for _, web in ipairs(web_apps) do
--   hl.bind(web[1], hl.dsp.exec_cmd([[omarchy-launch-webapp "]] .. web[2] .. [["]]), { description = web[3] })
-- end

-- Manual example actions not currently active in this config.
-- hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "fenêtre en plein écran" })
-- hl.bind("ALT + SPACE", hl.dsp.window.float({ action = "toggle" }), { description = "activer/désactiver le mode flottant" })
-- hl.bind("CTRL + ALT + return", hl.dsp.exec_cmd("uwsm-app -- kitty"), { description = "terminal Kitty" })
-- hl.bind(
--   "CTRL + ALT + SHIFT + return",
--   hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new]]),
--   { description = "Tmux" }
-- )

-- Section: Window/session controls
bind("SUPER SHIFT", "F", dispatch("fullscreen", ""), { description = "plein écran" })
bind("SUPER", "F", dispatch("fullscreen", "1"), { description = "maximiser la fenêtre" })
bind("SUPER", "SPACE", dispatch("togglefloating", ""), { description = "rendre la fenêtre actuelle flottante" })
bind("SUPER CTRL", "O", dispatch("setprop", "active opaque toggle"), { description = "activer/désactiver l'opacité de la fenêtre active" })
bind(
  "ALT",
  "Shift_L",
  exec_cmd("$HOME/.config/hypr/scripts/KeyboardLayout.sh switch"),
  { description = "changer globalement la disposition du clavier", locked = true }
)
bind(
  "ALT",
  "Shift_R",
  exec_cmd("$HOME/.config/hypr/scripts/KeyboardLayout.sh switch"),
  { description = "changer globalement la disposition du clavier (Shift droit)", locked = true }
)
bind(
  "SHIFT",
  "Alt_L",
  exec_cmd("$HOME/.config/hypr/scripts/Tak0-Per-Window-Switch.sh"),
  { description = "changer la disposition du clavier par fenêtre", locked = true }
)
bind(
  "SHIFT",
  "Alt_R",
  exec_cmd("$HOME/.config/hypr/scripts/Tak0-Per-Window-Switch.sh"),
  { description = "changer la disposition du clavier par fenêtre (Alt droit)", locked = true }
)
bind(
  "SUPER CTRL",
  "F9",
  dispatch("movecurrentworkspacetomonitor", "l"),
  { description = "déplacer l'espace vers l'écran de gauche" }
)
bind(
  "SUPER CTRL",
  "F10",
  dispatch("movecurrentworkspacetomonitor", "r"),
  { description = "déplacer l'espace vers l'écran de droite" }
)
bind(
  "SUPER CTRL",
  "F11",
  dispatch("movecurrentworkspacetomonitor", "u"),
  { description = "déplacer l'espace vers l'écran du haut" }
)
bind(
  "SUPER CTRL",
  "F12",
  dispatch("movecurrentworkspacetomonitor", "d"),
  { description = "déplacer l'espace vers l'écran du bas" }
)
bind("CTRL ALT", "Delete", exec_cmd("$HOME/.config/hypr/scripts/Logout.sh"), { description = "quitter Hyprland" })
bind("SUPER", "Q", dispatch("killactive", ""), { description = "fermer la fenêtre active" })
bind(
  "SUPER SHIFT",
  "Q",
  exec_cmd("$HOME/.config/hypr/scripts/KillActiveProcess.sh"),
  { description = "terminer le processus actif" }
)
bind("CTRL ALT", "L", exec_cmd("$HOME/.config/hypr/scripts/LockScreen.sh"), { description = "verrouiller l'écran" })
bind("CTRL ALT", "P", exec_cmd("$HOME/.config/hypr/scripts/Wlogout.sh"), { description = "menu d'alimentation" })
bind("SUPER SHIFT", "N", exec_cmd("swaync-client -t -sw"), { description = "panneau de notifications" })
bind(
  "SUPER SHIFT",
  "E",
  exec_cmd("$HOME/.config/hypr/scripts/Kool_Quick_Settings.sh"),
  { description = "menu des paramètres rapides" }
)

-- Section: Layout and tiling controls
bind("SUPER CTRL", "D", dispatch("layoutmsg", "removemaster"), { description = "supprimer le master" })
bind("SUPER", "I", dispatch("layoutmsg", "addmaster"), { description = "ajouter le master" })
bind(
  "SUPER",
  "j",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh cycle-next"),
  { description = "suivant (selon le layout)" }
)
bind(
  "SUPER",
  "k",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh cycle-prev"),
  { description = "précédent (selon le layout)" }
)
bind("SUPER CTRL", "Return", dispatch("layoutmsg", "swapwithmaster"), { description = "échanger avec le master" })
bind("SUPER SHIFT", "I", dispatch("layoutmsg", "togglesplit"), { description = "activer/désactiver la séparation (dwindle)" })
bind("SUPER", "P", dispatch("pseudo", ""), { description = "activer/désactiver le pseudo (dwindle)" })
bind("SUPER", "M", raw_dispatch_cmd("splitratio 0.3"), { description = "définir le ratio de séparation à 0,3" })
bind(
  "SUPER ALT",
  "1",
  exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh dwindle"),
  { description = "🌀 Layout Dwindle" }
)
bind("SUPER ALT", "2", exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh master"), { description = "👑 Layout Master" })
bind(
  "SUPER ALT",
  "3",
  exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh scrolling"),
  { description = "↔️ Layout Scrolling" }
)
bind(
  "SUPER ALT",
  "4",
  exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh monocle"),
  { description = "🔍 Layout Monocle" }
)
bind("SUPER SHIFT", "period", dispatch("layoutmsg", "move +col"), { description = "déplacer vers la colonne de droite" })
bind("SUPER SHIFT", "comma", dispatch("layoutmsg", "move -col"), { description = "déplacer vers la colonne de gauche" })
bind("SUPER ALT", "comma", dispatch("layoutmsg", "swapcol l"), { description = "échanger les colonnes vers la gauche" })
bind("SUPER ALT", "period", dispatch("layoutmsg", "swapcol r"), { description = "échanger les colonnes vers la droite" })
bind(
  "SUPER ALT",
  "H",
  function()
    if hl and hl.config then
      hl.config({ scrolling = { direction = "right" } })
    end
  end,
  { description = "défilement horizontal vers la droite" }
)
bind(
  "SUPER CTRL",
  "V",
  function()
    if hl and hl.config then
      hl.config({ scrolling = { direction = "down" } })
    end
  end,
  { description = "défilement vertical vers le bas" }
)
bind(
  "SUPER ALT",
  "S",
  function()
    if hl and hl.config then
      local cur = (hl.get_config and (hl.get_config("scrolling.direction") or hl.get_config("scrolling:direction"))) or "right"
      local next_dir = (cur == "right") and "down" or "right"
      hl.config({ scrolling = { direction = next_dir } })
    end
  end,
  { description = "basculer le défilement V/H" }
)
-- Section: Hyprview expose controls
-- "smartgrid", "justified", "masonry", "bands", "hero", "spiral"
-- "satellite", "staggered", "columnar", "vortex", "random"
-- Bound later (after SUPER SHIFT/CTRL tab workspace/group binds) so the combo is not overwritten.
local col_width_presets = { 0.25, 0.33, 0.5, 0.66, 0.75, 1.0 }
local function _as_number(v)
  if type(v) == "number" then
    return v
  end
  if type(v) == "string" then
    return tonumber(v)
  end
  return nil
end
local function _window_width(win)
  if type(win) ~= "table" then
    return nil
  end
  local sz = win.size
  if type(sz) == "number" then
    return sz
  end
  if type(sz) == "table" then
    return _as_number(sz[1] or sz.width or sz.w)
  end
  return nil
end
local function _monitor_width(win)
  local mon = type(win) == "table" and win.monitor or nil
  if type(mon) == "table" then
    local w = _as_number(mon.width or mon.w or (type(mon.size) == "table" and (mon.size[1] or mon.size.width)))
    if w ~= nil then
      return w
    end
  end
  if hl.get_active_monitor then
    local active_mon = hl.get_active_monitor()
    if type(active_mon) == "table" then
      local w = _as_number(
        active_mon.width
          or active_mon.w
          or (type(active_mon.size) == "table" and (active_mon.size[1] or active_mon.size.width))
      )
      if w ~= nil then
        return w
      end
    end
  end
  return nil
end
bind("SUPER", "R", exec_cmd("bash $HOME/.config/hypr/scripts/ScrollCycleColumnWidth.sh"), { description = "changer la largeur de colonne (scrolling)" })
bind("ALT", "Tab", exec_cmd("$HOME/.config/hypr/scripts/LuaCycleWindow.sh next"), { description = "fenêtre suivante" })

-- Section: Audio, media, and hardware keys
bind(
  "",
  "xf86audioraisevolume",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --inc"),
  { description = "augmenter le volume", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86audiolowervolume",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --dec"),
  { description = "baisser le volume", locked = true, ["repeat"] = true }
)
bind(
  "ALT",
  "xf86audioraisevolume",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --inc-precise"),
  { description = "augmenter précisément le volume", locked = true, ["repeat"] = true }
)
bind(
  "ALT",
  "xf86audiolowervolume",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --dec-precise"),
  { description = "baisser précisément le volume", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86AudioMicMute",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle-mic"),
  { description = "activer/désactiver le micro", locked = true }
)
bind(
  "",
  "xf86audiomute",
  exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle"),
  { description = "activer/désactiver le son", locked = true }
)
bind("", "xf86Sleep", exec_cmd("systemctl suspend"), { description = "mise en veille", locked = true })
bind(
  "",
  "xf86Rfkill",
  exec_cmd("$HOME/.config/hypr/scripts/AirplaneMode.sh"),
  { description = "mode avion", locked = true }
)
bind(
  "",
  "XF86AudioPlay",
  exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"),
  { description = "lecture/pause", locked = true }
)
bind(
  "",
  "XF86AudioPause",
  exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"),
  { description = "⏸️ Pause", locked = true }
)
bind(
  "",
  "XF86AudioNext",
  exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --nxt"),
  { description = "piste suivante", locked = true }
)
bind(
  "",
  "XF86AudioPrev",
  exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --prv"),
  { description = "piste précédente", locked = true }
)
bind(
  "",
  "XF86AudioStop",
  exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --stop"),
  { description = "arrêter", locked = true }
)
bind(
  "",
  "xf86MonBrightnessDown",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --dec"),
  { description = "diminuer la luminosité de l'écran", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86MonBrightnessUp",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"),
  { description = "augmenter la luminosité de l'écran", locked = true, ["repeat"] = true }
)
bind(
  "CTRL ALT",
  "equal",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"),
  { description = "augmenter la luminosité", locked = true, ["repeat"] = true }
)
bind(
  "CTRL ALT",
  "minus",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --dec"),
  { description = "diminuer la luminosité", locked = true, ["repeat"] = true }
)
bind(
  "CTRL ALT",
  "KP_Add",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"),
  { description = "augmenter la luminosité (pavé numérique)", locked = true, ["repeat"] = true }
)
bind(
  "CTRL ALT",
  "KP_Subtract",
  exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --dec"),
  { description = "diminuer la luminosité (pavé numérique)", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86KbdBrightnessDown",
  exec_cmd("$HOME/.config/hypr/scripts/BrightnessKbd.sh --dec"),
  { description = "diminuer la luminosité du clavier", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86KbdBrightnessUp",
  exec_cmd("$HOME/.config/hypr/scripts/BrightnessKbd.sh --inc"),
  { description = "augmenter la luminosité du clavier", locked = true, ["repeat"] = true }
)
bind(
  "",
  "xf86KbdLightOnOff",
  exec_cmd("$HOME/.config/hypr/scripts/BrightnessKbd.sh --cycle"),
  { description = "changer la luminosité du clavier", locked = true }
)
bind(
  "",
  "xf86TouchpadToggle",
  exec_cmd("$HOME/.config/hypr/scripts/TouchPad.sh"),
  { description = "désactiver le pavé tactile" }
)
bind(
  "",
  "xf86Launch1",
  exec_cmd("rog-control-center"),
  { description = "bouton ASUS Armory Crate" }
)
bind(
  "",
  "xf86Launch3",
  exec_cmd("asusctl led-mode -n"),
  { description = "FN+F4 changer le profil RGB du clavier" }
)
bind(
  "",
  "xf86Launch4",
  exec_cmd("asusctl profile -n"),
  { description = "FN+F5 changer le profil des ventilateurs" }
)

-- Section: Screenshot bindings
bind("SUPER", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --now"), { description = "capture maintenant" })
bind(
  "SUPER SHIFT",
  "Print",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --area"),
  { description = "capture d'une zone" }
)
bind(
  "SUPER CTRL",
  "Print",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in5"),
  { description = "capture dans 5 s" }
)
bind(
  "SUPER CTRL SHIFT",
  "Print",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in10"),
  { description = "capture dans 10 s" }
)
bind(
  "ALT",
  "Print",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --active"),
  { description = "capture de la fenêtre active" }
)
bind(
  "SUPER SHIFT",
  "S",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --swappy"),
  { description = "capture d'écran (Swappy)" }
)
-- Screenshot keybindings using F6 (no PrintSrc button)
bind("SUPER", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --now"), { description = "capture d'écran" })
bind(
  "SUPER SHIFT",
  "F6",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --area"),
  { description = "capture d'une zone" }
)
bind(
  "SUPER CTRL",
  "F6",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in5"),
  { description = "capture d'écran (délai de 5 s)" }
)
bind(
  "SUPER ALT",
  "F6",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in10"),
  { description = "capture d'écran (délai de 10 s)" }
)
bind(
  "ALT",
  "F6",
  exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --active"),
  { description = "capture de la fenêtre active uniquement" }
)
-- Keep legacy script-based resize bindings commented for quick rollback during Lua API migration.
-- These call ResizeActive.sh and are preserved in case native hl.dsp/hl.window resize behavior regresses.
-- bind(
--   "SUPER SHIFT",
--   "left",
--   exec_cmd("bash $HOME/.config/hypr/scripts/ResizeActive.sh -50 0"),
--   { description = "redimensionner vers la gauche (-50)" }
-- )
-- bind(
--   "SUPER SHIFT",
--   "right",
--   exec_cmd("bash $HOME/.config/hypr/scripts/ResizeActive.sh 50 0"),
--   { description = "redimensionner vers la droite (+50)" }
-- )
-- bind(
--   "SUPER SHIFT",
--   "up",
--   exec_cmd("bash $HOME/.config/hypr/scripts/ResizeActive.sh 0 -50"),
--   { description = "redimensionner vers le haut (-50)" }
-- )
-- bind(
--   "SUPER SHIFT",
--   "down",
--   exec_cmd("bash $HOME/.config/hypr/scripts/ResizeActive.sh 0 50"),
--   { description = "redimensionner vers le bas (+50)" }
-- )
bind("SUPER SHIFT", "left", dispatch("resizeactive", "-50 0"), { description = "redimensionner vers la gauche (-50)" })
bind("SUPER SHIFT", "right", dispatch("resizeactive", "50 0"), { description = "redimensionner vers la droite (+50)" })
bind("SUPER SHIFT", "up", dispatch("resizeactive", "0 -50"), { description = "redimensionner vers le haut (-50)" })
bind("SUPER SHIFT", "down", dispatch("resizeactive", "0 50"), { description = "redimensionner vers le bas (+50)" })
-- Keep legacy directional move script binds commented for rollback during Lua API migration.
-- Native movewindow dispatch below replaces LuaMoveWindowDirectional.sh usage.
-- bind(
--   "SUPER CTRL",
--   "left",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowDirectional.sh left"),
--   { description = "déplacer la fenêtre vers la gauche" }
-- )
-- bind(
--   "SUPER CTRL",
--   "right",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowDirectional.sh right"),
--   { description = "déplacer la fenêtre vers la droite" }
-- )

-- Section: Window resize, move, swap, and grouping
bind("SUPER CTRL", "left", dispatch("movewindow", "l"), { description = "déplacer la fenêtre vers la gauche" })
bind("SUPER CTRL", "right", dispatch("movewindow", "r"), { description = "déplacer la fenêtre vers la droite" })
bind("SUPER CTRL", "up", dispatch("movewindow", "u"), { description = "déplacer la fenêtre vers le haut" })
bind("SUPER CTRL", "down", dispatch("movewindow", "d"), { description = "déplacer la fenêtre vers le bas" })
bind(
  "SUPER ALT",
  "left",
  exec_cmd("$HOME/.config/hypr/scripts/LuaSwapWindow.sh l"),
  { description = "échanger la fenêtre vers la gauche" }
)
bind(
  "SUPER ALT",
  "right",
  exec_cmd("$HOME/.config/hypr/scripts/LuaSwapWindow.sh r"),
  { description = "échanger la fenêtre vers la droite" }
)
bind("SUPER ALT", "up", exec_cmd("$HOME/.config/hypr/scripts/LuaSwapWindow.sh u"), { description = "échanger la fenêtre vers le haut" })
bind(
  "SUPER ALT",
  "down",
  exec_cmd("$HOME/.config/hypr/scripts/LuaSwapWindow.sh d"),
  { description = "échanger la fenêtre vers le bas" }
)
bind("SUPER", "G", dispatch("togglegroup", ""), { description = "activer/désactiver le groupe" })
bind("SUPER", "Tab", dispatch("changegroupactive", "f"), { description = "groupe suivant" })
bind("SUPER SHIFT", "Tab", dispatch("changegroupactive", "b"), { description = "groupe précédent" })
bind("SUPER CTRL", "J", dispatch("moveintogroup", "l"), { description = "déplacer vers la gauche dans le groupe" })
bind("SUPER CTRL", "L", dispatch("moveintogroup", "r"), { description = "déplacer vers la droite dans le groupe" })
bind("SUPER CTRL", "H", dispatch("moveoutofgroup", ""), { description = "sortir la fenêtre active du groupe" })
bind(
  "SUPER",
  "left",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh focus-left"),
  { description = "focus vers la gauche (selon le layout)" }
)
bind(
  "SUPER",
  "right",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh focus-right"),
  { description = "focus vers la droite (selon le layout)" }
)
bind(
  "SUPER",
  "up",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh focus-up"),
  { description = "focus vers le haut (selon le layout)" }
)
bind(
  "SUPER",
  "down",
  exec_cmd("$HOME/.config/hypr/scripts/LayoutKeybindDispatch.sh focus-down"),
  { description = "focus vers le bas (selon le layout)" }
)

-- Section: Workspace navigation and assignment
-- Keep legacy relative workspace focus script binds commented for rollback during Lua API migration.
-- Native workspace dispatch below replaces LuaFocusWorkspaceRelative.sh usage.
-- bind(
--   "SUPER",
--   "tab",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh next"),
--   { description = "espace de travail suivant" }
-- )
-- bind(
--   "SUPER SHIFT",
--   "tab",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh previous"),
--   { description = "espace de travail précédent" }
-- )
bind("SUPER", "tab", dispatch("workspace", "e+1"), { description = "espace de travail suivant" })
bind("SUPER SHIFT", "tab", dispatch("workspace", "e-1"), { description = "espace de travail précédent" })
-- Hyprview: SUPER CTRL+Tab (avoids SUPER SHIFT+Tab used by previous workspace / group back)
local qs_hyprview_layout = "smartgrid"
bind(
  "SUPER CTRL",
  "tab",
  exec_cmd("$HOME/.config/hypr/scripts/toggle-qs-hyprview.sh " .. qs_hyprview_layout),
  { description = "activer/désactiver Hyprview" }
)
bind("SUPER SHIFT", "U", dispatch("movetoworkspace", "special"), { description = "déplacer vers l'espace spécial" })
bind("SUPER", "U", dispatch("togglespecialworkspace", ""), { description = "afficher/masquer l'espace spécial" })
bind("SUPER", "code:10", dispatch("workspace", "1"), { description = "espace de travail 1" })
bind("SUPER", "code:11", dispatch("workspace", "2"), { description = "espace de travail 2" })
bind("SUPER", "code:12", dispatch("workspace", "3"), { description = "espace de travail 3" })
bind("SUPER", "code:13", dispatch("workspace", "4"), { description = "espace de travail 4" })
bind("SUPER", "code:14", dispatch("workspace", "5"), { description = "espace de travail 5" })
bind("SUPER", "code:15", dispatch("workspace", "6"), { description = "espace de travail 6" })
bind("SUPER", "code:16", dispatch("workspace", "7"), { description = "espace de travail 7" })
bind("SUPER", "code:17", dispatch("workspace", "8"), { description = "espace de travail 8" })
bind("SUPER", "code:18", dispatch("workspace", "9"), { description = "espace de travail 9" })
bind("SUPER", "code:19", dispatch("workspace", "10"), { description = "espace de travail 10" })
bind("SUPER SHIFT", "code:10", dispatch("movetoworkspace", "1"), { description = "aller vers l'espace 1" })
bind("SUPER SHIFT", "code:11", dispatch("movetoworkspace", "2"), { description = "aller vers l'espace 2" })
bind("SUPER SHIFT", "code:12", dispatch("movetoworkspace", "3"), { description = "aller vers l'espace 3" })
bind("SUPER SHIFT", "code:13", dispatch("movetoworkspace", "4"), { description = "aller vers l'espace 4" })
bind("SUPER SHIFT", "code:14", dispatch("movetoworkspace", "5"), { description = "aller vers l'espace 5" })
bind("SUPER SHIFT", "code:15", dispatch("movetoworkspace", "6"), { description = "aller vers l'espace 6" })
bind("SUPER SHIFT", "code:16", dispatch("movetoworkspace", "7"), { description = "aller vers l'espace 7" })
bind("SUPER SHIFT", "code:17", dispatch("movetoworkspace", "8"), { description = "aller vers l'espace 8" })
bind("SUPER SHIFT", "code:18", dispatch("movetoworkspace", "9"), { description = "aller vers l'espace 9" })
bind("SUPER SHIFT", "code:19", dispatch("movetoworkspace", "10"), { description = "aller vers l'espace 10" })
-- Keep legacy relative move-to-workspace script binds commented for rollback during Lua API migration.
-- Native movetoworkspace dispatch below replaces LuaMoveWindowWorkspaceRelative.sh usage.
-- bind(
--   "SUPER SHIFT",
--   "bracketleft",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowWorkspaceRelative.sh previous"),
--   { description = "aller vers l'espace précédent" }
-- )
-- bind(
--   "SUPER SHIFT",
--   "bracketright",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowWorkspaceRelative.sh next"),
--   { description = "aller vers l'espace suivant" }
-- )
bind("SUPER SHIFT", "bracketleft", dispatch("movetoworkspace", "-1"), { description = "aller vers l'espace précédent" })
bind("SUPER SHIFT", "bracketright", dispatch("movetoworkspace", "+1"), { description = "aller vers l'espace suivant" })
bind("SUPER CTRL", "code:10", dispatch("movetoworkspacesilent", "1"), { description = "déplacer silencieusement vers l'espace 1" })
bind("SUPER CTRL", "code:11", dispatch("movetoworkspacesilent", "2"), { description = "déplacer silencieusement vers l'espace 2" })
bind("SUPER CTRL", "code:12", dispatch("movetoworkspacesilent", "3"), { description = "déplacer silencieusement vers l'espace 3" })
bind("SUPER CTRL", "code:13", dispatch("movetoworkspacesilent", "4"), { description = "déplacer silencieusement vers l'espace 4" })
bind("SUPER CTRL", "code:14", dispatch("movetoworkspacesilent", "5"), { description = "déplacer silencieusement vers l'espace 5" })
bind("SUPER CTRL", "code:15", dispatch("movetoworkspacesilent", "6"), { description = "déplacer silencieusement vers l'espace 6" })
bind("SUPER CTRL", "code:16", dispatch("movetoworkspacesilent", "7"), { description = "déplacer silencieusement vers l'espace 7" })
bind("SUPER CTRL", "code:17", dispatch("movetoworkspacesilent", "8"), { description = "déplacer silencieusement vers l'espace 8" })
bind("SUPER CTRL", "code:18", dispatch("movetoworkspacesilent", "9"), { description = "déplacer silencieusement vers l'espace 9" })
bind(
  "SUPER CTRL",
  "code:19",
  dispatch("movetoworkspacesilent", "10"),
  { description = "déplacer silencieusement vers l'espace 10" }
)
-- Keep legacy silent relative move-to-workspace script binds commented for rollback during Lua API migration.
-- Native movetoworkspacesilent dispatch below replaces LuaMoveWindowWorkspaceRelative.sh usage.
-- bind(
--   "SUPER CTRL",
--   "bracketleft",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowWorkspaceRelative.sh previous"),
--   { description = "déplacer silencieusement vers l'espace précédent" }
-- )
-- bind(
--   "SUPER CTRL",
--   "bracketright",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaMoveWindowWorkspaceRelative.sh next"),
--   { description = "déplacer silencieusement vers l'espace suivant" }
-- )
bind(
  "SUPER CTRL",
  "bracketleft",
  dispatch("movetoworkspacesilent", "-1"),
  { description = "déplacer silencieusement vers l'espace précédent" }
)
bind(
  "SUPER CTRL",
  "bracketright",
  dispatch("movetoworkspacesilent", "+1"),
  { description = "déplacer silencieusement vers l'espace suivant" }
)
-- Keep legacy scroll/period/comma workspace focus script binds commented for rollback during Lua API migration.
-- Native workspace dispatch below replaces LuaFocusWorkspaceRelative.sh usage.
-- bind(
--   "SUPER",
--   "mouse_down",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh next"),
--   { description = "espace de travail suivant" }
-- )
-- bind(
--   "SUPER",
--   "mouse_up",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh previous"),
--   { description = "espace de travail précédent" }
-- )
-- bind(
--   "SUPER",
--   "period",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh next"),
--   { description = "espace de travail suivant" }
-- )
-- bind(
--   "SUPER",
--   "comma",
--   exec_cmd("$HOME/.config/hypr/scripts/LuaFocusWorkspaceRelative.sh previous"),
--   { description = "espace de travail précédent" }
-- )
bind("SUPER", "mouse_down", dispatch("workspace", "e+1"), { description = "espace de travail suivant" })
bind("SUPER", "mouse_up", dispatch("workspace", "e-1"), { description = "espace de travail précédent" })
bind("SUPER", "period", dispatch("workspace", "e+1"), { description = "espace de travail suivant" })
bind("SUPER", "comma", dispatch("workspace", "e-1"), { description = "espace de travail précédent" })

-- Section: Mouse drag/resize bindings
bindm("SUPER", "mouse:272", "movewindow", "move window")
bindm("SUPER", "mouse:273", "resizewindow", "resize window")

-- Section: Keyboard passthrough submap ("Bind KB")
-- SUPER SHIFT P enters the "Bind KB" submap, which lets the keyboard pass through
-- to the focused window. The only key bound inside the submap is SUPER ALT P,
-- which resets back to the normal submap.
-- While this submap is active, Waybar's hyprland/submap module shows it as
-- "submap: Bind KB" in the center of the bar, and it stays hidden otherwise.
bind("SUPER SHIFT", "P", hl.dsp.submap("Bind KB"), { description = "entrer dans le sous-menu clavier passthrough" })
hl.define_submap("Bind KB", function()
  bind("SUPER ALT", "P", hl.dsp.submap("reset"), { description = "quitter le sous-menu clavier passthrough" })
end)
