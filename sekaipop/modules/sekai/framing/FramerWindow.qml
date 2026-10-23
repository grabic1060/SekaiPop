import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

// Puts the framer (FramerCard.qml) on screen while PanelImages.framing names a picture, on
// the monitor it was opened for (PanelImages.framingScreen). One of these per monitor
// (shell.qml); the others stay unmapped.
//
//   In Edit Desktop   it covers the stage only, dimmed, and leaves the tray (its hints say
//                     what framing does) where it is.
//   Anywhere else     it covers the monitor, over the scrim behind dialogs (the Quick
//                     Panel closes first, as it does for the picture chooser).
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    readonly property var mt: Theme.of(screen)
    readonly property real uiScale: ShellScale.forScreen(win.screen)
    readonly property bool open: PanelImages.framing !== "" && win.screen !== null
        && (PanelImages.framingScreen === "" || win.screen.name === PanelImages.framingScreen)
    readonly property bool editing: win.screen !== null && EditMode.editing(win.screen.name)

    visible: win.open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sekaipop-framer"
    // Esc, Enter, the arrows and + / - are the framer's while it is up.
    WlrLayershell.keyboardFocus: win.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: !win.editing
    }
    implicitHeight: win.editing && win.screen
        ? Math.max(1, Math.round(win.screen.height - EditMode.trayHeight * win.uiScale)) : 0

    Rectangle {
        anchors.fill: parent
        color: win.editing ? win.mt.colDeep : win.mt.scrim
        opacity: win.editing ? 0.72 : 0.82
    }

    // A click beside the card does nothing (the framer is closed with its keys or Esc).
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
    }

    Item {
        id: holder
        // The card at the monitor's shell scale, smaller when the room is short.
        readonly property real s: Math.min(win.uiScale, (win.width - 40) / 1010, (win.height - 40) / 720)
        width: 1010 * s
        height: 720 * s
        anchors.centerIn: parent

        FramerCard {
            id: framer
            width: 1010
            height: 720
            transformOrigin: Item.TopLeft
            scale: holder.s
            kind: PanelImages.framing !== "" ? PanelImages.framing : "banner"
            fresh: PanelImages.framingFresh
            onFinished: saved => PanelImages.closeFramer(saved)
        }
    }

    onOpenChanged: {
        if (win.open)
            Qt.callLater(() => framer.forceActiveFocus())
    }
}
