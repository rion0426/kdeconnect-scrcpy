#!/bin/bash
# Installs kdeconnect-scrcpy. Re-run after every KDE Connect update: the tray applet override
# is rebuilt from the system copy, so it never goes stale.
set -euo pipefail
cd "$(dirname "$0")"

for cmd in scrcpy adb kdeconnect-cli notify-send; do
    command -v "$cmd" >/dev/null || { echo "$cmd not found, install it first." >&2; exit 1; }
done

BIN="$HOME/.local/bin/kdeconnect-scrcpy"
SYS_PLASMOID=/usr/share/plasma/plasmoids/org.kde.kdeconnect
PLASMOID="$HOME/.local/share/plasma/plasmoids/org.kde.kdeconnect"
QML="$PLASMOID/contents/ui/DeviceDelegate.qml"

install -Dm755 src/kdeconnect-scrcpy.sh "$BIN"

rm -rf "$PLASMOID"
mkdir -p "$(dirname "$PLASMOID")"
cp -r "$SYS_PLASMOID" "$PLASMOID"

# Patch the current system QML instead of shipping a copy tied to one KDE Connect version.
for anchor in '^import org.kde.plasma.extras as PlasmaExtras$' '^    id: root$' '^        id: menu$'; do
    [ "$(grep -c "$anchor" "$QML")" = 1 ] || { rm -rf "$PLASMOID"; echo "DeviceDelegate.qml changed upstream ($anchor), patch needs updating." >&2; exit 1; }
done
sed -i \
    -e '/^import org.kde.plasma.extras as PlasmaExtras$/a import org.kde.plasma.plasma5support as Plasma5Support' \
    -e "/^    id: root\$/r src/datasource.qml" \
    -e "/^        id: menu\$/r src/menuitem.qml" \
    "$QML"
sed -i "s|@BIN@|$BIN|" "$QML"

mkdir -p "$HOME/.local/share/applications"
cat >"$HOME/.local/share/applications/kdeconnect-scrcpy.desktop" <<EOF
[Desktop Entry]
Name=Phone Mirror (scrcpy)
Comment=Mirror the KDE Connect phone with scrcpy
Exec=$BIN
Icon=phone
Terminal=false
Type=Application
Categories=Utility;RemoteAccess;
EOF

# a plasmashell started outside systemd would keep the old QML and make the unit exit at once
kquitapp6 plasmashell 2>/dev/null || true
systemctl --user restart plasma-plasmashell.service
echo "Installed. KDE Connect tray -> phone -> ⋮ -> Share Screen."
