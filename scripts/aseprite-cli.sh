#!/usr/bin/env bash
# Headless-friendly Aseprite CLI wrapper for Linux CI / Cloud Agents / servers.
# Always runs in batch mode (-b). Uses Xvfb when no display is available.
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v aseprite >/dev/null 2>&1; then
  echo "aseprite not found. Run scripts/install-aseprite.sh first." >&2
  exit 1
fi

# Prefer batch / no UI.
args=(-b)
has_batch=0
for a in "$@"; do
  case "$a" in
    -b|--batch) has_batch=1 ;;
  esac
done
if [[ "$has_batch" -eq 1 ]]; then
  args=("$@")
else
  args=(-b "$@")
fi

need_xvfb=0
if [[ "${ASEPRITE_FORCE_XVFB:-0}" == "1" ]]; then
  need_xvfb=1
elif [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  need_xvfb=1
elif [[ "${ASEPRITE_HEADLESS:-1}" == "1" && -z "${DISPLAY:-}" ]]; then
  need_xvfb=1
fi

# Avoid accidental GUI init in headless environments.
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-dummy}"

if [[ "$need_xvfb" -eq 1 ]]; then
  if command -v xvfb-run >/dev/null 2>&1; then
    exec xvfb-run -a -s "-screen 0 1280x720x24" aseprite "${args[@]}"
  fi
  # Fall through: many batch ops work without a display on this build.
fi

exec aseprite "${args[@]}"
