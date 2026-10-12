#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
TH="$HOME/.config/hypr/rofi/themes/Cava-Verre-opaque.rasi"
L="$HOME/Pentest/loot"; mkdir -p "$L"
k(){ kitty -e bash -c "$1; echo; read -p '[Entree pour fermer]'"; }
O="Scan reseau local
Scan cible (nmap)
Nuclei (vulns web)
WhatWeb (technos)
Feroxbuster (dossiers caches)
dirb (dossiers web)
wafw00f (detecte WAF)
Pseudo (sherlock)
Pseudo (maigret)
Email (holehe)
SpiderFoot (web)
Metadonnees (exiftool)
Nikto (scan web)
Metasploit (exploitation)
recon-ng (OSINT)
theHarvester (emails/domaine)
Wireshark
Notes de pentest"
C=$(echo "$O" | rofi -dmenu -i -p "Cyber" -theme "$TH")
case "$C" in
 *"reseau local"*) k 'sudo nmap -sn $(ip -4 a|awk "/inet /&&!/127/{print \$2;exit}")';;
 *"cible (nmap)"*) k 'read -p "Cible: " t; sudo nmap -sV -oN "'"$L"'/nmap_$t.txt" $t; echo "-> loot"';;
 *Nuclei*)   k 'read -p "URL: " u; nuclei -u $u -o "'"$L"'/nuclei_$(date +%s).txt"; echo "-> loot"';;
 *WhatWeb*)  k 'read -p "URL: " u; whatweb -v $u | tee "'"$L"'/whatweb_$(date +%s).txt"';;
 *dirb*) k 'read -p "URL: " u; dirb $u -o "'"$L"'/dirb_$(date +%s).txt"';;
 *Feroxbuster*) k 'read -p "URL: " u; feroxbuster -u $u -o "'"$L"'/ferox_$(date +%s).txt"';;
 *wafw00f*)  k 'read -p "URL: " u; wafw00f $u | tee "'"$L"'/waf_$(date +%s).txt"';;
 *sherlock*) k 'read -p "Pseudo: " u; cd "'"$L"'" && sherlock $u --txt; echo "-> loot/$u.txt"';;
 *maigret*)  k 'read -p "Pseudo: " u; maigret $u -H --folderoutput "'"$L"'"; echo "-> loot"';;
 *holehe*)   k 'read -p "Email: " e; cd "'"$L"'" && holehe $e --only-used';;
 *SpiderFoot*) "$HOME/.config/hypr/UserScripts/CyberSpiderfoot.sh" & ;;
 *Metadonnees*) k 'read -p "Fichier: " x; exiftool "$x" | tee "'"$L"'/exif_$(date +%s).txt"';;
 *Nikto*)    k 'read -p "URL: " u; nikto -h $u -o "'"$L"'/nikto_$(date +%s).txt"';;
 *Metasploit*) kitty -e msfconsole;;
 *recon-ng*) kitty -e recon-ng;;
 *theHarvester*) k 'read -p "Domaine: " d; theHarvester -d $d -b all -f "'"$L"'/harvest_$d"';;
 *Wireshark*) wireshark & ;;
 *Notes*) kitty -e nvim "$HOME/Pentest/notes";;
esac
