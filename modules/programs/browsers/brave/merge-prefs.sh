#!/usr/bin/env bash
set -euo pipefail

JQ_BIN="$1"
PREFS_JSON="$2"
PREFS_FILE="$3"

if [ ! -f "$PREFS_FILE" ]; then
  echo "[Brave] SKIP: Preferences not found"
  exit 0
fi

# Deep merge: existing prefs as base, external JSON overrides/adds keys.
"$JQ_BIN" --slurpfile new "$PREFS_JSON" '. * $new[0]' "$PREFS_FILE" > "$PREFS_FILE.tmp"

if ! diff -q <("$JQ_BIN" -S '.' "$PREFS_FILE") <("$JQ_BIN" -S '.' "$PREFS_FILE.tmp") >/dev/null 2>&1; then
  cp "$PREFS_FILE" "$PREFS_FILE.bak.$(date +%s)"
  mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  echo "[Brave] APPLIED"
else
  rm "$PREFS_FILE.tmp"
  echo "[Brave] UNCHANGED"
fi
