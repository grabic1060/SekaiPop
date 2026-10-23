#!/usr/bin/env bash
# Shared installation/update gate; run against a staging copy, never the live shell.
set -euo pipefail
RICE=${1:?Usage: prepare-runtime.sh /path/to/staged/sekaipop}
QSB=${QSB:-}
if [[ -z $QSB ]]; then
    for candidate in qsb qsb6 /usr/lib/qt6/bin/qsb /usr/lib/qt6-shadertools/bin/qsb; do
        if command -v "$candidate" >/dev/null 2>&1; then QSB=$(command -v "$candidate"); break; fi
    done
fi
[[ -n $QSB && -x $QSB ]] || { echo 'qsb missing: install qt6-shader-baker (Debian) or qt6-shadertools (Arch).' >&2; exit 1; }
version=$("$QSB" --version 2>&1)
qt=$(printf '%s\n' "$version" | grep -oE '6\.[0-9]+\.[0-9]+' | head -1)
[[ -n $qt && $(printf '%s\n' 6.7.0 "$qt" | sort -V | head -1) == 6.7.0 ]] || { echo "Qt 6.7+ required: $version" >&2; exit 1; }
# On Debian qsb and Quickshell must use the same private Qt ABI.
if command -v dpkg-query >/dev/null 2>&1; then
    runtime=$(dpkg-query -W -f='${Version}' libqt6core6t64 2>/dev/null || true)
    runtime=${runtime#*:}; runtime=${runtime%%+*}; runtime=${runtime%%-*}
    [[ -z $runtime || $qt == "$runtime" ]] || { echo "qsb $qt does not match installed Qt $runtime" >&2; exit 1; }
fi
QSB="$QSB" bash "$RICE/shaders/compile-shaders.sh"
# Binary-only shaders must be readable by the target Qt too. No silent skip.
count=0
while IFS= read -r -d '' file; do
    dump=$("$QSB" --dump "$file" 2>&1) || { echo "Incompatible shader: $file: $dump" >&2; exit 1; }
    [[ $dump == *'SPIR-V'* && $dump == *'GLSL'* ]] || { echo "Shader lacks Vulkan/OpenGL targets: $file" >&2; exit 1; }
    count=$((count + 1))
done < <(find "$RICE/shaders" -name '*.qsb' -type f -print0)
((count >= 36)) || { echo "Incomplete shader set ($count, expected at least 36)" >&2; exit 1; }
printf 'Qt %s: %s shader bundles validated\n' "$qt" "$count"
printf 'qt=%s\nshaders=%s\n' "$qt" "$count" > "$RICE/.runtime"
