#!/bin/bash
set -eu
rm -rf "$HOME/.local/share/plasma/plasmoids/org.kde.kdeconnect"
rm -f "$HOME/.local/bin/kdeconnect-scrcpy" "$HOME/.local/share/applications/kdeconnect-scrcpy.desktop"
systemctl --user restart plasma-plasmashell.service
echo "Uninstalled."
