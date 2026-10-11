#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

qt5compat_path=$(find /nix/store -maxdepth 1 -iname "*qt5compat-*" -not -iname "*.drv" -not -iname "*.tar.xz*" 2>/dev/null | head -1)
export QML2_IMPORT_PATH="${qt5compat_path}/lib/qt-6/qml:${QML2_IMPORT_PATH}"

default_layout="smartgrid"
layout_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/UserConfigs/hyprview-layout.conf"
layout="${1:-}"
config_name="qs-hyprview"
config_path="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/${config_name}"

if [[ -z "$layout" ]]; then
  if [[ -f "$layout_config" && -r "$layout_config" ]]; then
    layout="$(sed -n '1p' "$layout_config" | tr -d '[:space:]')"
  else
    notify-send "Can't read hyprview-layout.conf, falling back to smartgrid"
  fi
fi

case "$layout" in
smartgrid | justified | masonry | bands | hero | spiral | satellite | staggered | columnar | vortex | random) ;;
*) layout="$default_layout" ;;
esac

if ! pgrep -u "${UID}" -f "qs .* -p ${config_path}($| )" >/dev/null 2>&1; then
  setsid nixGL qs --log-rules "qt.qpa.wayland.textinput.warning=false" -p "${config_path}" >/dev/null 2>&1 &
  disown
  sleep 0.5
fi

if ! qs -c "${config_name}" ipc call expose toggle "${layout}" >/dev/null 2>&1; then
  sleep 0.3
  qs -c "${config_name}" ipc call expose toggle "${layout}"
fi
