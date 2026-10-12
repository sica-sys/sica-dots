#!/usr/bin/env bash
pgrep -f "sf.py -l" >/dev/null || (cd ~/Pentest && setsid sfwebui >/dev/null 2>&1 &) 
sleep 2; xdg-open http://127.0.0.1:5001
