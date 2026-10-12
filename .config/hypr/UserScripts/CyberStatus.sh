#!/usr/bin/env bash
if nordvpn status 2>/dev/null|grep -qi connected; then echo '{"text":"Nord","class":"on"}'; elif ip a show tun0 2>/dev/null|grep -q inet; then IP=$(ip -4 a show tun0|awk "/inet /{print \$2}"|cut -d/ -f1); echo "{\"text\":\"THM $IP\",\"class\":\"thm\"}"; else IP=$(ip -4 a|awk "/inet /&&!/127.0/{print \$2;exit}"|cut -d/ -f1); echo "{\"text\":\"IP $IP\",\"class\":\"off\"}"; fi
