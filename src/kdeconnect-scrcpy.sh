#!/bin/bash
# Mirror the phone with scrcpy over USB, else over Android wireless debugging (TLS).
# Plain `adb tcpip` connections (IP:port) are never used: they are unencrypted.

notify() { notify-send -a "KDE Connect" -i phone "Share Screen" "$1"; }
list() { adb devices | awk 'NR>1 && $2=="device" {print $1}'; }
# launched from the tray the output is discarded; send it to `journalctl --user -t kdeconnect-scrcpy`
[ -t 2 ] || exec &> >(systemd-cat -t kdeconnect-scrcpy)
echo "start"

devices=$(list)
# adb's own mDNS auto-connect misses phones whose adbd restarted, so connect paired services explicitly
for _ in 1 2 3 4 5; do
    [ -n "$devices" ] && break
    adb mdns services | awk '$2=="_adb-tls-connect._tcp" {print $1"."$2}' |
        xargs -r -n1 timeout 3 adb connect >/dev/null 2>&1
    sleep 1
    devices=$(list)
done

serial=$(grep -v -e : -e _adb-tls <<<"$devices" | head -n1)    # USB
[ -z "$serial" ] && serial=$(grep _adb-tls <<<"$devices" | head -n1)

if [ -z "$serial" ]; then
    notify "Phone not found. Plug in USB, or turn on Wireless debugging (same Wi-Fi, paired once)."
    exit 1
fi

scrcpy -s "$serial" --video-bit-rate=12M --max-fps=60 --window-title="Phone Mirror" ||
    notify "scrcpy failed on adb device '$serial'."
