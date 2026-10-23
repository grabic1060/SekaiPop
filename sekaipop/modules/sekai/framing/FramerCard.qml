import QtQuick
import QtQuick.Effects
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "../../common/functions/ImageMath.js" as IM
import "../../common/functions/Framing.js" as FR

// The framer: one card for all three of the shell's own pictures (the banner, the avatar,
// the phone wallpaper), where you choose which part of the picture fills its slot. Drag
// to move it, scroll / + and - / the slider to zoom, arrow keys to nudge; Reset centres it,
// Cancel (Esc) leaves it as it was, Done saves it (PanelImages.setFraming). Design:
// docs/PICTURE-FRAMING.md (the Claude Design canvas "Framing the shell's own pictures").
//
// 1010 x 720 design pixels. FramerWindow.qml puts it on screen (over Edit Desktop's stage,
// or over the desktop after a pick), scaled to the monitor.
Item {
    id: root

    readonly property var mt: Theme.of(QsWindow.window)

    // "banner" | "avatar" | "phone"
    property string kind: "banner"
    // Just picked: it starts centred and the card says so.
    property bool fresh: false

    // `saved`: Done (true) or Cancel / Esc (false).
    signal finished(bool saved)

    implicitWidth: 1010
    implicitHeight: 720

    // ===== the picture and its slot =====
    readonly property url source: root.kind === "avatar" ? PanelImages.avatar
        : (root.kind === "phone" ? PanelImages.phone : PanelImages.banner)
    // The slot as the framer draws it: the banner at its real size, the avatar 2.5x (its
    // real size is beside it), the phone's glass at its own proportions (616 x 1176), scaled
    // into the work area.
    readonly property real slotW: root.kind === "avatar" ? 300 : (root.kind === "phone" ? Math.round(437 * 616 / 1176) : 602)
    readonly property real slotH: root.kind === "avatar" ? 300 : (root.kind === "phone" ? 437 : 240)
    readonly property var slotRadii: root.kind === "avatar" ? [150, 150, 150, 150]
        : (root.kind === "phone" ? [30, 30, 30, 30] : [74, 74, 50, 50])
    readonly property real workW: 936
    readonly property real workH: 474
    readonly property real slotX: Math.round((root.workW - root.slotW) / 2)
    readonly property real slotY: Math.round((root.workH - root.slotH) / 2)

    // The framing being edited, and the one it started from (Cancel puts that back).
    property real zoom: 1
    property real panX: 0
    property real panY: 0
    property var start: ({ zoom: 1, panX: 0, panY: 0 })

    function load() {
        const f = root.fresh ? FR.normalize(null) : PanelImages.framingFor(root.kind)
        root.start = f
        root.zoom = f.zoom
        root.panX = f.panX
        root.panY = f.panY
    }
    onKindChanged: root.load()
    onFreshChanged: root.load()
    // Opened again while it is up (another Frame key, a new pick): start over.
    readonly property int seq: PanelImages.framingSeq
    onSeqChanged: root.load()
    Component.onCompleted: root.load()

    readonly property var current: ({ zoom: root.zoom, panX: root.panX, panY: root.panY })
    readonly property real aspect: probe.status === Image.Ready && probe.implicitHeight > 0
        ? probe.implicitWidth / probe.implicitHeight : 0
    readonly property var drawn: root.aspect > 0
        ? IM.drawRect(root.slotW, root.slotH, root.aspect * 1000, 1000, "crop", root.zoom, root.panX, root.panY)
        : ({ x: 0, y: 0, w: root.slotW, h: root.slotH })

    function setZoom(z) {
        root.zoom = Math.round(Math.max(1, Math.min(FR.MAX_ZOOM, z)) * 100) / 100
    }
    function panBy(dx, dy) {
        if (!(root.aspect > 0))
            return
        const p = IM.panBy(root.slotW, root.slotH, root.aspect * 1000, 1000, root.zoom, root.panX, root.panY, dx, dy)
        root.panX = p.panX
        root.panY = p.panY
    }
    function reset() {
        root.zoom = 1
        root.panX = 0
        root.panY = 0
    }
    function cancel() {
        // Everything is left as it was: the framing, and a picture just picked is put
        // back to the one it replaced (PanelImages.closeFramer).
        root.finished(false)
    }
    function done() {
        PanelImages.setFraming(root.kind, root.current)
        root.finished(true)
    }

    Image {
        id: probe
        source: root.source
        sourceSize.width: 64
        asynchronous: true
        visible: false
    }

    // ===== the keys (outline, ring, fill, hard shadow; lit = the accent gradient) =====
    component Key: Item {
        id: key
        property string icon: ""
        property string text: ""
        property bool lit: false
        property real size: 44
        property string badge: ""
        signal clicked()

        readonly property bool round: key.text === ""
        readonly property real bw: key.lit ? 4 : 3
        readonly property real ring: key.lit ? 4 : 3
        readonly property real dx: key.lit ? 6 : 4
        readonly property real dy: key.lit ? 4 : 3
        implicitWidth: (key.round ? key.size : row.implicitWidth + (key.lit ? 40 : 28)) + key.dx
        implicitHeight: key.size + key.dy

        Rectangle {
            x: key.dx
            y: key.dy
            width: key.width - key.dx
            height: key.height - key.dy
            radius: height / 2
            color: root.mt.pLineShadow
        }
        Rectangle {
            id: cap
            width: key.width - key.dx
            height: key.height - key.dy
            x: area.pressed ? key.dx : 0
            y: area.pressed ? key.dy : 0
            radius: height / 2
            color: key.lit ? "transparent" : root.mt.pSurface
            border.width: key.bw
            border.color: key.lit ? root.mt.colBorder : root.mt.pLine
            gradient: key.lit ? litGrad : null
            Gradient {
                id: litGrad
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: root.mt.accentMint }
                GradientStop { position: 1; color: root.mt.accentCyan }
            }
            Behavior on x { NumberAnimation { duration: area.pressed ? 60 : 260; easing.type: area.pressed ? Easing.OutQuad : Easing.OutBack; easing.overshoot: 2.2 } }
            Behavior on y { NumberAnimation { duration: area.pressed ? 60 : 260; easing.type: area.pressed ? Easing.OutQuad : Easing.OutBack; easing.overshoot: 2.2 } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: key.bw
                radius: height / 2
                color: "transparent"
                border.width: key.ring
                border.color: key.lit ? "#ffffff" : root.mt.pRingWhite
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 7
                MaterialIcon {
                    visible: key.icon !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    name: key.icon
                    size: 18
                    color: key.lit ? root.mt.colBorder : root.mt.pInk
                }
                Text {
                    visible: key.text !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: key.text
                    color: key.lit ? root.mt.colBorder : root.mt.pInk
                    font.family: root.mt.fontFamily
                    font.pixelSize: key.lit ? 16 : 15
                    font.weight: Font.ExtraBold
                    font.styleName: root.mt.fontStyleBold
                }
                Rectangle {
                    visible: key.badge !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    width: badgeText.implicitWidth + 12
                    height: 24
                    radius: 7
                    color: root.mt.pInk
                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: key.badge
                        color: root.mt.pSurface
                        font.family: root.mt.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.ExtraBold
                        font.styleName: root.mt.fontStyleBold
                    }
                }
            }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: key.clicked()
        }
    }

    // A soft chip: "New picture: starts centred", "Saved", "Text over it: white".
    component Chip: Rectangle {
        property string text: ""
        property string icon: ""
        property color swatch: "transparent"
        property bool hasSwatch: false
        height: 26
        width: chipRow.implicitWidth + (hasSwatch ? 18 : 24)
        radius: 13
        color: root.mt.pSurfaceDivider
        Row {
            id: chipRow
            anchors.verticalCenter: parent.verticalCenter
            x: parent.hasSwatch ? 6 : 12
            spacing: 7
            Rectangle {
                visible: chipRow.parent.hasSwatch
                width: 16
                height: 16
                radius: 8
                color: chipRow.parent.swatch
                border.width: 2
                border.color: root.mt.pLine
                anchors.verticalCenter: parent.verticalCenter
            }
            MaterialIcon {
                visible: chipRow.parent.icon !== ""
                name: chipRow.parent.icon
                size: 14
                color: root.mt.pInk
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: chipRow.parent.text
                color: root.mt.pInk
                font.family: root.mt.fontFamily
                font.pixelSize: 13
                font.weight: Font.ExtraBold
                font.styleName: root.mt.fontStyleBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ===== the banner's ink, as the Quick Panel picks it =====
    property bool inkDark: false
    Canvas {
        id: sampler
        width: 60
        height: 24
        opacity: 0
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Immediate
        readonly property url src: root.kind === "banner" && probe.status === Image.Ready ? root.source : ""
        readonly property var watch: [root.zoom, root.panX, root.panY]
        onSrcChanged: if (src.toString() !== "") loadImage(src)
        onWatchChanged: requestPaint()
        onImageLoaded: requestPaint()
        onPaint: {
            if (src.toString() === "" || !isImageLoaded(src) || !(root.aspect > 0))
                return
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const r = IM.drawRect(width, height, root.aspect * 1000, 1000, "crop", root.zoom, root.panX, root.panY)
            ctx.drawImage(src, r.x, r.y, r.w, r.h)
            const d = ctx.getImageData(4, 1, 15, 5).data
            let sum = 0, n = 0
            for (let i = 0; i < d.length; i += 4) {
                if (d[i + 3] === 0)
                    continue
                sum += 0.2126 * Math.pow(d[i] / 255, 2.2) + 0.7152 * Math.pow(d[i + 1] / 255, 2.2) + 0.0722 * Math.pow(d[i + 2] / 255, 2.2)
                n++
            }
            root.inkDark = n > 0 && sum / n < 0.30
        }
    }
    readonly property color bannerInk: root.inkDark ? "#ffffff" : root.mt.colBorder

    // ===== the card =====
    Rectangle {
        // hard shadow
        x: 5
        y: 26 + 4
        width: 1000
        height: 664
        radius: 30
        color: root.mt.pLineShadow
    }
    Rectangle {
        id: card
        x: 0
        y: 26
        width: 1000
        height: 664
        radius: 30
        color: root.mt.pSurface
        border.width: 3
        border.color: root.mt.pLine

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: 27
            color: "transparent"
            border.width: 5
            border.color: root.mt.pSurfaceRing
        }

        // The halftone in the bottom-right corner, kept inside the card's round corner.
        RoundClip {
            anchors.fill: parent
            anchors.margins: 3
            radii: [27, 27, 27, 27]
            DotField {
                x: parent.width - width
                y: parent.height - height
                width: 260
                height: 170
                corner: "br"
                spacing: 10
                maxRadius: 1.6
                dotColor: Qt.alpha(root.mt.pLine, 0.35)
            }
        }

        // three slanted stripes, top right
        Row {
            x: card.width - 34 - width
            y: 14
            spacing: 6
            Repeater {
                model: [root.mt.attributeColors[2], root.mt.attributeColors[1], root.mt.attributeColors[0]]
                delegate: Slant {
                    required property var modelData
                    width: 10
                    height: 20
                    skew: 0.45
                    radius: 0
                    color: modelData
                }
            }
        }

        // top right: what this picture is doing
        Row {
            x: card.width - 90 - width
            y: 10
            spacing: 8
            Chip {
                visible: root.fresh
                icon: "auto_awesome"
                text: "New picture: starts centred"
            }
            // The phone: which of its screens to show over the picture.
            Rectangle {
                visible: root.kind === "phone"
                width: screensRow.implicitWidth + 6
                height: 30
                radius: 15
                color: root.mt.pSurfaceDivider
                Row {
                    id: screensRow
                    x: 3
                    y: 3
                    spacing: 4
                    Repeater {
                        model: [["quick", "Quick"], ["apps", "Apps"]]
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool on: root.phoneScreen === modelData[0]
                            width: segText.implicitWidth + 24
                            height: 24
                            radius: 12
                            color: on ? root.mt.pSurface : "transparent"
                            border.width: 2
                            border.color: on ? root.mt.colBorder : "transparent"
                            Text {
                                id: segText
                                anchors.centerIn: parent
                                text: modelData[1]
                                color: root.mt.pInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.ExtraBold
                                font.styleName: root.mt.fontStyleBold
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.phoneScreen = modelData[0]
                            }
                        }
                    }
                }
            }
        }

        Column {
            x: 26
            y: 44
            width: card.width - 52
            spacing: 14

            // ===== the work area =====
            Rectangle {
                id: work
                width: 942
                height: 480
                radius: 20
                color: root.mt.pSurfaceDivider
                border.width: 3
                border.color: root.mt.pLine

                // Inside the border, rounded (the dimmed picture reaches its corners).
                RoundClip {
                    x: 3
                    y: 3
                    width: root.workW
                    height: root.workH
                    radii: [17, 17, 17, 17]

                    // The whole picture, dimmed: what the slot crops out. The picture at 38 %
                    // over the deep tone is the design's "deep at 62 % over it", drawn without
                    // an overlay (one over a picture inside this clip did not show).
                    Rectangle {
                        width: root.workW
                        height: root.workH
                        color: root.mt.colDeep
                    }
                    Image {
                        x: root.slotX + root.drawn.x
                        y: root.slotY + root.drawn.y
                        width: root.drawn.w
                        height: root.drawn.h
                        opacity: 0.38
                        source: root.aspect > 0 ? root.source : ""
                        sourceSize.width: 2400
                        asynchronous: true
                        smooth: true
                    }

                    // The slot's ring: white, then the border colour.
                    Rectangle {
                        x: root.slotX - 6
                        y: root.slotY - 6
                        width: root.slotW + 12
                        height: root.slotH + 12
                        color: root.mt.colBorder
                        topLeftRadius: root.slotRadii[0] + 6
                        topRightRadius: root.slotRadii[1] + 6
                        bottomLeftRadius: root.slotRadii[2] + 6
                        bottomRightRadius: root.slotRadii[3] + 6
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            color: "#ffffff"
                            topLeftRadius: root.slotRadii[0] + 3
                            topRightRadius: root.slotRadii[1] + 3
                            bottomLeftRadius: root.slotRadii[2] + 3
                            bottomRightRadius: root.slotRadii[3] + 3
                        }
                    }

                    // The slot: what shows.
                    RoundClip {
                        x: root.slotX
                        y: root.slotY
                        width: root.slotW
                        height: root.slotH
                        radii: root.slotRadii

                        Image {
                            x: root.drawn.x
                            y: root.drawn.y
                            width: root.drawn.w
                            height: root.drawn.h
                            source: root.aspect > 0 ? root.source : ""
                            sourceSize.width: 2400
                            asynchronous: true
                            smooth: true
                        }

                        // The banner: its clock and the speed readout over it, where the
                        // Quick Panel draws them, in the ink it would pick.
                        Column {
                            visible: root.kind === "banner"
                            x: 41
                            y: 10
                            spacing: -7
                            Text {
                                text: Qt.formatDateTime(new Date(), SettingsService.flag("time.use24h") ? "HH:mm" : "hh:mmAP")
                                color: root.bannerInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 24
                                font.weight: Font.ExtraBold
                                font.styleName: root.mt.fontStyleBold
                            }
                            Text {
                                text: Qt.formatDate(new Date(), "ddd, d  MMM")
                                color: root.bannerInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 20
                            }
                        }
                        Column {
                            visible: root.kind === "banner"
                            x: root.slotW - 41 - width
                            y: 12
                            Text {
                                anchors.right: parent.right
                                text: "↓"
                                color: root.bannerInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 20
                                font.weight: Font.ExtraBold
                            }
                            Text {
                                anchors.right: parent.right
                                text: "↑"
                                color: root.bannerInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 20
                                font.weight: Font.ExtraBold
                            }
                        }

                        // The phone: a hint of what sits over the picture.
                        Item {
                            visible: root.kind === "phone" && root.phoneScreen === "quick"
                            anchors.fill: parent
                            readonly property color cardFill: Qt.alpha(root.mt.pSurface, 0.78)
                            RoundClip {
                                x: 9; y: 9; width: parent.width - 18; height: 86
                                radii: [27, 27, 18, 18]
                                Rectangle {
                                    anchors.fill: parent
                                    color: root.mt.pSurfaceDivider
                                }
                                FramedImage {
                                    anchors.fill: parent
                                    source: PanelImages.banner
                                    framing: PanelImages.framingFor("banner")
                                    decodeScale: 1
                                }
                            }
                            Rectangle {
                                x: 14; y: 80; width: 44; height: 44; radius: 22
                                color: "#ffffff"
                                RoundClip {
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    radii: [19, 19, 19, 19]
                                    Rectangle {
                                        anchors.fill: parent
                                        color: root.mt.pSurfaceDivider
                                    }
                                    FramedImage {
                                        anchors.fill: parent
                                        source: PanelImages.avatar
                                        framing: PanelImages.framingFor("avatar")
                                        decodeScale: 1
                                    }
                                }
                            }
                            Rectangle {
                                x: 9; y: 132; width: parent.width - 18; height: 120; radius: 16
                                color: parent.cardFill
                                Grid {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    columns: 2
                                    spacing: 8
                                    Repeater {
                                        model: 4
                                        delegate: Rectangle {
                                            width: (parent.width - 8) / 2
                                            height: (parent.height - 8) / 2
                                            radius: 12
                                            color: root.mt.pSurface
                                            border.width: 2
                                            border.color: root.mt.pLine
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                x: 9; y: 266; width: parent.width - 18; height: 160; radius: 16
                                color: parent.cardFill
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: 60
                                    text: "All quiet here."
                                    color: root.mt.pInkSub
                                    font.family: root.mt.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                        Item {
                            visible: root.kind === "phone" && root.phoneScreen === "apps"
                            anchors.fill: parent
                            Rectangle {
                                x: 12; y: 22; width: parent.width - 24; height: 26; radius: 13
                                color: Qt.alpha(root.mt.pSurface, 0.78)
                                Text {
                                    x: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Search apps"
                                    color: root.mt.pInkSub
                                    font.family: root.mt.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.ExtraBold
                                }
                            }
                            Grid {
                                x: 14; y: 66; width: parent.width - 28
                                columns: 4
                                rowSpacing: 14
                                columnSpacing: 8
                                Repeater {
                                    model: 16
                                    delegate: Column {
                                        width: (parent.width - 24) / 4
                                        spacing: 4
                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 36; height: 36; radius: 11
                                            color: Qt.alpha(root.mt.pSurface, 0.78)
                                            border.width: 2
                                            border.color: root.mt.pLine
                                        }
                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 30; height: 5; radius: 3
                                            color: "#ffffff"
                                            opacity: 0.85
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // The banner: the avatar that sits on it, at its own framing, where the
                    // Quick Panel puts it.
                    Rectangle {
                        visible: root.kind === "banner" && PanelImages.avatar !== ""
                        x: root.slotX + 41
                        y: root.slotY + 182
                        width: 120
                        height: 120
                        radius: 60
                        color: root.mt.pLine
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: width / 2
                            color: "#ffffff"
                            RoundClip {
                                anchors.fill: parent
                                anchors.margins: 4
                                radii: [width / 2, width / 2, width / 2, width / 2]
                                FramedImage {
                                    anchors.fill: parent
                                    source: PanelImages.avatar
                                    framing: PanelImages.framingFor("avatar")
                                }
                            }
                        }
                    }

                    // The avatar: what it looks like at its real size.
                    Rectangle {
                        visible: root.kind === "avatar"
                        x: root.workW - 18 - width
                        y: root.workH - 18 - height
                        width: 168
                        height: realCol.implicitHeight + 22
                        radius: 13
                        color: root.mt.pSurface
                        border.width: 3
                        border.color: root.mt.pLine
                        Column {
                            id: realCol
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 12
                            spacing: 8
                            RoundClip {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 120
                                height: 120
                                radii: [60, 60, 60, 60]
                                Rectangle {
                                    anchors.fill: parent
                                    color: root.mt.pSurfaceDivider
                                }
                                FramedImage {
                                    anchors.fill: parent
                                    source: root.kind === "avatar" ? root.source : ""
                                    framing: root.current
                                    fixedDecodeWidth: 480
                                }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Real size, 120 px"
                                color: root.mt.pInk
                                font.family: root.mt.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.ExtraBold
                                font.styleName: root.mt.fontStyleBold
                            }
                        }
                    }

                    // Drag to move, scroll to zoom. The picture follows the pointer.
                    MouseArea {
                        id: drag
                        anchors.fill: parent
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        property real lastX: 0
                        property real lastY: 0
                        onPressed: mouse => {
                            drag.lastX = mouse.x
                            drag.lastY = mouse.y
                            root.forceActiveFocus()
                        }
                        onPositionChanged: mouse => {
                            if (!pressed)
                                return
                            root.panBy(mouse.x - drag.lastX, mouse.y - drag.lastY)
                            drag.lastX = mouse.x
                            drag.lastY = mouse.y
                        }
                        onWheel: wheel => {
                            const d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
                            if (d !== 0)
                                root.setZoom(FR.wheelZoom(root.zoom, d > 0))
                        }
                    }
                }

                Text {
                    visible: !(root.aspect > 0)
                    anchors.centerIn: parent
                    text: probe.status === Image.Error ? "Can't read this picture." : "Opening the picture…"
                    color: "#ffffff"
                    font.family: root.mt.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.ExtraBold
                }
            }

            // ===== under the work area =====
            Item {
                width: parent.width
                height: 26
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.kind === "avatar" ? "Drag to move it, scroll to zoom. Drawn 2.5× here; the real size is beside it."
                        : (root.kind === "phone" ? "Drag to move it, scroll to zoom. One framing for both screens, Quick and Apps."
                        : "Drag to move it, scroll to zoom. Shown at its real size: 602 × 240.")
                    color: root.mt.pInkSub
                    font.family: root.mt.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Chip {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    hasSwatch: true
                    swatch: root.kind === "banner" ? root.bannerInk
                        : (root.kind === "phone" ? Qt.alpha(root.mt.pSurface, 0.78) : root.mt.pSurface)
                    text: root.kind === "banner" ? (root.inkDark ? "Text over it: white" : "Text over it: navy")
                        : (root.kind === "phone" ? "Cards over it keep 78 % of their fill" : "Also on the desktop user card")
                }
            }

            // ===== the controls =====
            Row {
                width: parent.width
                height: 54
                spacing: 12

                Key {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "remove"
                    onClicked: root.setZoom(FR.stepZoom(root.zoom, -1))
                }

                // The zoom slider: a lit track and a round knob.
                Item {
                    id: slider
                    anchors.verticalCenter: parent.verticalCenter
                    width: 300
                    height: 44
                    readonly property real t: FR.zoomFraction(root.zoom)
                    Rectangle {
                        y: 14
                        width: parent.width
                        height: 16
                        radius: 8
                        color: root.mt.pSurfaceDivider
                        border.width: 3
                        border.color: root.mt.pLine
                        clip: true
                        Rectangle {
                            x: 3
                            y: 3
                            height: parent.height - 6
                            width: Math.max(0, (parent.width - 6) * slider.t)
                            radius: 5
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: root.mt.accentMint }
                                GradientStop { position: 1; color: root.mt.accentCyan }
                            }
                        }
                    }
                    Rectangle {
                        x: slider.t * (slider.width - 32) + 3
                        y: 6 + 2
                        width: 32
                        height: 32
                        radius: 16
                        color: root.mt.pLineShadow
                    }
                    Rectangle {
                        x: slider.t * (slider.width - 32)
                        y: 6
                        width: 32
                        height: 32
                        radius: 16
                        color: root.mt.pSurface
                        border.width: 3
                        border.color: root.mt.colBorder
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: width / 2
                            color: "transparent"
                            border.width: 3
                            border.color: root.mt.pRingWhite
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        function at(x) {
                            root.setZoom(FR.zoomFromFraction((x - 16) / (slider.width - 32)))
                        }
                        onPressed: mouse => at(mouse.x)
                        onPositionChanged: mouse => { if (pressed) at(mouse.x) }
                    }
                }

                Key {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "add"
                    onClicked: root.setZoom(FR.stepZoom(root.zoom, 1))
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 74
                    height: 36
                    radius: 18
                    color: root.mt.pSurfaceDivider
                    Text {
                        anchors.centerIn: parent
                        text: FR.zoomText(root.zoom)
                        color: root.mt.pInk
                        font.family: root.mt.fontFamily
                        font.pixelSize: 16
                        font.weight: Font.ExtraBold
                        font.styleName: root.mt.fontStyleBold
                        font.features: ({ "tnum": 1 })
                    }
                }

                Key {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "restart_alt"
                    text: "Reset"
                    onClicked: root.reset()
                }

                Item {
                    width: parent.width - x - cancelKey.width - doneKey.width - 2 * parent.spacing
                    height: 1
                }

                Key {
                    id: cancelKey
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Cancel"
                    badge: "Esc"
                    onClicked: root.cancel()
                }

                Key {
                    id: doneKey
                    anchors.verticalCenter: parent.verticalCenter
                    lit: true
                    size: 48
                    icon: "check"
                    text: "Done"
                    onClicked: root.done()
                }
            }
        }
    }

    // Which phone screen shows over the phone picture.
    property string phoneScreen: "quick"

    // ===== the name plate, leaning across the card's top edge =====
    Item {
        x: 36
        y: 4
        width: plateFace.width + 4
        height: 44 + 3
        Rectangle {
            x: 4
            y: 3
            width: plateFace.width
            height: 44
            radius: 15
            color: root.mt.colBorder
            transform: Matrix4x4 { matrix: Qt.matrix4x4(1, -0.21, 0, 22 * 0.21, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
        }
        Rectangle {
            id: plateFace
            width: plateText.implicitWidth + 44
            height: 44
            radius: 15
            color: root.kind === "avatar" ? root.mt.attributeColors[1] : (root.kind === "phone" ? root.mt.attributeColors[2] : root.mt.attributeColors[0])
            border.width: 3
            border.color: root.mt.colBorder
            transform: Matrix4x4 { matrix: Qt.matrix4x4(1, -0.21, 0, 22 * 0.21, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
        }
        Text {
            id: plateText
            x: 22
            anchors.verticalCenter: plateFace.verticalCenter
            text: root.kind === "avatar" ? "Frame the avatar" : (root.kind === "phone" ? "Frame the phone wallpaper" : "Frame the banner")
            color: root.mt.colBorder
            font.family: root.mt.fontFamily
            font.pixelSize: 21
            font.weight: Font.ExtraBold
            font.styleName: root.mt.fontStyleBold
        }
    }

    // ===== keys =====
    focus: true
    Keys.onPressed: event => {
        const k = event.key
        if (k === Qt.Key_Escape) {
            root.cancel()
        } else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            root.done()
        } else if (k === Qt.Key_Left) {
            root.panBy(12, 0)
        } else if (k === Qt.Key_Right) {
            root.panBy(-12, 0)
        } else if (k === Qt.Key_Up) {
            root.panBy(0, 12)
        } else if (k === Qt.Key_Down) {
            root.panBy(0, -12)
        } else if (k === Qt.Key_Plus || k === Qt.Key_Equal) {
            root.setZoom(FR.stepZoom(root.zoom, 1))
        } else if (k === Qt.Key_Minus) {
            root.setZoom(FR.stepZoom(root.zoom, -1))
        } else {
            return
        }
        event.accepted = true
    }
}
