import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// A small hover tag for a bar module: dark rounded label that opens towards
// the inside of the screen, whichever edge the bar is on.
//
//   BarTip { shown: area.containsMouse; text: "12 updates"; barPosition: "top" }
//
// Declare it as a child of the module (the module's own box is what it hangs
// off), exactly as before.
//
// The tag is its OWN small window (a PopupWindow), not a picture inside the bar's
// window. Why: the bar's window is only the strip plus ~24 px of room (Bar.qml
// `compactWindow`, kept small so Hyprland does not re-composite the whole
// screen for every frame the bar draws), so anything drawn inside it that is
// wider or taller than that room was cut off at the window's edge. A popup is
// a separate surface: it can be any size and sit anywhere on screen, and the
// bar's window does not change at all. It is click-through (empty mask), so it
// never steals the hover from the pill under it.
Item {
    id: root

    // This monitor's theme: Theme.of() gives the shell's own unless the monitor has one.
    readonly property var mt: Theme.of(QsWindow.window)

    property bool shown: false
    // Bind to the module's MouseArea.pressed: the tag is for hovering only, so any press
    // (click, right-click, middle-click) puts it away, and it stays away until the pointer
    // has left the module and come back.
    property bool pressed: false
    property string text: ""
    property string barPosition: "top"

    readonly property Item host: parent

    // The bar's PanelWindow this module lives in (null until it is on screen).
    readonly property var barWindow: QsWindow.window
    readonly property real uiScale: root.barWindow && root.barWindow.uiScale ? root.barWindow.uiScale : 1

    // Gap between the module and the tag, in design pixels. (Bigger = the tag sits
    // further from the pill. It is empty room inside the tag's own window, so it
    // never needs the bar's window to be any bigger.)
    readonly property real gap: 10
    readonly property real gapPx: Math.round(root.gap * root.uiScale)
    readonly property bool facingVertical: root.barPosition === "left" || root.barPosition === "right"


    // `shown` comes from a MouseArea's containsMouse, and that can stay true after the
    // pointer has really left (a press that opens a popup / focus grab moves the pointer
    // to another surface, and the bar never gets the hover-leave). The tag is its own
    // window, so it then stays up until the shell is restarted. So while the tag is up
    // the real cursor position is asked of Hyprland and checked against the module's box;
    // the moment the pointer is outside it, the tag goes. Coming back brings it back.
    // (If hyprctl is unavailable the answer is never read and `shown` rules, as before.)
    property bool pointerOver: true
    property bool dismissed: false

    onShownChanged: {
        if (shown)
            root.pointerOver = true   // a fresh hover: the pointer is on the module
        else
            root.dismissed = false    // a real leave: the next hover may show it again
    }

    onPressedChanged: {
        if (pressed)
            root.dismissed = true
    }

    // Once the cursor has been seen outside the module, a press-dismissal is over too:
    // coming back is a new hover (this is what lets a stale `shown` recover).
    onPointerOverChanged: {
        if (!pointerOver)
            root.dismissed = false
    }

    function checkPointer(raw) {
        if (!root.shown || !root.host)
            return
        let p
        try {
            p = JSON.parse(raw)
        } catch (e) {
            return
        }
        const win = root.barWindow
        const scr = win ? win.screen : null
        if (!scr || p.x === undefined || p.y === undefined)
            return
        // Hyprland gives the cursor in layout coordinates. The bar's window sticks to its
        // own edge, so its corner is the screen's corner only for a top or left bar: a
        // bottom bar's window starts (screen height - window height) down, a right bar's
        // (screen width - window width) across. Taking the screen corner for those hid the
        // tag the moment it appeared.
        let ox = scr.x
        let oy = scr.y
        if (root.barPosition === "bottom")
            oy += scr.height - win.height
        else if (root.barPosition === "right")
            ox += scr.width - win.width
        const a = root.host.mapToItem(null, 0, 0)
        const b = root.host.mapToItem(null, root.host.width, root.host.height)
        const m = 2
        const inside = p.x >= ox + a.x - m && p.x <= ox + b.x + m
                    && p.y >= oy + a.y - m && p.y <= oy + b.y + m
        // The module's own hover area only gets moves while the pointer really is on it,
        // so a move a moment ago beats this guess (which can be off by a pixel or two, or
        // read just before the pointer arrived): the tag is never taken away from a
        // pointer that is visibly moving over the module.
        root.pointerOver = inside || (Date.now() - root.lastMove < 350)
    }

    // When the pointer last moved over the module (a hover-only area laid over it; it takes
    // no clicks, so the module's own area underneath still gets every press).
    property double lastMove: 0

    MouseArea {
        width: root.host ? root.host.width : 0
        height: root.host ? root.host.height : 0
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: root.lastMove = Date.now()
    }

    Timer {
        interval: 70
        repeat: true
        running: root.shown && root.text !== ""
        onTriggered: {
            if (!cursorProbe.running)
                cursorProbe.running = true
        }
    }

    Process {
        id: cursorProbe
        command: ["hyprctl", "-j", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: root.checkPointer(text)
        }
    }

    // Fades in and out like before; the window is only mapped while it is visible.
    property real fade: shown && pointerOver && !dismissed && text !== "" ? 1 : 0
    Behavior on fade {
        NumberAnimation { duration: 120 }
    }

    // The module's box in the bar window's real pixels (mapToItem folds in the
    // ScaleHost scale). The tag is centred on the middle of the side that faces the
    // inside of the screen. `void root.shown` re-reads it each time the tag is about
    // to show, because the module can have moved since the last time.
    readonly property rect hostRect: {
        void root.shown
        void root.text
        if (!root.host)
            return Qt.rect(0, 0, 0, 0)
        const a = root.host.mapToItem(null, 0, 0)
        const b = root.host.mapToItem(null, root.host.width, root.host.height)
        return Qt.rect(Math.round(a.x), Math.round(a.y), Math.round(b.x - a.x), Math.round(b.y - a.y))
    }

    PopupWindow {
        id: popup
        visible: root.fade > 0.01 && root.barWindow !== null && root.text !== ""

        anchor.window: root.barWindow
        anchor.rect: root.hostRect
        // Centred on the module's side that faces the inside of the screen.
        anchor.edges: root.barPosition === "bottom" ? Edges.Top
                    : (root.barPosition === "left" ? Edges.Right
                    : (root.barPosition === "right" ? Edges.Left : Edges.Bottom))
        anchor.gravity: anchor.edges
        // Near a screen corner it slides along the edge instead of running off.
        anchor.adjustment: PopupAdjustment.Slide

        // The window is the label plus the gap, on the side that faces the pill.
        implicitWidth: Math.ceil((label.implicitWidth + 16) * root.uiScale) + (root.facingVertical ? root.gapPx : 0)
        implicitHeight: Math.ceil((label.implicitHeight + 10) * root.uiScale) + (root.facingVertical ? 0 : root.gapPx)
        color: "transparent"

        // Click-through: an empty region takes no input.
        mask: Region {}

        ScaleHost {
            anchors.fill: parent
            factor: root.uiScale
            opacity: root.fade

            Rectangle {
                // Pushed away from the pill by the gap (top bar: down; bottom bar: stays
                // at the top of the window; left bar: right; right bar: stays left).
                x: root.barPosition === "left" ? root.gap : 0
                y: root.barPosition === "top" ? root.gap : 0
                width: label.implicitWidth + 16
                height: label.implicitHeight + 10
                radius: 8
                color: mt.colBorder

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: root.text
                    color: mt.textWhite
                    font.family: mt.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
