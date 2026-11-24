# kdeconnect-scrcpy

Adds a **Share Screen** item to the KDE Connect tray menu (⋮ next to the phone) that mirrors the phone with [scrcpy](https://github.com/Genymobile/scrcpy).
Fork of [MAKHMUDuz/kdeconnect-scrcpy](https://github.com/MAKHMUDuz/kdeconnect-scrcpy).

## Requirements
KDE Plasma 6, `kdeconnect`, `scrcpy`, `android-tools` (adb), `libnotify`.

## Install
```bash
./install.sh     # re-run after every KDE Connect update
./uninstall.sh
```
Installs `~/.local/bin/kdeconnect-scrcpy` and a tray applet override in
`~/.local/share/plasma/plasmoids/org.kde.kdeconnect`, patched from the current system copy.

## Connection
USB if plugged in, otherwise Android **Wireless debugging** (Android 11+, TLS-encrypted),
found via adb mDNS. Pair once: phone → Developer options → Wireless debugging → *Pair device
with pairing code*, then `adb pair <ip>:<port>`. On a new Wi-Fi, allow wireless debugging on the
phone ("Always allow on this network"); networks that block multicast won't work.

Unencrypted `adb tcpip` (IP:5555) connections are deliberately never used.
