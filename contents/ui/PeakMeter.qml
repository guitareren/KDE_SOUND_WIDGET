import QtQuick
import QtQuick.Layouts

Item {
    id: meterRoot
    implicitWidth: 140
    implicitHeight: 10

    property real level: 0.0
    property bool active: true
    property int segmentsCount: 16

    property color normalColor: "#2ecc71"
    property color warningColor: "#f39c12"
    property color peakColor: "#e74c3c"
    property color inactiveColor: Qt.rgba(0.5, 0.5, 0.5, 0.15)

    // Smooth responsive animation for peak level
    property real animatedLevel: active ? level : 0.0
    Behavior on animatedLevel {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutQuad
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: meterRoot.segmentsCount
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 1.5

                readonly property real segPos: (index + 1) / meterRoot.segmentsCount
                readonly property bool isLit: segPos <= meterRoot.animatedLevel

                color: {
                    if (!isLit) return meterRoot.inactiveColor;
                    if (segPos > 0.82) return meterRoot.peakColor;
                    if (segPos > 0.62) return meterRoot.warningColor;
                    return meterRoot.normalColor;
                }

                // Subtle glow on highest lit segments
                opacity: isLit ? 1.0 : 0.35
            }
        }
    }
}
