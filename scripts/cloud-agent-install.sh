#!/usr/bin/env bash
# Cloud Agent install: ensure Aseprite is available and repo layout exists.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p src export
export PATH="$HOME/.local/bin:$PATH"

aseprite_ok() {
  command -v aseprite >/dev/null 2>&1 && aseprite --version >/dev/null 2>&1
}

if ! aseprite_ok; then
  # Snapshot/base image may already have build tools; install only if compile is needed.
  if ! command -v ninja >/dev/null 2>&1 || ! command -v cmake >/dev/null 2>&1; then
    "$ROOT/scripts/install-system-deps.sh"
  fi
  "$ROOT/scripts/install-aseprite.sh"
  export PATH="$HOME/.local/bin:$PATH"
fi

aseprite --version
echo "Cloud Agent install complete."
