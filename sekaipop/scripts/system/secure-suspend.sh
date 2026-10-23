#!/usr/bin/env bash
# Suspend only after the compositor confirms that every output is covered.
set -euo pipefail
action=${1:-suspend}
case "$action" in suspend|hibernate) :;; *) exit 2;; esac
QS=$(command -v qs || command -v quickshell) || exit 1
"$QS" -c sekaipop ipc call lock lock || { echo 'Cannot lock: refusing suspend.' >&2; exit 1; }
for ((i=0; i<100; i++)); do
    if [[ $("$QS" -c sekaipop ipc call lock secure 2>/dev/null) == true ]]; then
        exec systemctl "$action"
    fi
    sleep 0.1
done
echo 'Compositor did not confirm a secure lock; refusing suspend.' >&2
exit 1
