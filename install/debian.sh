#!/usr/bin/env bash
# Debian backend for install-deps.sh; no system-wide upgrade or driver replacement.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/debian-packages.sh"
DRY=0 YES=0 CORE_ONLY=0 DESKTOP=1 OPT=0 SERVICES=1 FONTS=1 SESSION=1 UPDATE=1 DDC=0 FM=auto UTM=0
for_arg_error() { echo "$*" >&2; exit 2; }
while (($#)); do
    case "$1" in
        --dry-run) DRY=1;; --yes|-y) YES=1;; --core-only) CORE_ONLY=1;;
        --utm) UTM=1;;
        --with-optional) OPT=1;; --no-desktop-layer) DESKTOP=0;;
        --no-services) SERVICES=0;; --no-fonts) FONTS=0;; --no-session) SESSION=0;;
        --no-update) UPDATE=0;; --no-aur) :;; --ddc) DDC=1;;
        --gpu) shift; case "${1:-}" in amd|intel|nvidia|skip) echo 'Debian: retaining the installed GPU driver.';; *) for_arg_error 'Invalid --gpu value';; esac;;
        --file-manager) shift; FM=${1:-}; case "$FM" in dolphin|thunar|none) :;; *) for_arg_error 'Invalid --file-manager value';; esac;;
        -h|--help) echo 'Debian 13 ARM64/AMD64: install-deps.sh [--dry-run] [--yes] [--utm] [--core-only] [--with-optional] [--no-services] [--no-fonts] [--no-session] [--no-update] [--no-desktop-layer] [--file-manager dolphin|thunar|none] [--ddc]'; exit 0;;
        *) for_arg_error "Unknown option: $1";;
    esac
    shift
done
source /etc/os-release
[[ ${ID:-} == debian && ${VERSION_CODENAME:-} == trixie ]] || for_arg_error 'Requires Debian 13 (trixie).'
ARCH=$(dpkg --print-architecture)
case "$ARCH" in arm64|amd64) :;; *) for_arg_error "Unsupported Debian architecture: $ARCH";; esac
[[ $(id -u) != 0 ]] || for_arg_error 'Run as your normal user with sudo.'
command -v sudo >/dev/null || for_arg_error 'Install sudo and grant your normal user sudo access first.'
run() { if ((DRY)); then printf 'would run:'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
WANT=("${DEBIAN_CORE[@]}")
((UTM == 0)) || WANT+=(spice-vdagent pciutils mesa-utils)
if ((!CORE_ONLY)); then
    WANT+=("${DEBIAN_FEATURES[@]}")
    if ((DESKTOP)); then
        WANT+=("${DEBIAN_DESKTOP[@]}")
        if [[ ! -s /etc/X11/default-display-manager && ! -e /etc/systemd/system/display-manager.service ]] || [[ $(cat /etc/X11/default-display-manager 2>/dev/null) == /usr/sbin/lightdm ]]; then
            WANT+=(lightdm lightdm-gtk-greeter xserver-xorg xserver-xorg-input-libinput xauth)
        fi
        [[ $FM != auto ]] || { if command -v dolphin >/dev/null; then FM=dolphin; else FM=thunar; fi; }
        case "$FM" in dolphin) WANT+=(dolphin kio-extras ffmpegthumbs kde-style-breeze);; thunar) WANT+=(thunar thunar-volman tumbler);; esac
    fi
fi
# Backports is preferred only for this requested dependency closure; no global pinning or full upgrade.
BP_FILE=/etc/apt/sources.list.d/sekaipop-backports.sources
if ! grep -RqsE '^[^#]*trixie-backports' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
    if ((DRY)); then echo "would add official trixie-backports to $BP_FILE";
    else
        [[ ! -e $BP_FILE ]] || for_arg_error "$BP_FILE exists but does not enable backports; inspect it first."
        printf '%s\n' 'Types: deb' 'URIs: http://deb.debian.org/debian' 'Suites: trixie-backports' 'Components: main' 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' | sudo tee "$BP_FILE" >/dev/null
    fi
fi
if ((UPDATE)); then run sudo apt-get -o APT::Update::Error-Mode=any update; fi
PACKAGES=("${WANT[@]}")
if ((OPT)); then
    for p in "${DEBIAN_OPTIONAL[@]}"; do
        if ((DRY)) || apt-cache show "$p" >/dev/null 2>&1; then PACKAGES+=("$p"); else echo "Optional package unavailable: $p"; fi
    done
fi
if ((DRY)); then
    run sudo apt-get --no-install-recommends -t trixie-backports install "${PACKAGES[@]}"
else
    # Resolve the entire required set before installing anything.
    apt-get --simulate --no-install-recommends -t trixie-backports install "${PACKAGES[@]}" >/dev/null
    FLAGS=(); ((YES == 0)) || FLAGS+=(-y)
    sudo apt-get --no-install-recommends -t trixie-backports install "${FLAGS[@]}" "${PACKAGES[@]}"
fi
if ((FONTS)); then run bash "$HERE/fonts.sh"; fi
# matugen is not in every Debian suite. Build the pinned upstream crate locally when needed.
if ((!CORE_ONLY)); then
    run bash "$HERE/matugen.sh" "$DRY"
    run bash "$HERE/gtk-theme.sh"
fi
if command -v xdg-user-dirs-update >/dev/null; then run xdg-user-dirs-update; fi
if ((SERVICES)); then
    if [[ -d /run/systemd/system ]]; then
        # Never replace another network manager automatically.
        if systemctl is-active --quiet systemd-networkd && ! systemctl is-active --quiet NetworkManager; then
            echo 'systemd-networkd is active; NetworkManager was not enabled. Wi-Fi controls require an intentional migration.'
        else run sudo systemctl enable --now NetworkManager.service; fi
        for unit in bluetooth.service upower.service power-profiles-daemon.service; do
            if systemctl cat "$unit" >/dev/null 2>&1; then run sudo systemctl start "$unit"; fi
        done
        if systemctl --user show-environment >/dev/null 2>&1; then
            run systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
        else echo 'No user bus: activate PipeWire after logging in to Hyprland.'; fi
    else echo 'No running systemd session: services will be checked at desktop login.'; fi
fi
if ((SERVICES && DESKTOP && !CORE_ONLY)); then
    run bash "$HERE/display-manager.sh" "$DRY"
fi
if ((DDC)); then
    run sudo groupadd -f i2c
    run sudo usermod -aG i2c "$(id -un)"
    if ((DRY)); then echo 'would configure i2c-dev'; else printf 'i2c-dev\n' | sudo tee /etc/modules-load.d/sekaipop-i2c.conf >/dev/null; fi
fi
if ((SESSION)); then run bash "$HERE/session.sh" "$DRY" "$UTM"; fi
echo 'Debian dependencies prepared. GPU drivers and existing DNS configuration were retained.'
echo 'Optional WARP and Discord/Vencord clients are not installed automatically.'
