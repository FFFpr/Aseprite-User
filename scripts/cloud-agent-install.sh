#!/usr/bin/env bash
# Cloud Agent install (.cursor/environment.json).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p src export
export PATH="$HOME/.local/bin:$PATH"

if command -v git-lfs >/dev/null && [[ -d .git ]]; then
  git lfs install --local >/dev/null 2>&1 || true
  git lfs pull || true
fi

aseprite_ready() {
  command -v aseprite >/dev/null && aseprite --version >/dev/null 2>&1
}

if ! aseprite_ready; then
  "$ROOT/scripts/install-system-deps.sh"
  "$ROOT/scripts/install-aseprite.sh"
  export PATH="$HOME/.local/bin:$PATH"
elif ! command -v xvfb-run >/dev/null; then
  "$ROOT/scripts/install-system-deps.sh"
fi

aseprite --version
