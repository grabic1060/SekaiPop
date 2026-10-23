import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

// The shell's own three pictures, at the front of Edit Desktop's THEME board: the banner,
// the avatar and the phone wallpaper. Each shows what it is now (its picture, framed, or
// "none yet", or "can't find its file") and has keys to change it, frame it (FramerCard)
// and remove it (two clicks: "Remove?"). The phone's also chooses what it shows: Off, the
// monitor's wallpaper, or a picture of its own. Design: docs/PICTURE-FRAMING.md.
Item {
    id: root

    readonly property var mt: Theme.of(QsWindow.window)
    // The monitor the board is on: pickers and the framer open there.
    property string screenName: ""

    implicitWidth: 690
    implicitHeight: 170

    // A remove waiting for its second click ("" = none), forgotten after 3 s.
    property string asking: ""
    Timer {
        id: askTimer
        interval: 3000
        onTriggered: root.asking = ""
    }
    function ask(kind) {
        root.asking = kind
        askTimer.restart()
    }
    // The chooser is a normal window: Edit Desktop (which parks the windows and draws over
    // them) steps aside first, so it opens where you can use it. The framer follows the pick.
    function pick(kind) {
        EditMode.close()
        PanelImages.pick(kind, root.screenName)
    }

    function remove(kind) {
        root.asking = ""
        PanelImages.clear(kind)
    }

    // ===== a small key: icon, or icon + word; "ask" is the Remove? one =====
    component SmallKey: Item {
        id: sk
        property string icon: ""
        property string text: ""
        property bool ask: false
        property string tip: ""
        signal clicked()

        implicitWidth: (sk.text === "" ? 28 : skRow.implicitWidth + 18) + 2
        implicitHeight: 28 + 2
        opacity: sk.enabled ? 1 : 0.35

        Rectangle {
            x: sk.ask ? 3 : 2
            y: sk.ask ? 3 : 2
            width: sk.width - 2
            height: 28
            radius: 14
            color: root.mt.pLineShadow
        }
        Rectangle {
            width: sk.width - 2
            height: 28
            x: skArea.pressed ? 2 : 0
            y: skArea.pressed ? 2 : 0
            radius: 14
            color: sk.ask ? root.mt.pSurfaceHover : root.mt.pSurface
            border.width: sk.ask ? 3 : 2.5
            border.color: sk.ask ? root.mt.colBorder : root.mt.pLine
            Rectangle {
                visible: !sk.ask
                anchors.fill: parent
                anchors.margins: 2.5
                radius: height / 2
                color: "transparent"
                border.width: 2
                border.color: root.mt.pRingWhite
            }
            Row {
                id: skRow
                anchors.centerIn: parent
                spacing: 5
                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: sk.icon
                    size: 15
                    color: sk.ask ? root.mt.colBorder : root.mt.pInk
                }
                Text {
                    visible: sk.text !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: sk.text
                    color: sk.ask ? root.mt.colBorder : root.mt.pInk
                    font.family: root.mt.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                    font.styleName: root.mt.fontStyleBold
                }
            }
        }
        MouseArea {
            id: skArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sk.clicked()
        }
    }

    // ===== a tile's housing; lit while its picture is in the framer =====
    component Tile: Item {
        id: tile
        property string kind: ""
        property string label: ""
        default property alias content: tileInner.data
        readonly property bool focused: PanelImages.framing === tile.kind
        opacity: PanelImages.framing !== "" && !tile.focused ? 0.45 : 1
        height: 138

        Rectangle {
            x: tile.focused ? 6 : 4
            y: tile.focused ? 4 : 3
            width: tile.width - (tile.focused ? 6 : 4)
            height: tile.height - (tile.focused ? 4 : 3)
            radius: 18
            color: root.mt.pLineShadow
        }
        Rectangle {
            width: tile.width - (tile.focused ? 6 : 4)
            height: tile.height - (tile.focused ? 4 : 3)
            radius: 18
            color: tile.focused ? "transparent" : root.mt.pSurface
            border.width: tile.focused ? 4 : 3
            border.color: tile.focused ? root.mt.colBorder : root.mt.pLine
            gradient: tile.focused ? tileLit : null
            Gradient {
                id: tileLit
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: root.mt.accentMint }
                GradientStop { position: 1; color: root.mt.accentCyan }
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: tile.focused ? 4 : 3
                radius: 15
                color: "transparent"
                border.width: tile.focused ? 4 : 3
                border.color: root.mt.pRingWhite
            }
            Item {
                id: tileInner
                anchors.fill: parent
                anchors.margins: 9
            }
        }
        Rectangle {
            visible: tile.focused
            x: 14
            y: -13
            width: framingTag.implicitWidth + 18
            height: 22
            radius: 11
            color: root.mt.colBorder
            Text {
                id: framingTag
                anchors.centerIn: parent
                text: "Framing"
                color: "#ffffff"
                font.family: root.mt.fontFamily
                font.pixelSize: 11
                font.weight: Font.ExtraBold
                font.styleName: root.mt.fontStyleBold
            }
        }
    }

    // ===== what a picture slot shows when there is no picture =====
    component Empty: Row {
        property string text: ""
        property string icon: "image"
        anchors.centerIn: parent
        spacing: 7
        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: parent.icon
            size: 16
            color: root.mt.pInkSub
        }
        Text {
            visible: parent.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: parent.text
            color: root.mt.pInkSub
            font.family: root.mt.fontFamily
            font.pixelSize: 13
            font.weight: Font.ExtraBold
            font.styleName: root.mt.fontStyleBold
        }
    }

    // ===== the footer of a tile: its name and keys =====
    component Footer: Item {
        id: foot
        property string kind: ""
        property string label: ""
        // "set" | "empty" | "missing"
        property string pic: "set"
        property bool canFrame: foot.pic === "set"
        property bool canRemove: foot.pic !== "empty"
        property bool focused: false
        width: parent ? parent.width : 0
        height: 30

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, keyRow.x - 6)
            elide: Text.ElideRight
            text: foot.label
            color: foot.focused ? root.mt.colBorder : root.mt.pInk
            font.family: root.mt.fontFamily
            font.pixelSize: 14
            font.weight: Font.ExtraBold
            font.styleName: root.mt.fontStyleBold
        }
        Row {
            id: keyRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            // Remove? (the second click removes)
            SmallKey {
                visible: root.asking === foot.kind
                icon: "delete"
                text: "Remove?"
                ask: true
                onClicked: root.remove(foot.kind)
            }
            SmallKey {
                visible: root.asking !== foot.kind
                icon: "image"
                text: foot.pic === "set" || foot.kind === "phone" ? "" : "Pick"
                onClicked: root.pick(foot.kind)
            }
            SmallKey {
                visible: root.asking !== foot.kind && (foot.pic === "set" || foot.kind === "phone")
                enabled: foot.canFrame
                icon: "crop"
                onClicked: PanelImages.frame(foot.kind, false, root.screenName)
            }
            SmallKey {
                visible: root.asking !== foot.kind && (foot.pic !== "empty" || foot.kind === "phone")
                enabled: foot.canRemove
                icon: "delete"
                onClicked: root.ask(foot.kind)
            }
        }
    }

    Row {
        x: 4
        y: 16
        spacing: 14

        // ===== Banner =====
        Tile {
            id: bannerTile
            kind: "banner"
            width: 216
            readonly property string pic: PanelImages.banner === "" ? "empty" : (bannerImg.status === Image.Error ? "missing" : "set")

            Column {
                spacing: 8
                Rectangle {
                    width: 192
                    height: 77
                    color: root.mt.pSurfaceDivider
                    topLeftRadius: 24
                    topRightRadius: 24
                    bottomLeftRadius: 16
                    bottomRightRadius: 16
                    border.width: bannerTile.pic === "missing" ? 2 : (bannerTile.focused ? 3 : 0)
                    border.color: bannerTile.focused ? root.mt.colBorder : root.mt.pLine
                    RoundClip {
                        anchors.fill: parent
                        radii: [24, 24, 16, 16]
                        visible: bannerTile.pic === "set"
                        FramedImage {
                            id: bannerImg
                            anchors.fill: parent
                            source: PanelImages.banner
                            framing: PanelImages.framingFor("banner")
                        }
                    }
                    Empty {
                        visible: bannerTile.pic !== "set"
                        icon: bannerTile.pic === "missing" ? "hide_image" : "image"
                        text: bannerTile.pic === "missing" ? "Can't find its file" : "No banner yet"
                    }
                }
                Footer {
                    kind: "banner"
                    label: "Banner"
                    pic: bannerTile.pic
                    focused: bannerTile.focused
                }
            }
        }

        // ===== Avatar =====
        Tile {
            id: avatarTile
            kind: "avatar"
            // A little wider than the canvas's 170, so "Avatar" fits beside its three keys.
            width: 180
            readonly property string pic: PanelImages.avatar === "" ? "empty" : (avatarImg.status === Image.Error ? "missing" : "set")

            Column {
                width: 162
                spacing: 8
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 77
                    height: 77
                    radius: 38.5
                    color: root.mt.pSurfaceDivider
                    border.width: avatarTile.pic === "missing" ? 2 : (avatarTile.focused ? 3 : 0)
                    border.color: avatarTile.focused ? root.mt.colBorder : root.mt.pLine
                    RoundClip {
                        anchors.fill: parent
                        radii: [38.5, 38.5, 38.5, 38.5]
                        visible: avatarTile.pic === "set"
                        FramedImage {
                            id: avatarImg
                            anchors.fill: parent
                            source: PanelImages.avatar
                            framing: PanelImages.framingFor("avatar")
                        }
                    }
                    Empty {
                        visible: avatarTile.pic !== "set"
                        icon: avatarTile.pic === "missing" ? "hide_image" : "account_circle"
                        text: ""
                    }
                }
                Footer {
                    kind: "avatar"
                    label: avatarTile.pic === "empty" ? "No avatar" : "Avatar"
                    pic: avatarTile.pic
                    focused: avatarTile.focused
                }
            }
        }

        // ===== Phone wallpaper =====
        Tile {
            id: phoneTile
            kind: "phone"
            width: 250
            readonly property string mode: PanelImages.phoneMode
            readonly property bool picked: PanelImages.phone !== ""
            readonly property string desktopPath: WallpaperService.imageFor(WallpaperService.pathFor(root.screenName))

            Column {
                width: 232
                spacing: 8
                Row {
                    spacing: 10
                    height: 77
                    // A small phone: what its screens show.
                    Rectangle {
                        width: 44
                        height: 77
                        radius: 10
                        color: root.mt.pSurfaceDivider
                        border.width: 3
                        border.color: root.mt.darker ? root.mt.pLine : root.mt.colBorder
                        RoundClip {
                            anchors.fill: parent
                            anchors.margins: 3
                            radii: [7, 7, 7, 7]
                            visible: phoneTile.mode !== "off" && phoneImg.source.toString() !== ""
                            FramedImage {
                                id: phoneImg
                                anchors.fill: parent
                                source: phoneTile.mode === "picture" ? PanelImages.phone
                                    : (phoneTile.mode === "desktop" && phoneTile.desktopPath !== "" ? "file://" + phoneTile.desktopPath : "")
                                framing: phoneTile.mode === "picture" ? PanelImages.framingFor("phone") : null
                            }
                        }
                        Empty {
                            visible: phoneTile.mode === "picture" && !phoneTile.picked
                            icon: "image"
                            text: ""
                        }
                        Rectangle {
                            x: 4; y: 22; width: parent.width - 8; height: 18; radius: 4
                            color: Qt.alpha(root.mt.pSurface, 0.78)
                        }
                        Rectangle {
                            x: 4; y: 44; width: parent.width - 8; height: 24; radius: 4
                            color: Qt.alpha(root.mt.pSurface, 0.78)
                        }
                    }
                    // What the phone shows: Off / Desktop / A picture.
                    Column {
                        width: 232 - 44 - 10
                        spacing: 4
                        Repeater {
                            model: [["off", "Off"], ["desktop", "Desktop"], ["picture", "A picture"]]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool on: phoneTile.mode === modelData[0]
                                width: parent.width
                                height: 23
                                radius: 12
                                color: on ? "transparent" : root.mt.pSurface
                                border.width: on ? 3 : 2
                                border.color: on ? root.mt.colBorder : root.mt.pLine
                                gradient: on ? modeLit : null
                                Gradient {
                                    id: modeLit
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0; color: root.mt.accentMint }
                                    GradientStop { position: 1; color: root.mt.accentCyan }
                                }
                                Text {
                                    x: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData[1]
                                    color: parent.on ? root.mt.colBorder : root.mt.pInk
                                    font.family: root.mt.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.ExtraBold
                                    font.styleName: root.mt.fontStyleBold
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // "A picture" with none picked opens the chooser first;
                                        // cancelling it leaves the mode as it was.
                                        if (modelData[0] === "picture" && !phoneTile.picked)
                                            root.pick("phone")
                                        else
                                            SettingsService.set("phone.wallpaper", modelData[0])
                                    }
                                }
                            }
                        }
                    }
                }
                Footer {
                    kind: "phone"
                    label: "Phone wallpaper"
                    pic: phoneTile.picked ? "set" : "empty"
                    canFrame: phoneTile.mode === "picture" && phoneTile.picked
                    canRemove: phoneTile.picked
                    focused: phoneTile.focused
                }
            }
        }
    }
}
