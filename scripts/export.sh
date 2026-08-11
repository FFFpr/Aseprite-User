#!/usr/bin/env bash
# Headless export: .aseprite/.ase → .png
# Usage: ./scripts/export.sh --input <path> --output <path>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLI="$ROOT/scripts/aseprite-cli.sh"
INPUT=""
OUTPUT=""

usage() {
  echo "Usage: $0 --input <file-or-dir> --output <file-or-dir>" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      [[ $# -ge 2 ]] || usage
      INPUT="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || usage
      OUTPUT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

[[ -n "$INPUT" && -n "$OUTPUT" ]] || usage
[[ -e "$INPUT" ]] || {
  echo "Input not found: $INPUT" >&2
  exit 1
}

export_one() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  echo "Exporting $src -> $dest"
  "$CLI" "$src" --save-as "$dest"
}

if [[ -f "$INPUT" ]]; then
  case "$INPUT" in
    *.aseprite|*.ase) ;;
    *)
      echo "Input file must be .aseprite or .ase: $INPUT" >&2
      exit 1
      ;;
  esac
  if [[ -d "$OUTPUT" || "$OUTPUT" == */ ]]; then
    base="$(basename "$INPUT")"
    dest="${OUTPUT%/}/${base%.*}.png"
  else
    dest="$OUTPUT"
  fi
  export_one "$INPUT" "$dest"
  exit 0
fi

if [[ ! -d "$INPUT" ]]; then
  echo "Input must be a file or directory: $INPUT" >&2
  exit 1
fi

mkdir -p "$OUTPUT"
mapfile -t files < <(find "$INPUT" \( -name '*.aseprite' -o -name '*.ase' \) -type f | sort -u)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .aseprite/.ase files under $INPUT."
  exit 0
fi

failed=0
input_abs="$(cd "$INPUT" && pwd)"
for src in "${files[@]}"; do
  src_abs="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
  rel="${src_abs#"$input_abs"/}"
  dest="$OUTPUT/${rel%.*}.png"
  if ! export_one "$src" "$dest"; then
    failed=$((failed + 1))
  fi
done

[[ "$failed" -eq 0 ]] || exit 1
