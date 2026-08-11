#!/usr/bin/env bash
# Headless single-file export: .aseprite/.ase → .png
# Usage: ./scripts/export.sh --input <file> --output <file>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLI="$ROOT/scripts/aseprite-cli.sh"
INPUT=""
OUTPUT=""

usage() {
  echo "Usage: $0 --input <file.aseprite|file.ase> --output <file.png>" >&2
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
[[ -f "$INPUT" ]] || {
  echo "Input file not found: $INPUT" >&2
  exit 1
}

case "$INPUT" in
  *.aseprite|*.ase) ;;
  *)
    echo "Input must be .aseprite or .ase: $INPUT" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
echo "Exporting $INPUT -> $OUTPUT"
"$CLI" "$INPUT" --save-as "$OUTPUT"
