#!/usr/bin/env bash
# Read-only Debian dependency diagnostics; package names share the install manifest.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/debian-packages.sh"
CORE_ONLY=0
for arg in "$@"; do
    case "$arg" in --core) CORE_ONLY=1;; --no-color) :;; -h|--help) echo 'check-deps.sh [--core] [--no-color]'; exit 0;; *) echo "Unknown option: $arg" >&2; exit 2;; esac
done
missing=()
for p in "${DEBIAN_CORE[@]}"; do
    [[ $(dpkg-query -W -f='${Status}' "$p" 2>/dev/null) == 'install ok installed' ]] || missing+=("$p")
done
if ((${#missing[@]})); then
    printf 'Missing required Debian packages: %s\n' "${missing[*]}"
    printf 'Install using: bash install-deps.sh --core-only\n'
fi
fail=${#missing[@]}
version=$(sh "$HERE/../sekaipop/scripts/system/hyprland-version.sh" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
if [[ -z $version || $(printf '%s\n' 0.55 "$version" | sort -V | head -1) != 0.55 ]]; then echo 'Hyprland 0.55+ is required'; fail=$((fail+1)); fi
for family in 'Google Sans Flex' 'Material Symbols Rounded'; do
    if ! fc-list -f '%{family}\n' 2>/dev/null | grep -F "$family" >/dev/null; then echo "Missing font: $family (bash install/fonts.sh)"; fail=$((fail+1)); fi
done
if ! bash "$HERE/../sekaipop/scripts/system/check-qml.sh"; then fail=$((fail+1)); fi
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    echo 'No enabled graphical login manager. Full Debian installation configures LightDM; TTY-only installs require starting Hyprland manually.'
fi
if ((!CORE_ONLY)); then
    for p in "${DEBIAN_DESKTOP[@]}" "${DEBIAN_FEATURES[@]}"; do
        [[ $(dpkg-query -W -f='${Status}' "$p" 2>/dev/null) == 'install ok installed' ]] || echo "Feature package missing: $p"
    done
    command -v matugen >/dev/null || echo 'Theming missing: run bash install/matugen.sh'
    for unit in NetworkManager bluetooth upower power-profiles-daemon; do
        systemctl is-active --quiet "$unit" 2>/dev/null || echo "Session check: $unit is not active (hardware/service availability varies)"
    done
fi
[[ -n ${WAYLAND_DISPLAY:-} ]] || echo 'No Wayland session: GPU, portals, PAM, audio and suspend are not verified.'
printf 'Debian core errors: %s\n' "$fail"
((fail == 0))
