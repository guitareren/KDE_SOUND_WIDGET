import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: control
    implicitWidth: 100
    implicitHeight: 100

    property real value: 0
    property real from: 0
    property real to: 65536
    property real stepSize: 655.36
    property bool muted: false

    property real peakVolume: 0.0
    property color peakColor: Qt.darker(control.accentColor, 1.5)

    property color accentColor: "#d49a3d"
    property color bodyColor: "#2b2b2b"
    property color textColor: "#ffffff"
    property color trackColor: Qt.rgba(1, 1, 1, 0.15)

    signal moved(real val)

    readonly property real fraction: Math.min(1.0, Math.max(0.0, (to > from) ? (value - from) / (to - from) : 0))
    readonly property real targetAngle: -135 + (fraction * 270)
    property real displayAngle: targetAngle
    readonly property real arcRadius: Math.max(0, Math.min(width, height) / 2 - 7)

    property bool isDragging: false
    property real dragStartY: 0
    property real dragStartValue: 0

    Behavior on peakVolume {
        NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
    }

    onTargetAngleChanged: {
        if (!isDragging) {
            displayAngle = targetAngle;
        }
    }

    Behavior on displayAngle {
        enabled: !control.isDragging
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
    }

    // Dial background and volume arcs (rendered via QtQuick.Shapes on GPU)
    Shape {
        id: dialShape
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        // Background track
        ShapePath {
            strokeColor: control.trackColor
            strokeWidth: 3.5
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            PathAngleArc {
                centerX: control.width / 2
                centerY: control.height / 2
                radiusX: control.arcRadius
                radiusY: control.arcRadius
                startAngle: 135
                sweepAngle: 270
            }
        }

        // Active volume arc
        ShapePath {
            strokeColor: control.muted ? "#7f8c8d" : control.accentColor
            strokeWidth: 3.5
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            PathAngleArc {
                centerX: control.width / 2
                centerY: control.height / 2
                radiusX: control.arcRadius
                radiusY: control.arcRadius
                startAngle: 135
                sweepAngle: control.fraction * 270
            }
        }

        // Live peak intensity pulse arc
        ShapePath {
            strokeColor: control.peakColor
            strokeWidth: 5.0
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            PathAngleArc {
                centerX: control.width / 2
                centerY: control.height / 2
                radiusX: control.arcRadius
                radiusY: control.arcRadius
                startAngle: 135
                sweepAngle: (control.fraction * Math.min(1.0, Math.max(0.0, control.peakVolume))) * 270
            }
        }
    }

    // 11 Tick marks (declarative GPU quads uploaded once to Scene Graph)
    Repeater {
        model: 11

        Item {
            anchors.centerIn: parent
            width: 1.5
            height: (control.arcRadius + 6.5) * 2
            rotation: -135 + (index * 27)

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 1.5
                height: 3.0
                color: ((-135 + (index * 27)) <= control.targetAngle && !control.muted) ? control.accentColor : control.trackColor
            }
        }
    }

    // Rotating Knob Disc
    Rectangle {
        id: knobCircle
        anchors.centerIn: parent
        width: Math.max(16, Math.min(parent.width, parent.height) - 30)
        height: width
        radius: width / 2
        color: control.bodyColor
        border.color: Qt.lighter(control.bodyColor, 1.25)
        border.width: 1.5
        rotation: control.displayAngle
        opacity: control.muted ? 0.6 : 1.0

        // Tactile Indicator notch
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 3.5
            anchors.horizontalCenter: parent.horizontalCenter
            width: 3.5
            height: 8
            radius: 1.75
            color: control.muted ? "#7f8c8d" : control.accentColor
        }
    }

    // Inner Center Label showing %
    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(control.fraction * 100) + "%"
            color: control.muted ? "#7f8c8d" : control.textColor
            font.bold: true
            font.pixelSize: Math.max(9, Math.min(control.width, control.height) * 0.17)
        }
    }

    // Interactive Drag and Wheel Handlers
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            control.isDragging = true;
            control.dragStartY = mouse.y;
            control.dragStartValue = control.value;
        }

        onPositionChanged: mouse => {
            if (control.isDragging) {
                var deltaY = control.dragStartY - mouse.y;
                var range = control.to - control.from;
                var change = (deltaY / 120.0) * range;
                var newVal = Math.min(control.to, Math.max(control.from, control.dragStartValue + change));
                control.displayAngle = -135 + (((newVal - control.from) / range) * 270);
                control.moved(newVal);
            }
        }

        onReleased: {
            control.isDragging = false;
            control.displayAngle = control.targetAngle;
        }

        onWheel: wheel => {
            var range = control.to - control.from;
            var step = (range * 0.03); // 3% per notch
            var delta = wheel.angleDelta.y > 0 ? step : -step;
            var newVal = Math.min(control.to, Math.max(control.from, control.value + delta));
            control.moved(newVal);
        }
    }
}
