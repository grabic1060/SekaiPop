#!/usr/bin/env bash
# Architecture-independent release archive, pinned by SHA-256.
set -euo pipefail
DEST=${XDG_DATA_HOME:-$HOME/.local/share}/themes
if [[ -d /usr/share/themes/adw-gtk3 || -d $DEST/adw-gtk3 ]]; then exit 0; fi
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
curl --fail --location --retry 3 --connect-timeout 20 --max-time 180 \
  https://github.com/lassekongo83/adw-gtk3/releases/download/v6.5/adw-gtk3v6.5.tar.xz -o "$TMP/theme.tar.xz"
printf '%s  %s\n' a81780fadfc432be0fc3d89c4ebb41aa28e4f032d42c36f9789c57dd10cfa41c "$TMP/theme.tar.xz" | sha256sum --check --status
tar --no-same-owner -xf "$TMP/theme.tar.xz" -C "$TMP"
mkdir -p "$DEST"
for theme in adw-gtk3 adw-gtk3-dark; do
    [[ -d $TMP/$theme/gtk-3.0 ]]
    [[ ! -e $DEST/$theme ]] || { echo "Keeping existing $DEST/$theme"; continue; }
    cp -a "$TMP/$theme" "$DEST/"
done
