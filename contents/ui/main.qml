import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume as PulseAudio

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Desktop/Full representation default dimensions
    width: Kirigami.Units.gridUnit * 18.5
    height: Kirigami.Units.gridUnit * 16.5

    preferredRepresentation: fullRepresentation

    // Language detection and bilingual translations
    readonly property bool isTurkish: Qt.locale().name.toLowerCase().startsWith("tr")

    readonly property var translations: {
        "en": {
            "devices": "Devices",
            "apps": "Applications",
            "theme": "Theme: %1",
            "unmute": "Unmute",
            "mute": "Mute",
            "muted": "Muted",
            "live_vu_output": "Live VU Output",
            "no_device": "No Output Device",
            "unmute_mic": "Unmute Mic",
            "mute_mic": "Mute Mic",
            "mic_muted": "Microphone Muted",
            "live_vu_input": "Live VU Input",
            "no_mic": "No Microphone",
            "no_apps": "No Active Applications",
            "no_apps_desc": "Applications playing audio will automatically appear here.",
            "application": "Application"
        },
        "tr": {
            "devices": "Aygıtlar",
            "apps": "Uygulamalar",
            "theme": "Tema: %1",
            "unmute": "Sesi Aç",
            "mute": "Sesi Kapat",
            "muted": "Sessiz",
            "live_vu_output": "Canlı VU Çıkış",
            "no_device": "Aygıt Yok",
            "unmute_mic": "Mikrofonu Aç",
            "mute_mic": "Mikrofonu Kapat",
            "mic_muted": "Mikrofon Kapalı",
            "live_vu_input": "Canlı VU Giriş",
            "no_mic": "Mikrofon Yok",
            "no_apps": "Çalan Uygulama Yok",
            "no_apps_desc": "Herhangi bir medya veya tarayıcı sesi başladığında burada listelenecektir.",
            "application": "Uygulama"
        }
    }

    function t(key, arg) {
        let lang = isTurkish ? "tr" : "en";
        let str = (translations[lang] && translations[lang][key]) || (translations["en"] && translations["en"][key]) || key;
        if (arg !== undefined) {
            str = str.replace("%1", arg);
        }
        return str;
    }

    // Tab state (0: Aygıtlar / Devices, 1: Uygulamalar / Apps)
    property int currentTabIndex: 0

    // Multi-Theme Engine State (0: Breeze, 1: Vintage Cream, 2: Cyber Dark Glass, 3: Nordic Frost)
    property int currentThemeIndex: 0

    readonly property var themes: [
        {
            name: "Breeze",
            displayName: "Breeze (Plasma)",
            isBreeze: true,
            bg: Kirigami.Theme.backgroundColor,
            cardBg: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06),
            border: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15),
            text: Kirigami.Theme.textColor,
            subText: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.7),
            accent: Kirigami.Theme.highlightColor,
            knobBody: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.14),
            knobText: Kirigami.Theme.textColor,
            knobTrack: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.20),
            meterNormal: "#2ecc71",
            meterWarn: "#f39c12",
            meterPeak: "#e74c3c"
        },
        {
            name: "Warm Vintage Cream",
            displayName: "Warm Vintage Cream",
            isBreeze: false,
            bg: "#f5f0e8",
            cardBg: "#ebe3d5",
            border: "#d49a3d",
            text: "#1a2744",
            subText: "#4a5568",
            accent: "#d49a3d",
            knobBody: "#2b2118",
            knobText: "#f5f0e8",
            knobTrack: "#d8cebe",
            meterNormal: "#2d7f36",
            meterWarn: "#d49a3d",
            meterPeak: "#c0392b"
        },
        {
            name: "Cyber Dark Glass",
            displayName: "Cyber Dark Glass",
            isBreeze: false,
            bg: "#e60f141d",
            cardBg: "#73182436",
            border: "#00f0ff",
            text: "#e6f8ff",
            subText: "#6ee7b7",
            accent: "#00f0ff",
            knobBody: "#0d1824",
            knobText: "#00f0ff",
            knobTrack: "#1e3347",
            meterNormal: "#00f0ff",
            meterWarn: "#ffcc00",
            meterPeak: "#ff0055"
        },
        {
            name: "Nordic Frost",
            displayName: "Nordic Frost",
            isBreeze: false,
            bg: "#f22e3440",
            cardBg: "#803b4252",
            border: "#88c0d0",
            text: "#eceff4",
            subText: "#d8dee9",
            accent: "#88c0d0",
            knobBody: "#434c5e",
            knobText: "#eceff4",
            knobTrack: "#4c566a",
            meterNormal: "#a3be8c",
            meterWarn: "#ebcb8b",
            meterPeak: "#bf616a"
        }
    ]

    readonly property var activeTheme: themes[currentThemeIndex]

    // PulseAudio backend objects with fallback to Server
    readonly property var defaultSink: PulseAudio.PreferredDevice.sink || PulseAudio.Server.defaultSink
    readonly property var defaultMic: PulseAudio.PreferredDevice.source || PulseAudio.Server.defaultSource

    // Sinks and Sources Models
    readonly property PulseAudio.PulseObjectFilterModel filteredSinks: PulseAudio.PulseObjectFilterModel {
        id: filteredSinks
        filterOutInactiveDevices: true
        sourceModel: PulseAudio.SinkModel { id: sinkModel }
    }

    readonly property PulseAudio.PulseObjectFilterModel filteredSources: PulseAudio.PulseObjectFilterModel {
        id: filteredSources
        filterOutInactiveDevices: true
        sourceModel: PulseAudio.SourceModel { id: sourceModel }
    }

    // Application Streams Model
    readonly property PulseAudio.PulseObjectFilterModel filteredAppStreams: PulseAudio.PulseObjectFilterModel {
        id: filteredAppStreams
        sourceModel: PulseAudio.SinkInputModel { id: sinkInputModel }
    }

    // Volume Intensity Monitors (Active only when visible & tab is Aygıtlar)
    readonly property PulseAudio.VolumeMonitor sinkMonitor: PulseAudio.VolumeMonitor {
        id: sinkMonitor
        target: (root.visible && root.currentTabIndex === 0 && Boolean(root.defaultSink) && !root.defaultSink.muted) ? root.defaultSink : null
    }

    readonly property PulseAudio.VolumeMonitor micMonitor: PulseAudio.VolumeMonitor {
        id: micMonitor
        target: (root.visible && root.currentTabIndex === 0 && Boolean(root.defaultMic) && !root.defaultMic.muted) ? root.defaultMic : null
    }

    // Volume formatting helper
    function formatVolume(val) {
        if (val === undefined || val === null) {
            return "0%";
        }
        return Math.round((val / 65536) * 100) + "%";
    }

    // Compact Representation (for panel placement)
    compactRepresentation: MouseArea {
        id: compactRoot
        implicitWidth: Kirigami.Units.gridUnit * 2.5
        implicitHeight: Kirigami.Units.gridUnit * 2.5
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: root.defaultSink && root.defaultSink.muted ? "audio-volume-muted" : "audio-volume-high"
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            }

            PlasmaComponents.Label {
                visible: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                text: root.formatVolume(root.defaultSink ? root.defaultSink.volume : 0)
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    // Full Representation (Desktop Card & Popup View)
    fullRepresentation: Item {
        id: fullRepItem
        implicitWidth: Kirigami.Units.gridUnit * 18.5
        implicitHeight: contentColumn.implicitHeight + Kirigami.Units.mediumSpacing
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        // Themed outer frame (100% transparent so widget cards float cleanly on desktop wallpaper)
        Rectangle {
            id: themedFrame
            anchors.fill: parent
            color: "transparent"
            border.color: "transparent"
            border.width: 0
            clip: true

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                // ==========================================
                // HEADER ROW: View Toggle & Theme Selector
                // ==========================================
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    // View Toggle Button (Aygıtlar <-> Uygulamalar)
                    Rectangle {
                        id: viewToggleBtn
                        Layout.fillWidth: true
                        height: Kirigami.Units.gridUnit * 1.9
                        radius: 6
                        color: root.activeTheme.isBreeze
                               ? Qt.rgba(root.activeTheme.accent.r, root.activeTheme.accent.g, root.activeTheme.accent.b, 0.15)
                               : root.activeTheme.cardBg
                        border.color: root.activeTheme.border
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Kirigami.Units.smallSpacing

                            Kirigami.Icon {
                                source: root.currentTabIndex === 0 ? "audio-speakers" : "applications-multimedia"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                color: root.activeTheme.text
                            }
                            Text {
                                text: (root.currentTabIndex === 0
                                       ? root.t("devices")
                                       : (root.t("apps") + (root.filteredAppStreams.count > 0 ? " (" + root.filteredAppStreams.count + ")" : ""))) + "  ⇆"
                                color: root.activeTheme.text
                                font.bold: true
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTabIndex = (root.currentTabIndex === 0 ? 1 : 0)
                        }
                    }

                    // Theme selector button
                    PlasmaComponents.ToolButton {
                        id: themeBtn
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.9
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 1.9
                        PlasmaComponents.ToolTip.text: root.t("theme", root.activeTheme.displayName)
                        PlasmaComponents.ToolTip.visible: hovered

                        onClicked: themeMenu.open()

                        contentItem: Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "preferences-desktop-theme"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            color: root.activeTheme.text
                        }

                        background: Rectangle {
                            radius: 6
                            color: themeBtn.down
                                   ? Qt.darker(root.activeTheme.cardBg, 1.1)
                                   : (themeBtn.hovered ? Qt.lighter(root.activeTheme.cardBg, 1.05) : root.activeTheme.cardBg)
                            border.color: root.activeTheme.border
                            border.width: 1
                        }

                        PlasmaComponents.Menu {
                            id: themeMenu

                            PlasmaComponents.MenuItem {
                                text: "Breeze (Plasma)"
                                icon.name: "plasma"
                                checkable: true
                                checked: root.currentThemeIndex === 0
                                onClicked: root.currentThemeIndex = 0
                            }
                            PlasmaComponents.MenuItem {
                                text: "Warm Vintage Cream"
                                icon.name: "color-management"
                                checkable: true
                                checked: root.currentThemeIndex === 1
                                onClicked: root.currentThemeIndex = 1
                            }
                            PlasmaComponents.MenuItem {
                                text: "Cyber Dark Glass"
                                icon.name: "view-media-equalizer"
                                checkable: true
                                checked: root.currentThemeIndex === 2
                                onClicked: root.currentThemeIndex = 2
                            }
                            PlasmaComponents.MenuItem {
                                text: "Nordic Frost"
                                icon.name: "weather-snow"
                                checkable: true
                                checked: root.currentThemeIndex === 3
                                onClicked: root.currentThemeIndex = 3
                            }
                        }
                    }
                }

                // ==========================================
                // TAB CONTENT 1: AYGITLAR (DEVICES)
                // ==========================================
                ColumnLayout {
                    id: devicesColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.smallSpacing
                    visible: root.currentTabIndex === 0

                    // ------------------------------------------
                    // KART 1: Ses Çıkışı (Master Output Device)
                    // ------------------------------------------
                    Rectangle {
                        id: outputCard
                        Layout.fillWidth: true
                        radius: 8
                        color: root.activeTheme.cardBg
                        border.color: root.activeTheme.border
                        border.width: 1
                        implicitHeight: outputColumn.implicitHeight + Math.round(Kirigami.Units.smallSpacing * 1.5)

                        ColumnLayout {
                            id: outputColumn
                            anchors.fill: parent
                            anchors.topMargin: Math.round(Kirigami.Units.smallSpacing * 0.75)
                            anchors.bottomMargin: Math.round(Kirigami.Units.smallSpacing * 0.75)
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.rightMargin: Kirigami.Units.smallSpacing
                            spacing: Math.round(Kirigami.Units.smallSpacing * 0.75)

                            // Çıkış Aygıtı Seçimi
                            PlasmaComponents.ComboBox {
                                id: sinkComboBox
                                implicitWidth: 100
                                implicitHeight: Kirigami.Units.gridUnit * 1.6
                                Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                model: root.filteredSinks
                                textRole: "Description"
                                valueRole: "PulseObject"

                                function syncIndex() {
                                    if (root.defaultSink) {
                                        let idx = indexOfValue(root.defaultSink);
                                        if (idx !== -1 && idx !== currentIndex) {
                                            currentIndex = idx;
                                        }
                                    }
                                }

                                Component.onCompleted: syncIndex()

                                onActivated: index => {
                                    let pObj = valueAt(index);
                                    if (pObj) {
                                        pObj.default = true;
                                        pObj.switchStreams();
                                        PulseAudio.PreferredDevice.sink = pObj;
                                    }
                                }

                                Connections {
                                    target: PulseAudio.PreferredDevice
                                    function onSinkChanged() { sinkComboBox.syncIndex(); }
                                }
                                Connections {
                                    target: root.filteredSinks
                                    function onCountChanged() { sinkComboBox.syncIndex(); }
                                }
                            }

                            // Rotary Dial + Mute Düğmesi Düzeni (Entegre Canlı VU Metre)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.mediumSpacing

                                // Sol: Retro Rotary Knob ile Entegre Canlı VU Metre
                                RotaryKnob {
                                    id: masterKnob
                                    implicitWidth: Kirigami.Units.gridUnit * 4.8
                                    implicitHeight: Kirigami.Units.gridUnit * 4.8
                                    value: root.defaultSink ? root.defaultSink.volume : 0
                                    peakVolume: (root.visible && root.currentTabIndex === 0 && Boolean(root.defaultSink) && !root.defaultSink.muted) ? root.sinkMonitor.volume : 0.0
                                    muted: root.defaultSink ? root.defaultSink.muted : false
                                    accentColor: root.activeTheme.accent
                                    bodyColor: root.activeTheme.knobBody
                                    textColor: root.activeTheme.knobText || "#ffffff"
                                    trackColor: root.activeTheme.knobTrack

                                    onMoved: val => {
                                        if (root.defaultSink) {
                                            root.defaultSink.volume = Math.round(val);
                                        }
                                    }
                                }

                                // Sağ: Mute Düğmesi ve Durum
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                     PlasmaComponents.ToolButton {
                                        id: outputMuteBtn
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.8
                                        checkable: true
                                        checked: root.defaultSink ? root.defaultSink.muted : false
                                        PlasmaComponents.ToolTip.text: root.defaultSink && root.defaultSink.muted ? root.t("unmute") : root.t("mute")
                                        PlasmaComponents.ToolTip.visible: hovered

                                        onClicked: {
                                            if (root.defaultSink) {
                                                root.defaultSink.muted = !root.defaultSink.muted;
                                            }
                                        }

                                        contentItem: RowLayout {
                                            spacing: Kirigami.Units.smallSpacing

                                            Kirigami.Icon {
                                                source: root.defaultSink && root.defaultSink.muted ? "audio-volume-muted" : "audio-volume-high"
                                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                                color: (root.defaultSink && root.defaultSink.muted) ? root.activeTheme.meterPeak : root.activeTheme.text
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: root.defaultSink && root.defaultSink.muted ? root.t("unmute") : root.t("mute")
                                                color: root.activeTheme.text
                                                font.bold: true
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        background: Rectangle {
                                            radius: 6
                                            color: outputMuteBtn.down
                                                   ? Qt.darker(root.activeTheme.cardBg, 1.1)
                                                   : (outputMuteBtn.hovered ? Qt.lighter(root.activeTheme.cardBg, 1.05) : "transparent")
                                            border.color: (root.defaultSink && root.defaultSink.muted)
                                                          ? root.activeTheme.meterPeak
                                                          : root.activeTheme.border
                                            border.width: 1
                                        }
                                    }

                                    Text {
                                        text: root.defaultSink ? (root.defaultSink.muted ? root.t("muted") : root.t("live_vu_output")) : root.t("no_device")
                                        font.pixelSize: 11
                                        color: root.activeTheme.subText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }

                    // ------------------------------------------
                    // KART 2: Mikrofon (Microphone)
                    // ------------------------------------------
                    Rectangle {
                        id: micCard
                        Layout.fillWidth: true
                        radius: 8
                        color: root.activeTheme.cardBg
                        border.color: root.activeTheme.border
                        border.width: 1
                        implicitHeight: micColumn.implicitHeight + Math.round(Kirigami.Units.smallSpacing * 1.5)

                        ColumnLayout {
                            id: micColumn
                            anchors.fill: parent
                            anchors.topMargin: Math.round(Kirigami.Units.smallSpacing * 0.75)
                            anchors.bottomMargin: Math.round(Kirigami.Units.smallSpacing * 0.75)
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.rightMargin: Kirigami.Units.smallSpacing
                            spacing: Math.round(Kirigami.Units.smallSpacing * 0.75)

                            // Giriş Aygıtı (Mikrofon) Seçimi
                            PlasmaComponents.ComboBox {
                                id: micComboBox
                                implicitWidth: 100
                                implicitHeight: Kirigami.Units.gridUnit * 1.6
                                Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                model: root.filteredSources
                                textRole: "Description"
                                valueRole: "PulseObject"

                                function syncIndex() {
                                    if (root.defaultMic) {
                                        let idx = indexOfValue(root.defaultMic);
                                        if (idx !== -1 && idx !== currentIndex) {
                                            currentIndex = idx;
                                        }
                                    }
                                }

                                Component.onCompleted: syncIndex()

                                onActivated: index => {
                                    let pObj = valueAt(index);
                                    if (pObj) {
                                        pObj.default = true;
                                        pObj.switchStreams();
                                        PulseAudio.PreferredDevice.source = pObj;
                                    }
                                }

                                Connections {
                                    target: PulseAudio.PreferredDevice
                                    function onSourceChanged() { micComboBox.syncIndex(); }
                                }
                                Connections {
                                    target: root.filteredSources
                                    function onCountChanged() { micComboBox.syncIndex(); }
                                }
                            }

                            // Rotary Dial + Mute Düğmesi Düzeni (Entegre Canlı VU Metre)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.mediumSpacing

                                // Sol: Mikrofon Rotary Knob ile Entegre Canlı VU Metre
                                RotaryKnob {
                                    id: micKnob
                                    implicitWidth: Kirigami.Units.gridUnit * 4.8
                                    implicitHeight: Kirigami.Units.gridUnit * 4.8
                                    value: root.defaultMic ? root.defaultMic.volume : 0
                                    peakVolume: (root.visible && root.currentTabIndex === 0 && Boolean(root.defaultMic) && !root.defaultMic.muted) ? root.micMonitor.volume : 0.0
                                    muted: root.defaultMic ? root.defaultMic.muted : false
                                    accentColor: root.activeTheme.accent
                                    bodyColor: root.activeTheme.knobBody
                                    textColor: root.activeTheme.knobText || "#ffffff"
                                    trackColor: root.activeTheme.knobTrack

                                    onMoved: val => {
                                        if (root.defaultMic) {
                                            root.defaultMic.volume = Math.round(val);
                                        }
                                    }
                                }

                                // Sağ: Mute Düğmesi ve Durum
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                     PlasmaComponents.ToolButton {
                                        id: micMuteBtn
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.8
                                        checkable: true
                                        checked: root.defaultMic ? root.defaultMic.muted : false
                                        PlasmaComponents.ToolTip.text: root.defaultMic && root.defaultMic.muted ? root.t("unmute_mic") : root.t("mute_mic")
                                        PlasmaComponents.ToolTip.visible: hovered

                                        onClicked: {
                                            if (root.defaultMic) {
                                                root.defaultMic.muted = !root.defaultMic.muted;
                                            }
                                        }

                                        contentItem: RowLayout {
                                            spacing: Kirigami.Units.smallSpacing

                                            Kirigami.Icon {
                                                source: root.defaultMic && root.defaultMic.muted ? "microphone-sensitivity-muted" : "microphone-sensitivity-high"
                                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                                color: (root.defaultMic && root.defaultMic.muted) ? root.activeTheme.meterPeak : root.activeTheme.text
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: root.defaultMic && root.defaultMic.muted ? root.t("unmute_mic") : root.t("mute_mic")
                                                color: root.activeTheme.text
                                                font.bold: true
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        background: Rectangle {
                                            radius: 6
                                            color: micMuteBtn.down
                                                   ? Qt.darker(root.activeTheme.cardBg, 1.1)
                                                   : (micMuteBtn.hovered ? Qt.lighter(root.activeTheme.cardBg, 1.05) : "transparent")
                                            border.color: (root.defaultMic && root.defaultMic.muted)
                                                          ? root.activeTheme.meterPeak
                                                          : root.activeTheme.border
                                            border.width: 1
                                        }
                                    }

                                    Text {
                                        text: root.defaultMic ? (root.defaultMic.muted ? root.t("mic_muted") : root.t("live_vu_input")) : root.t("no_mic")
                                        font.pixelSize: 11
                                        color: root.activeTheme.subText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // TAB CONTENT 2: UYGULAMALAR (APPS)
                // ==========================================
                Item {
                    id: appsContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: devicesColumn.implicitHeight
                    visible: root.currentTabIndex === 1

                    // Boş Durum (Empty State)
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.filteredAppStreams.count === 0
                        spacing: Kirigami.Units.mediumSpacing

                        Kirigami.Icon {
                            source: "multimedia-player"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Kirigami.Units.iconSizes.enormous
                            Layout.preferredHeight: Kirigami.Units.iconSizes.enormous
                            opacity: 0.4
                        }

                        Text {
                            text: root.t("no_apps")
                            font.bold: true
                            font.pixelSize: 14
                            color: root.activeTheme.text
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: root.t("no_apps_desc")
                            color: root.activeTheme.subText
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Aktif Ses Akışları Listesi (App Streams ListView)
                    ListView {
                        anchors.fill: parent
                        visible: root.filteredAppStreams.count > 0
                        clip: true
                        spacing: Kirigami.Units.smallSpacing
                        model: root.filteredAppStreams

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: appItemColumn.implicitHeight + (Kirigami.Units.smallSpacing * 2)
                            radius: 8
                            color: root.activeTheme.cardBg
                            border.color: root.activeTheme.border
                            border.width: 1

                            readonly property var pObject: model.PulseObject

                            ColumnLayout {
                                id: appItemColumn
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.smallSpacing
                                spacing: Kirigami.Units.smallSpacing

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                    Kirigami.Icon {
                                        source: model.IconName || (model.Client ? model.Client.iconName : "") || (pObject ? pObject.iconName : "") || "audio-volume-high"
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: (model.Client && model.Client.name) ? model.Client.name : (model.Name || (pObject ? pObject.name : root.t("application")))
                                        font.bold: true
                                        color: root.activeTheme.text
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: root.formatVolume(pObject ? pObject.volume : 0)
                                        font.bold: true
                                        color: root.activeTheme.text
                                        opacity: 0.8
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                    PlasmaComponents.ToolButton {
                                        icon.name: pObject && pObject.muted ? "audio-volume-muted" : "audio-volume-high"
                                        checkable: true
                                        checked: pObject ? pObject.muted : false
                                        PlasmaComponents.ToolTip.text: pObject && pObject.muted ? root.t("unmute") : root.t("mute")
                                        PlasmaComponents.ToolTip.visible: hovered

                                        onClicked: {
                                            if (pObject) {
                                                pObject.muted = !pObject.muted;
                                            }
                                        }
                                    }

                                    PlasmaComponents.Slider {
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 65536
                                        stepSize: 655.36
                                        enabled: pObject ? pObject.volumeWritable : false
                                        value: pObject ? pObject.volume : 0

                                        onMoved: {
                                            if (pObject) {
                                                pObject.volume = Math.round(value);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
