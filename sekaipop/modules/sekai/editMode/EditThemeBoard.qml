import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

// The THEME tab of Edit Desktop's shelf (EditTray.qml): the colour groups,
// each drawn as a little picture of the shell wearing that group's colours
// (a bar, a widget card, two Quick Panel keys), so you pick by how it looks,
// not by a name. This replaces the old drop-down card under the media pill
// (ThemePopup.qml).
//
//   click a tile     the whole shell, the card above included, re-colours live
//                    (ThemeService.pickTheme); the pick is remembered. With one theme
//                    per monitor (Settings > Desktop) it is this monitor's theme; on the
//                    main monitor, the shell's (ThemeService, "one theme per monitor")
//   mouse wheel      scrolls the row sideways, if the tiles do not all fit
//
// The pictures are drawn from each group's own palette (`group.c`), not from
// the active theme, so every tile shows what you would get. They follow the
// current Light / Dark / Darker look for their surfaces, so the preview is
// honest about that too. The last tile is the Matugen (wallpaper) theme; its
// swatches are the live palette once matugen has made one.
//
// Tile size lives in `tileW` / `tileH`. The shelf is 168 tall, so keep
// tileH under about 140 (the selected badge pokes out above the tile).
//
// The Matugen tile has more (issue #28; docs/MATUGEN-CONTROLS.md):
//   not the theme on   a small "tune" mark beside its name: it has options
//   the theme on       a round tune key on its corner; clicking it, or the tile
//                      again, swaps the row for its controls (EditMatugenControls.qml)
//                      until Back or Esc (EditTray.qml) brings the tiles back
//   accent pinned      a pin badge on the other top corner (EditPinBadge.qml)
//   matugen missing    a dashed face saying so, faded, and no click
Item {
    id: root

    // This monitor's theme: Theme.of() gives the shell's own unless the monitor has one.
    readonly property var mt: Theme.of(QsWindow.window)
    // The monitor Edit Desktop is open on: with one theme per monitor, a tile picks for it
    // (ThemeService.pickTheme; the main monitor's is the shell's theme).
    readonly property string screenName: QsWindow.window && QsWindow.window.screen ? String(QsWindow.window.screen.name) : ""

    readonly property real tileW: 150
    readonly property real tileH: 138

    // The Matugen controls are up instead of the tiles.
    property bool tuning: false
    // The hex field in the controls gave the keyboard back (EditTray: Esc leaves again).
    signal finished()

    readonly property bool matugenOn: ThemeService.themeFor(root.screenName) === "matugen"

    // Leaving the tab, or the theme no longer being Matugen, puts the tiles back.
    onVisibleChanged: {
        if (!visible)
            root.tuning = false
        root.takeRequest()
    }
    onMatugenOnChanged: {
        if (!matugenOn)
            root.tuning = false
        root.takeRequest()
    }

    // `ipc call desktopedit matugen` (EditMode.openMatugen): the controls, once this tab
    // shows and Matugen is the theme on.
    function takeRequest() {
        if (EditMode.matugenAsked && root.visible && root.matugenOn) {
            EditMode.matugenAsked = false
            root.tuning = true
        }
    }

    Connections {
        target: EditMode
        function onMatugenAskedChanged() {
            root.takeRequest()
        }
    }

    Component.onCompleted: root.takeRequest()

    // One group: the picture, its name, and a badge on the one that is on.
    component ThemeTile: Item {
        id: tile

        // This monitor's theme: Theme.of() gives the shell's own unless the monitor has one.
        readonly property var mt: Theme.of(QsWindow.window)

        required property var group

        readonly property var c: group.c
        readonly property bool selected: ThemeService.themeFor(root.screenName) === group.id
        readonly property bool isMatugen: group.id === "matugen"
        readonly property bool missing: tile.isMatugen && !ThemeService.matugenInstalled
        readonly property bool dark: ThemeService.dark

        // What the picture's surfaces are in the current look: white in Light,
        // the group's own dark tone in Dark / Darker (as Theme.qml makes them).
        readonly property color surf: dark ? Qt.lighter(Qt.color(c.deep), 1.18) : "#ffffff"
        readonly property color bg: dark ? Qt.darker(Qt.color(c.deep), 1.3) : Qt.color(c.boardBg)
        readonly property color skeleton: dark ? Qt.lighter(surf, 1.75) : Qt.color(c.divider)

        width: root.tileW
        height: root.tileH
        // Dimmed while matugen is missing, and while a picture is being framed (the themes
        // step back).
        opacity: (tile.missing ? 0.62 : 1) * (PanelImages.framing !== "" ? 0.4 : 1)

        Gradient {
            id: onFill
            GradientStop { position: 0.0; color: mt.accentMint }
            GradientStop { position: 1.0; color: mt.accentCyan }
        }

        // The group's own accent stops, left to right.
        Gradient {
            id: accent
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: tile.c.A }
            GradientStop { position: 1.0; color: tile.c.B }
        }

        // The tile lifts a little under the pointer, like the shelf's slots.
        Pill {
            id: body
            width: tile.width
            height: tile.height
            y: tileArea.containsMouse && !tile.selected && !tileArea.pressed ? -3 : 0
            cornerRadius: 15
            ringWidth: 4
            shadowDx: 0
            shadowDy: 4
            pressed: tileArea.pressed
            fillColor: tileArea.containsMouse && !tile.selected ? mt.pSurfaceHover : mt.pSurface
            fillGradient: tile.selected ? onFill : null

            Behavior on y {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            // ===== the picture =====
            Item {
                id: pic
                visible: !tile.missing
                x: 6
                y: 6
                width: body.capWidth - body.ringWidth * 2 - 12
                height: 92

                // Its hard drop shadow, then the card (the desktop).
                Rectangle {
                    y: 3
                    width: parent.width
                    height: parent.height - 3
                    radius: 10
                    color: tile.c.border
                    antialiasing: true
                }

                Rectangle {
                    id: card
                    width: parent.width
                    height: parent.height - 3
                    radius: 10
                    color: tile.bg
                    border.width: 3
                    border.color: tile.c.border
                    antialiasing: true

                    // The bar: a gradient key on the left, two dots on the right.
                    Rectangle {
                        x: 8
                        y: 8
                        width: card.width - 16
                        height: 15
                        radius: 7.5
                        color: tile.surf
                        border.width: 2
                        border.color: tile.c.border
                        antialiasing: true

                        Rectangle {
                            x: 6
                            y: 3.5
                            width: 24
                            height: 8
                            radius: 4
                            gradient: accent
                            antialiasing: true
                        }

                        Rectangle {
                            x: parent.width - 24
                            y: 4
                            width: 7
                            height: 7
                            radius: 3.5
                            color: tile.c.border
                            antialiasing: true
                        }

                        Rectangle {
                            x: parent.width - 14
                            y: 4
                            width: 7
                            height: 7
                            radius: 3.5
                            color: tile.c.A
                            antialiasing: true
                        }
                    }

                    // A widget card: title strip, two lines of text, a key.
                    Rectangle {
                        x: 8
                        y: 30
                        width: 58
                        height: card.height - 38
                        radius: 7
                        color: tile.surf
                        border.width: 2
                        border.color: tile.c.border
                        antialiasing: true

                        Rectangle {
                            x: 6
                            y: 6
                            width: 30
                            height: 8
                            radius: 4
                            gradient: accent
                            antialiasing: true
                        }

                        Rectangle {
                            x: 6
                            y: 19
                            width: 44
                            height: 4
                            radius: 2
                            color: tile.skeleton
                        }

                        Rectangle {
                            x: 6
                            y: 27
                            width: 32
                            height: 4
                            radius: 2
                            color: tile.skeleton
                        }

                        Rectangle {
                            x: 6
                            y: parent.height - 16
                            width: 24
                            height: 8
                            radius: 4
                            color: tile.c.border
                            antialiasing: true
                        }
                    }

                    // Two Quick Panel keys: one on (the gradient), one off.
                    Rectangle {
                        x: 72
                        y: 30
                        width: card.width - 72 - 8
                        height: (card.height - 38 - 4) / 2
                        radius: 8
                        gradient: accent
                        border.width: 2
                        border.color: tile.c.border
                        antialiasing: true

                        Rectangle {
                            x: 6
                            y: (parent.height - 8) / 2
                            width: 8
                            height: 8
                            radius: 4
                            color: tile.c.border
                            antialiasing: true
                        }
                    }

                    Rectangle {
                        x: 72
                        y: 30 + (card.height - 38 - 4) / 2 + 4
                        width: card.width - 72 - 8
                        height: (card.height - 38 - 4) / 2
                        radius: 8
                        color: tile.surf
                        border.width: 2
                        border.color: tile.c.border
                        antialiasing: true

                        Rectangle {
                            x: 6
                            y: (parent.height - 8) / 2
                            width: 8
                            height: 8
                            radius: 4
                            color: tile.c.A
                            antialiasing: true
                        }
                    }
                }
            }

            // matugen isn't installed: a dashed face where the picture goes.
            Canvas {
                id: missingFace
                visible: tile.missing
                x: pic.x
                y: pic.y
                width: pic.width
                height: pic.height - 3
                // A Canvas only redraws when asked: again when the colours change.
                property color lineColour: mt.pLine
                onLineColourChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = missingFace.lineColour
                    ctx.lineWidth = 2.5
                    ctx.setLineDash([3, 2.5])
                    ctx.beginPath()
                    ctx.roundedRect(1.25, 1.25, width - 2.5, height - 2.5, 10, 10)
                    ctx.stroke()
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    MaterialIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "terminal"
                        size: 20
                        weight: 700
                        color: mt.pInkSub
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Needs matugen"
                        color: mt.pInk
                        font.family: mt.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Black
                        font.styleName: mt.fontStyleBold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "Install it to use\nthe wallpaper"
                        color: mt.pInkSub
                        font.family: mt.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.ExtraBold
                    }
                }
            }

            // ===== the name =====
            Row {
                x: 6 + (pic.width - width) / 2
                y: pic.y + pic.height + 6
                spacing: 5

                Text {
                    width: Math.min(implicitWidth, pic.width - (tuneMark.visible ? 17 : 0))
                    elide: Text.ElideRight
                    text: tile.isMatugen ? "Matugen" : tile.group.name
                    color: tile.selected ? mt.colBorder : mt.pInk
                    font.family: mt.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.ExtraBold
                    font.styleName: mt.fontStyleBold
                }

                // Matugen has options (shown while it isn't the theme on).
                MaterialIcon {
                    id: tuneMark
                    visible: tile.isMatugen && !tile.selected && !tile.missing
                    anchors.verticalCenter: parent.verticalCenter
                    name: "tune"
                    size: 12
                    weight: 700
                    opacity: 0.8
                    color: mt.pInk
                }
            }
        }

        // The one that is on: a small tick badge on the corner.
        Rectangle {
            visible: tile.selected
            x: tile.width - 17
            y: -8
            width: 24
            height: 24
            radius: 12
            color: mt.accentMint
            border.width: 2
            border.color: mt.pLine
            antialiasing: true

            MaterialIcon {
                anchors.centerIn: parent
                name: "check"
                size: 15
                weight: 700
                color: mt.colBorder
            }
        }

        // An accent is pinned (Matugen only).
        EditPinBadge {
            visible: tile.isMatugen && !tile.missing && pins.length > 0
            x: -9
            y: -9
        }

        MouseArea {
            id: tileArea
            anchors.fill: parent
            enabled: !tile.missing
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            // Matugen, clicked again while it is on: its controls.
            onClicked: {
                if (tile.isMatugen && tile.selected)
                    root.tuning = true
                else
                    ThemeService.pickTheme(root.screenName, tile.group.id)
            }
        }

        // Matugen is on: the round tune key on its corner opens the controls.
        Item {
            visible: tile.isMatugen && tile.selected && !tile.missing
            x: tile.width - 34 + 10
            y: tile.height - 34 + 10 - 3
            width: 34
            height: 37

            Pill {
                anchors.fill: parent
                cornerRadius: 17
                ringWidth: 3
                shadowDx: 0
                shadowDy: 3
                pressed: tuneArea.pressed
                fillColor: tuneArea.containsMouse ? mt.pSurfaceHover : mt.pSurface
            }

            MaterialIcon {
                x: (34 - width) / 2
                y: (34 - height) / 2
                name: "tune"
                size: 18
                weight: 700
                color: mt.pInk
            }

            MouseArea {
                id: tuneArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.tuning = true
            }
        }
    }

    // The Matugen controls, in the row's place while tuning.
    EditMatugenControls {
        anchors.fill: parent
        visible: root.tuning
        onBack: root.tuning = false
        onFinished: root.finished()
    }

    // The row. Centred; if the tiles do not all fit, it scrolls sideways.
    Flickable {
        id: flick
        anchors.fill: parent
        visible: !root.tuning

        // `edge` of room at each end of the row, so what pokes out of the end tiles (the
        // pin badge on the left, Matugen's tune key on the right) isn't cut when it scrolls.
        readonly property real edge: 12
        contentWidth: Math.max(flick.width, row.width + 2 * flick.edge)
        contentHeight: flick.height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        // Not clipped while everything fits, so the tick badge and the lift
        // can poke out above the tiles.
        clip: flick.contentWidth > flick.width + 1

        // A plain wheel scrolls the row (a Flickable only takes sideways ones).
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const d = mt.wheelPx(event, true)
                flick.contentX = Math.max(0, Math.min(flick.contentWidth - flick.width, flick.contentX - d))
            }
        }

        Row {
            id: row
            x: Math.max(flick.edge, (flick.width - row.width) / 2)
            y: (flick.height - row.height) / 2
            spacing: 16

            // The shell's own pictures first (banner, avatar, phone wallpaper): change,
            // frame, remove (docs/PICTURE-FRAMING.md).
            PicturesRow {
                anchors.verticalCenter: parent.verticalCenter
                screenName: root.screenName
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 3
                height: 120
                radius: 2
                color: mt.pSurfaceDivider
            }

            Repeater {
                model: ThemeService.groups

                delegate: ThemeTile {
                    required property var modelData

                    // Centred in the row, beside the (taller) picture tiles.
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    group: modelData
                }
            }
        }
    }
}
