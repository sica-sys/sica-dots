#!/usr/bin/env bash
export DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
notif(){ notify-send "TryHackMe" "$1"; }
if pgrep -x openvpn >/dev/null; then
  sudo pkill -x openvpn; sleep 1; notif "VPN coupé ❌"
else
  O=$(find ~/Pentest/vpn -iname "*.ovpn" | head -1)
  [ -z "$O" ] && { notif "Aucun .ovpn dans ~/Pentest/vpn"; exit; }
  sudo openvpn --config "$O" --daemon
  sleep 3
  ip a show tun0 >/dev/null 2>&1 && notif "VPN connecté ✅" || notif "Échec connexion"
fi
pkill -RTMIN+9 waybar 2>/dev/null
