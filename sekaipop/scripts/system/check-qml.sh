#!/usr/bin/env bash
# Import smoke test; on Wayland also compile (do not instantiate) the staged shell.
set -euo pipefail
QS=$(command -v qs || command -v quickshell) || { echo 'Quickshell is missing' >&2; exit 1; }
tmp=$(mktemp -d)
probe="$tmp/shell.qml"
platform=offscreen
entry=""
wayland=${WAYLAND_DISPLAY:-}
if [[ -n ${1:-} && -n $wayland ]]; then
    [[ $wayland == /* ]] || wayland="${XDG_RUNTIME_DIR:-}/$wayland"
    if [[ -S $wayland ]]; then
        platform=wayland
        entry="file://$1/shell.qml"
        probe=$(mktemp "$1/.sekaipop-check.XXXXXX.qml")
    fi
fi
trap 'rm -f "$probe"; rm -rf "$tmp"' EXIT
cat > "$probe" <<'QML'
import QtQuick
import QtQuick.Controls.impl
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Layouts
import QtQml.Models
import Qt.labs.folderlistmodel
import QtMultimedia
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.Polkit
import Quickshell.Services.Notifications
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
QML
if [[ -n $entry ]]; then grep '^import qs' "$1/shell.qml" >> "$probe"; fi
cat >> "$probe" <<'QML'
ShellRoot {
    Timer {
        interval: 100; running: true
        onTriggered: {
            const entry = Quickshell.env("SEKAIPOP_QML_ENTRY")
            if (entry) {
                const component = Qt.createComponent(Qt.resolvedUrl("shell.qml"))
                if (component.status !== Component.Ready) {
                    console.error(component.errorString())
                    Qt.quit()
                    return
                }
            }
            console.log("SEKAIPOP_IMPORTS_OK")
            Qt.quit()
        }
    }
}
QML
mkdir -p "$tmp/runtime" "$tmp/cache"
chmod 700 "$tmp/runtime"
SEKAIPOP_QML_ENTRY="$entry" WAYLAND_DISPLAY="$wayland" XDG_RUNTIME_DIR="$tmp/runtime" XDG_CACHE_HOME="$tmp/cache" QT_QPA_PLATFORM="$platform" timeout 30 "$QS" -p "$probe" > "$tmp/log" 2>&1 || { cat "$tmp/log" >&2; exit 1; }
grep -q SEKAIPOP_IMPORTS_OK "$tmp/log" || { cat "$tmp/log" >&2; exit 1; }
if [[ -n $entry ]]; then echo 'Quickshell imports and full shell component compilation passed.'
else echo 'Quickshell imports passed (headless; full shell/GPU verification requires Wayland).'; fi
