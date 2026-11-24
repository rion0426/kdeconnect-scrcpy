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

## Connecting on any network
The script tries, in order: USB → `<IP from KDE Connect>:5555` → wireless debugging (adb mDNS).
Whenever it reaches the phone it switches adbd to TCP port 5555, so later runs work on **any
Wi-Fi where KDE Connect sees the phone** — until the phone reboots. After a reboot, plug in USB
once (or have Wireless debugging on) and press Share Screen; that re-arms it.

Port 5555 still needs this PC's adb key to be authorized on the phone.
