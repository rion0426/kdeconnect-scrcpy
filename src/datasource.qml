
    // kdeconnect-scrcpy
    Plasma5Support.DataSource {
        id: scrcpyLauncher
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }
