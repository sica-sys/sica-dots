#!/usr/bin/env bash
if nordvpn status 2>/dev/null|grep -qi connected; then nordvpn disconnect; else nordvpn connect; fi
