#!/usr/bin/env bash
# Kompiluje DataModels.swift razem z Tools/ModelChecks/main.swift i uruchamia sprawdzenia.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$DIR")"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

# stdout kompilatora pomijamy (na Windowsie linker dopisuje komunikaty), błędy idą na stderr
swiftc "$ROOT/Lingo/DataModel/DataModels.swift" "$DIR/ModelChecks/main.swift" -o "$OUT/modelchecks" >/dev/null 2>"$OUT/swiftc.log"
STATUS=$?
grep -v "modelchecks.lib" "$OUT/swiftc.log" >&2
[ $STATUS -eq 0 ] || exit $STATUS
"$OUT/modelchecks" "$ROOT/Lingo/DataModel/data.json"
exit $?
