#!/usr/bin/env bash
# Native ARM64 build of a pinned upstream revision, with locked Cargo dependencies.
set -euo pipefail
DRY=${1:-0}
if command -v matugen >/dev/null; then matugen --version; exit 0; fi
if [[ $DRY == 1 ]]; then
    echo 'would install matugen from APT or build pinned v4.2.0 with Debian backports Rust (no rustup/system Qt replacement)'
    exit 0
fi
if apt-cache show matugen >/dev/null 2>&1; then
    sudo apt-get install -y matugen
    exit 0
fi
sudo apt-get --no-install-recommends -t trixie-backports install -y build-essential pkg-config cargo rustc
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
REV=bb27a35d7f9e0f57cf638703f3d8e3182aed0304
git -C "$TMP" init -q
git -C "$TMP" remote add origin https://github.com/InioX/matugen.git
git -C "$TMP" fetch --depth 1 origin "$REV"
git -C "$TMP" checkout --detach FETCH_HEAD
[[ $(git -C "$TMP" rev-parse HEAD) == "$REV" ]]
# Use the distribution compiler even when the user's PATH contains another toolchain.
CARGO_HOME="$TMP/cargo" RUSTC=/usr/bin/rustc /usr/bin/cargo build --release --locked --manifest-path "$TMP/Cargo.toml" --jobs "${SEKAIPOP_BUILD_JOBS:-2}"
sudo install -m 755 "$TMP/target/release/matugen" /usr/local/bin/matugen
/usr/local/bin/matugen --version
