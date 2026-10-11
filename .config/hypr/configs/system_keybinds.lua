-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- System defaults migrated from configs/Keybinds.conf (auto-generated).
-- Add keybinds with bind("MODS", "KEY", fn, opts).
-- Example:
-- bind("SUPER", "Z", exec_cmd("thunar"), { description = "ouvrir le gestionnaire de fichiers" })

local dsp = hl.dsp or hl
local function resolve_cmd(cmd)
  local defaults = rawget(_G, "KOOLDOTS_DEFAULTS") or {}
  local resolved_term = defaults.term or os.getenv("TERMINAL") or "kitty"
  local resolved_files = defaults.files or "thunar"
  local resolved_edit = defaults.edit or os.getenv("EDITOR") or "nano"
  local resolved_visual = defaults.visual or os.getenv("VISUAL") or ""
  cmd = tostring(cmd)
  cmd = cmd:gsub("%$term", resolved_term)
  cmd = cmd:gsub("%$files", resolved_files)
  cmd = cmd:gsub("%$edit", resolved_edit)
  cmd = cmd:gsub("%$visual", resolved_visual)
  return cmd
end

local function exec_cmd(cmd)
  local resolved = resolve_cmd(cmd)
  if dsp and dsp.exec_cmd then
    return dsp.exec_cmd(resolved)
  end
  return function()
    hl.exec_cmd(resolved)
  end
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function raw_dispatch_cmd(command)
  if dsp and dsp.exec_raw then
    return function()
      hl.dispatch(dsp.exec_raw(tostring(command)))
    end
  end
  return exec_cmd("hyprctl dispatch " .. tostring(command))
end

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_mods(mods)
  mods = trim(mods)
  if mods == "" then
    return ""
  end
  local known = {
    super = "SUPER",
    super_l = "SUPER_L",
    super_r = "SUPER_R",
    shift = "SHIFT",
    shift_l = "SHIFT_L",
    shift_r = "SHIFT_R",
    ctrl = "CTRL",
    control = "CTRL",
    ctrl_l = "CTRL_L",
    ctrl_r = "CTRL_R",
    control_l = "CTRL_L",
    control_r = "CTRL_R",
    alt = "ALT",
    alt_l = "ALT_L",
    alt_r = "ALT_R",
    meta = "META",
    meta_l = "META_L",
    meta_r = "META_R",
    mod2 = "MOD2",
    mod3 = "MOD3",
    mod5 = "MOD5",
  }
  local parts = {}
  for token in mods:gmatch("%S+") do
    parts[#parts + 1] = known[token:lower()] or token
  end
  return table.concat(parts, " ")
end

local function chord(mods, key)
  mods = normalize_mods(mods):gsub("%s+", " + ")
  key = trim(key)
  if mods == "" then
    return key
  end
  return mods .. " + " .. key
end

local function key_variants(key, mods)
  key = trim(key):gsub("^xf86", "XF86")
  local key_aliases = {
    XF86AudioPlayPause = "XF86AudioPlay",
    XF86audiolowervolume = "XF86AudioLowerVolume",
    XF86audiomute = "XF86AudioMute",
    XF86audioraisevolume = "XF86AudioRaiseVolume",
    XF86audiostop = "XF86AudioStop",
  }
  key = key_aliases[key] or key
  local shifted_number_keys = {
    ["code:10"] = "exclam",
    ["code:11"] = "at",
    ["code:12"] = "numbersign",
    ["code:13"] = "dollar",
    ["code:14"] = "percent",
    ["code:15"] = "asciicircum",
    ["code:16"] = "ampersand",
    ["code:17"] = "asterisk",
    ["code:18"] = "parenleft",
    ["code:19"] = "parenright",
  }
  local number_keys = {
    ["code:10"] = "1",
    ["code:11"] = "2",
    ["code:12"] = "3",
    ["code:13"] = "4",
    ["code:14"] = "5",
    ["code:15"] = "6",
    ["code:16"] = "7",
    ["code:17"] = "8",
    ["code:18"] = "9",
    ["code:19"] = "0",
  }
  if mods:upper():match("SHIFT") and shifted_number_keys[key] then
    local number_key = number_keys[key]
    if number_key then
      return { shifted_number_keys[key], number_key }
    end
    return { shifted_number_keys[key] }
  end
  if number_keys[key] then
    return { number_keys[key] }
  end
  return { key }
end

local function workspace_value(value)
  value = trim(value)
  return tonumber(value) or value
end

local function direction(value)
  local directions = {
    l = "left",
    r = "right",
    u = "up",
    d = "down",
    left = "left",
    right = "right",
    up = "up",
    down = "down",
  }
  return directions[trim(value)] or trim(value)
end

local function dispatch(name, args)
  local window_api = (dsp and dsp.window) or hl.window or {}
  name = trim(name)
  args = trim(args)
  if name == "exec" then
    return exec_cmd(args)
  end
  if name == "killactive" and window_api.close then
    return function()
      hl.dispatch(window_api.close())
    end
  end
  if name == "fullscreen" and window_api.fullscreen then
    if args == "1" then
      return function()
        hl.dispatch(window_api.fullscreen({ mode = "maximized" }))
      end
    end
    return function()
      hl.dispatch(window_api.fullscreen({ mode = "fullscreen" }))
    end
  end
  if name == "movefocus" and dsp and dsp.focus then
    return function()
      local ok, dispatcher = pcall(dsp.focus, { direction = direction(args) })
      if ok and dispatcher then
        hl.dispatch(dispatcher)
      end
    end
  end
  if name == "cyclenext" then
    if args == "prev" or args == "b" then
      return exec_cmd("$HOME/.config/hypr/scripts/LuaCycleWindow.sh previous")
    end
    return exec_cmd("$HOME/.config/hypr/scripts/LuaCycleWindow.sh next")
  end
  if name == "swapwindow" then
    local swap_direction = trim(args)
    if swap_direction == "" then
      return nil
    end
    return exec_cmd("$HOME/.config/hypr/scripts/LuaSwapWindow.sh " .. swap_direction)
  end
  if name == "workspace" and dsp and dsp.focus then
    return function()
      hl.dispatch(dsp.focus({ workspace = workspace_value(args) }))
    end
  end
  if name == "movetoworkspace" then
    if args == "special" or args:match("^special:") then
      return function()
        local win = hl.get_active_window and hl.get_active_window()
        local ws = win and win.workspace
        if ws and (ws.special == true or (type(ws.name) == "string" and ws.name:match("^special"))) then
          local mon = hl.get_active_monitor and hl.get_active_monitor()
          local active_ws = hl.get_active_workspace and hl.get_active_workspace(mon and mon.id)
          local target_id = (active_ws and not active_ws.special and active_ws.id) or "+0"
          if window_api.move then
            hl.dispatch(window_api.move({ workspace = target_id }))
          else
            hl.dispatch(dsp.exec_raw("movetoworkspace " .. tostring(target_id)))
          end
          return
        end
        if window_api.move then
          hl.dispatch(window_api.move({ workspace = workspace_value(args) }))
        else
          hl.dispatch(dsp.exec_raw("movetoworkspace " .. args))
        end
      end
    end
    if window_api.move then
      return function()
        hl.dispatch(window_api.move({ workspace = workspace_value(args) }))
      end
    end
    return raw_dispatch_cmd("movetoworkspace " .. args)
  end
  if name == "movetoworkspacesilent" and window_api.move then
    return function()
      hl.dispatch(window_api.move({ workspace = workspace_value(args), follow = false }))
    end
  end
  if name == "togglespecialworkspace" then
    local workspace_api = (dsp and dsp.workspace) or {}
    if workspace_api.toggle_special then
      return function()
        local ok, dispatcher = pcall(workspace_api.toggle_special, args ~= "" and { name = args } or nil)
        if ok and dispatcher then
          hl.dispatch(dispatcher)
        end
      end
    end
    if args ~= "" then
      return raw_dispatch_cmd("togglespecialworkspace " .. args)
    end
    return raw_dispatch_cmd("togglespecialworkspace")
  end
  if name == "togglefloating" and window_api.float then
    return function()
      hl.dispatch(window_api.float({ action = "toggle" }))
    end
  end
  if name == "togglegroup" then
    return function()
      local group_api = (dsp and dsp.group) or (hl and hl.dsp and hl.dsp.group) or {}
      if group_api and group_api.toggle then
        local ok, dispatcher = pcall(group_api.toggle)
        if ok and dispatcher then
          hl.dispatch(dispatcher)
          return
        end
      end
      if dsp and dsp.exec_raw then
        pcall(hl.dispatch, dsp.exec_raw("togglegroup"))
      end
    end
  end
  if name == "changegroupactive" then
    local group_api = (dsp and dsp.group) or (hl and hl.dsp and hl.dsp.group) or {}
    if group_api and group_api.next and group_api.prev then
      if args == "b" or args == "prev" or args == "-1" then
        return function()
          hl.dispatch(group_api.prev())
        end
      end
      return function()
        hl.dispatch(group_api.next())
      end
    end
  end
  if name == "pseudo" and window_api.pseudo then
    return function()
      hl.dispatch(window_api.pseudo())
    end
  end
  if (name == "layoutmsg" or name == "layout") and dsp and dsp.layout then
    return function()
      local ok, dispatcher = pcall(dsp.layout, args)
      if ok and dispatcher then
        hl.dispatch(dispatcher)
      end
    end
  end
  if name == "togglesplit" and dsp and dsp.layout then
    return function()
      local ok, dispatcher = pcall(dsp.layout, "togglesplit")
      if ok and dispatcher then
        hl.dispatch(dispatcher)
      end
    end
  end
  if name == "resizewindow" and window_api.resize then
    return function()
      hl.dispatch(window_api.resize())
    end
  end
  if name == "resizeactive" and window_api.resize then
    local x, y = args:match("^(%-?%d+)%s+(%-?%d+)$")
    if x and y then
      return function()
        hl.dispatch(window_api.resize({ x = tonumber(x) or 0, y = tonumber(y) or 0, relative = true }))
      end
    end
  end
  if name == "movewindow" then
    if args == "" and window_api.drag then
      return function()
        hl.dispatch(window_api.drag())
      end
    end
    if args ~= "" and window_api.move then
      return function()
        local ok, dispatcher = pcall(window_api.move, { direction = direction(args) })
        if ok and dispatcher then
          hl.dispatch(dispatcher)
        end
      end
    end
    if args ~= "" then
      return raw_dispatch_cmd("movewindow " .. args)
    end
    return raw_dispatch_cmd("movewindow")
  end
  if args ~= "" then
    return raw_dispatch_cmd(name .. " " .. args)
  end
  return raw_dispatch_cmd(name)
end

local function bind(mods, key, fn, opts)
  local seen = {}
  for _, key_variant in ipairs(key_variants(key, mods)) do
    local key_chord = chord(mods, key_variant)
    if not seen[key_chord] then
      seen[key_chord] = true
      if opts then
        hl.bind(key_chord, fn, opts)
      else
        hl.bind(key_chord, fn)
      end
    end
  end
end

local function unbind(mods, key)
  if hl.unbind then
    local seen = {}
    for _, key_variant in ipairs(key_variants(key, mods)) do
      local key_chord = chord(mods, key_variant)
      if not seen[key_chord] then
        seen[key_chord] = true
        local ok = pcall(hl.unbind, mods, key_variant)
        if not ok then
          pcall(hl.unbind, key_chord)
        end
      end
    end
  end
end

-- Converted from configs/Keybinds.conf
bind(
  "SUPER",
  "D",
  exec_cmd("pkill rofi || true; $HOME/.config/hypr/scripts/RofiFocusedWallpaperLink.sh >/dev/null 2>&1 || true; rofi -show drun -modi drun,filebrowser,run,window -config $HOME/.config/hypr/rofi/config.rasi"),
  { description = "lanceur d'applications" }
)
bind("SUPER", "B", exec_cmd('xdg-open "https://"'), { description = "ouvrir le navigateur par défaut" })
bind("SUPER", "A", exec_cmd("$HOME/.config/hypr/scripts/OverviewToggle.sh"), { description = "aperçu du bureau" })
bind(
  "SUPER CTRL",
  "A",
  exec_cmd("pkill rofi || true && ags -t 'overview'"),
  { description = "aperçu Ags" }
)
bind(
  "SUPER",
  "Return",
  exec_cmd("$HOME/.config/hypr/scripts/LaunchTerminal.sh '$term'"),
  { description = "ouvrir le terminal" }
)
bind(
  "SUPER",
  "E",
  exec_cmd("$HOME/.config/hypr/scripts/LaunchFileManager.sh '$files' '$term'"),
  { description = "gestionnaire de fichiers" }
)
bind("SUPER", "C", exec_cmd("$HOME/.config/hypr/scripts/rofi-ssh-menu.sh"), { description = "gestionnaire de sessions SSH" })
bind(
  "SUPER",
  "T",
  exec_cmd("$HOME/.config/hypr/scripts/ThemeChanger.sh"),
  { description = "sélecteur global de thèmes avec Wallust" }
)
bind("SUPER", "H", exec_cmd("$HOME/.config/hypr/scripts/KeyHints.sh"), { description = "aide / aide-mémoire" })
bind("SUPER ALT", "R", exec_cmd("$HOME/.config/hypr/scripts/Refresh.sh"), { description = "actualiser la barre et les menus" })
bind("SUPER ALT", "E", exec_cmd("$HOME/.config/hypr/scripts/RofiEmoji.sh"), { description = "menu des emojis" })
bind("SUPER", "S", exec_cmd("$HOME/.config/hypr/scripts/RofiSearch.sh"), { description = "recherche web" })
bind(
  "SUPER CTRL",
  "S",
  exec_cmd("$HOME/.config/hypr/scripts/RofiFocusedWallpaperLink.sh >/dev/null 2>&1 || true; rofi -show window -config $HOME/.config/hypr/rofi/config.rasi"),
  { description = "sélecteur de fenêtres" }
)
bind("SUPER ALT", "O", exec_cmd("$HOME/.config/hypr/scripts/ChangeBlur.sh"), { description = "activer/désactiver le flou" })
bind("SUPER SHIFT", "G", exec_cmd("$HOME/.config/hypr/scripts/GameMode.sh"), { description = "activer/désactiver le mode jeu" })
bind(
  "SUPER ALT",
  "L",
  exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh toggle"),
  { description = "changer de layout" }
)
bind("SUPER ALT", "V", exec_cmd("$HOME/.config/hypr/scripts/ClipManager.sh"), { description = "gestionnaire de presse-papiers" })
bind(
  "SUPER CTRL",
  "R",
  exec_cmd("$HOME/.config/hypr/scripts/RofiThemeSelector.sh"),
  { description = "sélecteur de thème Rofi" }
)
bind(
  "SUPER CTRL SHIFT",
  "R",
  exec_cmd("pkill rofi || true && $HOME/.config/hypr/scripts/RofiThemeSelector-modified.sh"),
  { description = "sélecteur de thème Rofi (modifié)" }
)
bind(
  "SUPER CTRL",
  "K",
  exec_cmd("$HOME/.config/hypr/scripts/Kitty_themes.sh"),
  { description = "sélecteur de thème Kitty" }
)
bind(
  "SUPER CTRL",
  "G",
  exec_cmd("$HOME/.config/hypr/scripts/Ghostty_themes.sh"),
  { description = "sélecteur de thème Ghostty" }
)
bind(
  "SUPER CTRL",
  "W",
  exec_cmd("$HOME/.config/hypr/scripts/RofiWlogoutTheme.sh"),
  { description = "sélecteur de thème Wlogout" }
)
bind(
  "SUPER CTRL SHIFT",
  "W",
  exec_cmd("$HOME/.config/hypr/scripts/RofiWlogoutWallust.sh"),
  { description = "sélecteur de fond d'écran dynamique Wlogout" }
)
bind(
  "SUPER SHIFT",
  "B",
  exec_cmd("$HOME/.config/hypr/UserScripts/RainbowBorders-low-cpu.sh  --run-once"),
  { description = "activer une bordure arc-en-ciel statique" }
)
bind(
  "SUPER SHIFT",
  "H",
  exec_cmd("$HOME/.config/hypr/scripts/Toggle-Active-Window-Audio.sh"),
  { description = "activer/désactiver le son de la fenêtre active" }
)
bind(
  "ALT SHIFT",
  "S",
  exec_cmd("$HOME/.config/hypr/scripts/hyprshot.sh -m region -o $HOME/Pictures/Screenshots"),
  { description = "capture d'écran avec Hyprshot" }
)
bind("SUPER SHIFT", "F", dispatch("fullscreen", ""), { description = "plein écran" })
bind("SUPER", "F", dispatch("fullscreen", "1"), { description = "maximiser la fenêtre" })
bind("SUPER", "SPACE", dispatch("togglefloating", ""), { description = "rendre la fenêtre actuelle flottante" })
bind(
  "SUPER ALT",
  "SPACE",
  exec_cmd("$HOME/.config/hypr/scripts/Float-all-Windows.sh"),
  { description = "rendre toutes les fenêtres flottantes" }
)
bind(
  "SUPER CTRL",
  "SPACE",
  exec_cmd("$HOME/.config/hypr/scripts/float.all.samesize.lua"),
  { description = "rendre toutes les fenêtres flottantes de même taille" }
)
bind(
  "SUPER SHIFT",
  "Return",
  exec_cmd("$HOME/.config/hypr/scripts/Dropterminal.sh kitty"),
  { description = "terminal déroulant" }
)
bind(
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
  { description = "zoomer" }
)
bind(
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
  { description = "dézoomer" }
)
bind("SUPER CTRL ALT", "B", exec_cmd("pkill -SIGUSR1 waybar"), { description = "afficher/masquer Waybar" })
bind("SUPER CTRL", "B", exec_cmd("$HOME/.config/hypr/scripts/WaybarStyles.sh"), { description = "menu des styles Waybar" })
bind("SUPER ALT", "B", exec_cmd("$HOME/.config/hypr/scripts/WaybarLayout.sh"), { description = "menu de disposition Waybar" })
bind(
  "SUPER",
  "N",
  exec_cmd("$HOME/.config/hypr/scripts/Hyprsunset.sh toggle"),
  { description = "activer/désactiver Hyprsunset - mode nuit" }
)
bind("SUPER SHIFT", "M", exec_cmd("$HOME/.config/hypr/UserScripts/RofiBeats.sh"), { description = "musique en ligne" })
bind("SUPER", "W", exec_cmd("$HOME/.config/hypr/UserScripts/WallCarousel.py"), { description = "carrousel de fonds d'écran" })
bind(
  "SUPER SHIFT",
  "W",
  exec_cmd("$HOME/.config/hypr/UserScripts/EffetsPlus.sh"),
  { description = "effets du fond d'écran" }
)
bind(
  "CTRL ALT",
  "W",
  exec_cmd("$HOME/.config/hypr/UserScripts/WallpaperRandom.sh"),
  { description = "fond d'écran aléatoire" }
)
bind("SUPER CTRL", "O", exec_cmd("$HOME/.config/hypr/scripts/ToggleOpacity.sh"), { description = "activer/désactiver l'opacité de la fenêtre active" })
bind("SUPER SHIFT", "K", exec_cmd("$HOME/.config/hypr/scripts/KeyBinds.sh"), { description = "rechercher des raccourcis" })
bind("SUPER SHIFT", "A", exec_cmd("$HOME/.config/hypr/scripts/Animations.sh"), { description = "menu des animations" })
bind(
  "SUPER SHIFT",
  "O",
  exec_cmd("$HOME/.config/hypr/scripts/ZshChangeTheme.sh"),
  { description = "changer le thème oh-my-zsh" }
)
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
  { description = "changer globalement la disposition du clavier", locked = true }
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
  { description = "changer la disposition du clavier par fenêtre", locked = true }
)
bind("SUPER ALT", "C", exec_cmd("kitty --class calculette --title Calculatrice -e qalc"), { description = "calculatrice" })
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
bind("CTRL ALT", "D", exec_cmd("$HOME/.config/hypr/scripts/Dock.sh"), { description = "afficher/masquer le dock" })
bind("SUPER SHIFT", "N", exec_cmd("swaync-client -t -sw"), { description = "panneau de notifications" })
bind(
  "SUPER SHIFT",
  "E",
  exec_cmd("$HOME/.config/hypr/scripts/Kool_Quick_Settings.sh"),
  { description = "menu des paramètres rapides" }
)
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
bind("SUPER", "M", exec_cmd("hyprctl dispatch splitratio 0.3"), { description = "définir le ratio de séparation à 0,3" })
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
  "SUPER",
  "R",
  exec_cmd("bash $HOME/.config/hypr/scripts/ScrollCycleColumnWidth.sh"),
  { description = "changer la largeur de colonne (scrolling)" }
)
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
-- Hyprview: SUPER CTRL+Tab (bound later after workspace/group Tab binds)
-- "smartgrid", "justified", "masonry", "bands", "hero", "spiral"
-- "satellite", "staggered", "columnar", "vortex", "random"
bind("ALT", "Tab", dispatch("cyclenext", ""), { description = "fenêtre suivante" })
bind("ALT", "Tab", dispatch("bringactivetotop", ""), { description = "placer la fenêtre active au premier plan" })
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
bind("SUPER SHIFT", "left", dispatch("resizeactive", "-50 0"), { description = "redimensionner vers la gauche (-50)", ["repeat"] = true })
bind(
  "SUPER SHIFT",
  "right",
  dispatch("resizeactive", "50 0"),
  { description = "redimensionner vers la droite (+50)", ["repeat"] = true }
)
bind("SUPER SHIFT", "up", dispatch("resizeactive", "0 -50"), { description = "redimensionner vers le haut (-50)", ["repeat"] = true })
bind("SUPER SHIFT", "down", dispatch("resizeactive", "0 50"), { description = "redimensionner vers le bas (+50)", ["repeat"] = true })
bind("SUPER CTRL", "left", dispatch("movewindow", "l"), { description = "déplacer la fenêtre vers la gauche" })
bind("SUPER CTRL", "right", dispatch("movewindow", "r"), { description = "déplacer la fenêtre vers la droite" })
bind("SUPER CTRL", "up", dispatch("movewindow", "u"), { description = "déplacer la fenêtre vers le haut" })
bind("SUPER CTRL", "down", dispatch("movewindow", "d"), { description = "déplacer la fenêtre vers le bas" })
bind("SUPER ALT", "left", dispatch("swapwindow", "l"), { description = "échanger la fenêtre vers la gauche" })
bind("SUPER ALT", "right", dispatch("swapwindow", "r"), { description = "échanger la fenêtre vers la droite" })
bind("SUPER ALT", "up", dispatch("swapwindow", "u"), { description = "échanger la fenêtre vers le haut" })
bind("SUPER ALT", "down", dispatch("swapwindow", "d"), { description = "échanger la fenêtre vers le bas" })
bind("SUPER", "G", dispatch("togglegroup", ""), { description = "activer/désactiver le groupe" })
bind("SUPER", "Tab", dispatch("changegroupactive", "f"), { description = "groupe suivant" })
-- SUPER CTRL+Tab is Hyprview Toggle (not change active in group)
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
bind("SUPER", "tab", dispatch("workspace", "m+1"), { description = "espace de travail suivant" })
bind("SUPER SHIFT", "tab", dispatch("workspace", "m-1"), { description = "espace de travail précédent" })
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
bind("SUPER", "mouse_down", dispatch("workspace", "e+1"), { description = "espace de travail suivant" })
bind("SUPER", "mouse_up", dispatch("workspace", "e-1"), { description = "espace de travail précédent" })
bind("SUPER", "period", dispatch("workspace", "e+1"), { description = "espace de travail suivant" })
bind("SUPER", "comma", dispatch("workspace", "e-1"), { description = "espace de travail précédent" })
bind("SUPER", "mouse:272", dispatch("movewindow", ""), { description = "déplacer la fenêtre" })
bind("SUPER", "mouse:273", dispatch("resizewindow", ""), { description = "redimensionner la fenêtre" })

-- KB passthrough submap: SUPER SHIFT P enters a submap that lets the keyboard
-- pass through to the focused window. The only key bound inside the submap is
-- SUPER ALT P, which resets back to the normal submap. Waybar's hyprland/submap
-- module shows "submap: Bind KB" only while it is active.
bind("SUPER SHIFT", "P", hl.dsp.submap("Bind KB"), { description = "entrer dans le sous-menu clavier passthrough" })
hl.define_submap("Bind KB", function()
  bind("SUPER ALT", "P", hl.dsp.submap("reset"), { description = "quitter le sous-menu clavier passthrough" })
end)
