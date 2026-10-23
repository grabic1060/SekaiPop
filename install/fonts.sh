#!/usr/bin/env bash
set -euo pipefail
DEST=${XDG_DATA_HOME:-$HOME/.local/share}/fonts/sekaipop
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fetch_font() {
    local name=$1 hash=$2 url=$3 family=$4
    if fc-list -f '%{family}\n' | grep -F "$family" >/dev/null; then return; fi
    curl --fail --location --retry 3 --connect-timeout 20 --max-time 180 "$url" -o "$TMP/$name"
    printf '%s  %s\n' "$hash" "$TMP/$name" | sha256sum --check --status
    mkdir -p "$DEST"
    install -m 644 "$TMP/$name" "$DEST/$name"
}
fetch_font GoogleSansFlex.ttf 2510a8b7a24beb1fe8163e9a49813ccfe96b5453444b9443d42665ca4fa320c9 \
 'https://raw.githubusercontent.com/end-4/google-sans-flex/251aa5abd30496368f634e54ce2a508fe5a2fdfa/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf' 'Google Sans Flex'
fetch_font MaterialSymbolsRounded.ttf 32e4011709e055596eb8d2dd0f7cb547b47c1d40ac9ecb8fad54f7f7eac202e7 \
 'https://raw.githubusercontent.com/google/material-design-icons/49d4db35df873165d6bd6ba09b063c7dafbac2f4/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf' 'Material Symbols Rounded'
mkdir -p "$DEST"
curl --fail --location --retry 3 'https://raw.githubusercontent.com/end-4/google-sans-flex/251aa5abd30496368f634e54ce2a508fe5a2fdfa/LICENSE' -o "$DEST/GoogleSansFlex-LICENSE"
curl --fail --location --retry 3 'https://raw.githubusercontent.com/google/material-design-icons/49d4db35df873165d6bd6ba09b063c7dafbac2f4/LICENSE' -o "$DEST/MaterialSymbols-LICENSE"
fc-cache -f
