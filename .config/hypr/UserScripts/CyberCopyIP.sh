#!/usr/bin/env bash
ip -4 a | awk "/inet /&&!/127.0/{print \$2;exit}" | cut -d/ -f1 | tr -d "\n" | wl-copy
notify-send "IP copiee"
