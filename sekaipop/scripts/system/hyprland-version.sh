#!/bin/sh
# Hyprland 0.55 requires XDG_RUNTIME_DIR even for --version.
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    Hyprland --version 2>/dev/null
else
    tmp=$(mktemp -d) || exit 1
    trap 'rm -rf "$tmp"' EXIT
    XDG_RUNTIME_DIR="$tmp" Hyprland --version 2>/dev/null
fi
