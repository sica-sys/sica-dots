#!/usr/bin/env bash
if ip a show tun0 >/dev/null 2>&1; then
  IP=$(ip -4 a show tun0 | awk '/inet /{print $2}' | cut -d/ -f1)
  echo "{\"text\":\"🎯 $IP\",\"class\":\"on\",\"tooltip\":\"THM connecté\"}"
else
  echo "{\"text\":\"🎯 THM\",\"class\":\"off\",\"tooltip\":\"THM déconnecté - clic pour connecter\"}"
fi
