#!/bin/sh
# Stable line protocol consumed by PackageUpdatesService. Checks never invoke sudo.
export LC_ALL=C
backend=unknown
if [ -r /etc/os-release ]; then . /etc/os-release; fi
if [ "${ID:-}" = debian ]; then backend=apt
elif command -v checkupdates >/dev/null 2>&1 || command -v pacman >/dev/null 2>&1; then backend=arch; fi
mode=${1:-}
if [ "$mode" = backend ]; then echo "$backend"; exit 0; fi
if [ "$mode" = run ]; then
    case "$backend" in
        apt) sudo apt-get -o APT::Update::Error-Mode=any update && sudo apt-get upgrade; rc=$?;;
        arch) if command -v paru >/dev/null 2>&1; then paru; elif command -v yay >/dev/null 2>&1; then yay; else sudo pacman -Syu; fi; rc=$?;;
        *) echo 'Unsupported package manager'; rc=1;;
    esac
    printf '\nUpdate command exited %s. Press Enter to close ' "$rc"; read -r _
    exit "$rc"
fi
[ "$mode" = check ] || { echo 'Usage: pkg-updates.sh check [aur: 0|1] | run | backend' >&2; exit 2; }
echo "backend=$backend"
case "$backend" in
    apt)
        command -v apt-get >/dev/null 2>&1 || { echo status=nocmd; exit 0; }
        out=$(apt-get -s -o Debug::NoLocking=1 upgrade 2>/dev/null) || { echo status=error; exit 0; }
        packages=$(printf '%s\n' "$out" | awk '/^Inst / {old=$3; gsub(/[][]/,"",old); new=$4; sub(/^\(/,"",new); print "pkg=" $2 " " old " -> " new}')
        count=$(printf '%s\n' "$packages" | awk 'NF {n++} END {print n+0}')
        held=$(apt-mark showhold 2>/dev/null | awk 'NF {n++} END {print n+0}')
        # Newest package-index mtime, not the time we last looked at the cache.
        stamp=$(find /var/lib/apt/lists -maxdepth 1 -type f -name '*Packages*' -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)
        echo status=ok; echo "repo=$count"; echo aur=0; echo "held=$held"; echo "index_at=${stamp:-0}"
        [ -z "$packages" ] || printf '%s\n' "$packages" | head -40
        ;;
    arch)
        command -v checkupdates >/dev/null 2>&1 || { echo status=nocmd; exit 0; }
        out=$(checkupdates 2>/dev/null); rc=$?
        case "$rc" in 0) :;; 2) out=;; *) echo status=error; exit 0;; esac
        aurout=
        if [ "${2:-0}" = 1 ]; then
            if command -v paru >/dev/null 2>&1; then aurout=$(paru -Qua 2>/dev/null)
            elif command -v yay >/dev/null 2>&1; then aurout=$(yay -Qua 2>/dev/null); fi
        fi
        echo status=ok
        printf '%s\n' "$out" | awk 'NF {n++} END {print "repo=" n+0}'
        printf '%s\n' "$aurout" | awk 'NF {n++} END {print "aur=" n+0}'
        printf '%s\n' "$out" | head -40 | awk 'NF>=4 {print "pkg=" $1 " " $2 " -> " $4}'
        printf '%s\n' "$aurout" | head -20 | awk 'NF>=4 {print "aurpkg=" $1 " " $2 " -> " $4}'
        ;;
    *) echo status=nocmd;;
esac
