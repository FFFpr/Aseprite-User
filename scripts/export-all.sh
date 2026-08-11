#!/usr/bin/env bash
# Export every .aseprite / .ase file under src/ into export/.
# Headless by default (Linux servers / Cloud Agents / CI).
# During development, game repos can read export/ directly (no Release required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
OUT="$ROOT/export"
CLI="$ROOT/scripts/aseprite-cli.sh"

# Default to headless unless the caller opts out.
export ASEPRITE_HEADLESS="${ASEPRITE_HEADLESS:-1}"

mkdir -p "$OUT"

shopt -s nullglob globstar
files=("$SRC"/**/*.{aseprite,ase} "$SRC"/*.{aseprite,ase})
# Deduplicate
mapfile -t files < <(printf '%s\n' "${files[@]}" | awk 'NF && !seen[$0]++')

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .aseprite/.ase files under src/. Nothing to export."
  exit 0
fi

count=0
failed=0
for src in "${files[@]}"; do
  [[ -f "$src" ]] || continue
  rel="${src#"$SRC"/}"
  dest_dir="$OUT/$(dirname "$rel")"
  base="$(basename "$rel")"
  base_noext="${base%.*}"
  mkdir -p "$dest_dir"
  dest="$dest_dir/${base_noext}.png"
  echo "Exporting $rel -> ${dest#"$ROOT"/}"
  if "$CLI" "$src" --save-as "$dest"; then
    count=$((count + 1))
  else
    echo "Failed: $rel" >&2
    failed=$((failed + 1))
  fi
done

echo "Exported $count file(s) into export/."
if [[ "$failed" -gt 0 ]]; then
  echo "$failed file(s) failed to export." >&2
  exit 1
fi
