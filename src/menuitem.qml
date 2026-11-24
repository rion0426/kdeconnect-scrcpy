
        // kdeconnect-scrcpy
        PlasmaExtras.MenuItem {
            icon: "phone"
            text: "Share Screen"
            onClicked: scrcpyLauncher.connectSource("@BIN@")
        }
