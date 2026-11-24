#!/bin/bash
# Mirror a KDE Connect phone with scrcpy.  Usage: kdeconnect-scrcpy [kdeconnect-device-id]
#
# Connection order: USB > <IP KDE Connect reports>:5555 > wireless debugging (adb mDNS).
# Whenever the phone is reachable, adbd is switched to TCP port 5555 so the next run works
# on any network KDE Connect works on, until the phone reboots (Android resets it then).

notify() { notify-send -a "KDE Connect" -i phone "Share Screen" "$1"; }

ip=$(kdeconnect-cli -a | grep -F -- "${1:-}" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
[ -n "$ip" ] && timeout 3 adb connect "$ip:5555" >/dev/null 2>&1

list() { adb devices | awk 'NR>1 && $2=="device" {print $1}'; }
devices=$(list)
if [ -z "$devices" ]; then # give adb's mDNS auto-connect (wireless debugging) a moment
    timeout 5 adb wait-for-device 2>/dev/null
    devices=$(list)
fi

serial=$(grep -v -e : -e _adb-tls <<<"$devices" | head -n1)                    # USB
[ -z "$serial" ] && [ -n "$ip" ] && serial=$(grep -Fx "$ip:5555" <<<"$devices")
[ -z "$serial" ] && serial=$(head -n1 <<<"$devices")                           # mDNS etc.

if [ -z "$serial" ]; then
    notify "Phone not reachable over adb. Plug in USB once, or turn on Wireless debugging."
    exit 1
fi

if [ "$(adb -s "$serial" shell getprop service.adb.tcp.port | tr -d '\r')" != 5555 ]; then
    adb -s "$serial" tcpip 5555 >/dev/null 2>&1
    sleep 2 # adbd restarts; USB and wireless-debugging transports come back by themselves
    timeout 10 adb -s "$serial" wait-for-device
fi

scrcpy -s "$serial" --video-bit-rate=12M --max-fps=60 --window-title="Phone Mirror" ||
    notify "scrcpy failed on adb device '$serial'."
