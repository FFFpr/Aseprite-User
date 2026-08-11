#!/usr/bin/env bash
# Export src/**/*.aseprite|*.ase → export/**/*.png (headless).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
OUT="$ROOT/export"
CLI="$ROOT/scripts/aseprite-cli.sh"

mkdir -p "$OUT"
shopt -s nullglob globstar
mapfile -t files < <(find "$SRC" \( -name '*.aseprite' -o -name '*.ase' \) -type f | sort -u)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .aseprite/.ase files under src/."
  exit 0
fi

failed=0
for src in "${files[@]}"; do
  rel="${src#"$SRC"/}"
  dest="$OUT/${rel%.*}.png"
  mkdir -p "$(dirname "$dest")"
  echo "Exporting $rel"
  if ! "$CLI" "$src" --save-as "$dest"; then
    echo "Failed: $rel" >&2
    failed=$((failed + 1))
  fi
done

[[ "$failed" -eq 0 ]] || exit 1
