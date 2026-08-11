#!/usr/bin/env bash
# Cloud Agent install: ensure headless Aseprite CLI is available.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p src export
export PATH="$HOME/.local/bin:$PATH"
export ASEPRITE_HEADLESS="${ASEPRITE_HEADLESS:-1}"

# Hydrate Git LFS art binaries when pointers are checked out.
if command -v git-lfs >/dev/null 2>&1 && [[ -d .git ]]; then
  git lfs install --local >/dev/null 2>&1 || true
  git lfs pull || true
fi

aseprite_ok() {
  command -v aseprite >/dev/null 2>&1 && aseprite --version >/dev/null 2>&1
}

if ! aseprite_ok; then
  if ! command -v ninja >/dev/null 2>&1 || ! command -v cmake >/dev/null 2>&1 || ! command -v xvfb-run >/dev/null 2>&1; then
    "$ROOT/scripts/install-system-deps.sh"
  fi
  "$ROOT/scripts/install-aseprite.sh"
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v xvfb-run >/dev/null 2>&1; then
  "$ROOT/scripts/install-system-deps.sh"
fi

aseprite --version

# Smoke-test headless batch (no GUI / no required DISPLAY).
tmp="$(mktemp /tmp/aseprite-headless-XXXXXX.png)"
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT

if [[ -f src/examples/demo.aseprite ]]; then
  env -u DISPLAY -u WAYLAND_DISPLAY ASEPRITE_FORCE_XVFB=1 \
    "$ROOT/scripts/aseprite-cli.sh" src/examples/demo.aseprite --save-as "$tmp"
  test -s "$tmp"
  echo "Headless export smoke test OK."
else
  env -u DISPLAY -u WAYLAND_DISPLAY ASEPRITE_FORCE_XVFB=1 \
    "$ROOT/scripts/aseprite-cli.sh" --help >/dev/null
  echo "Headless CLI smoke test OK (no demo sprite)."
fi

echo "Cloud Agent install complete."
