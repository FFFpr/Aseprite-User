#!/usr/bin/env bash
# Headless Aseprite CLI for Linux (batch mode; Xvfb when no display).
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-dummy}"

if ! command -v aseprite >/dev/null; then
  echo "aseprite not found. Run scripts/install-aseprite.sh first." >&2
  exit 1
fi

args=(-b "$@")
for a in "$@"; do
  case "$a" in -b|--batch) args=("$@"); break ;; esac
done

if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]] && command -v xvfb-run >/dev/null; then
  exec xvfb-run -a -s "-screen 0 1280x720x24" aseprite "${args[@]}"
fi
exec aseprite "${args[@]}"
