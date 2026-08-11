#!/usr/bin/env bash
# Ubuntu/Debian packages for building and running Aseprite headless.
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=()
elif command -v sudo >/dev/null 2>&1; then
  SUDO=(sudo)
else
  echo "Need root or sudo to install system packages." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
"${SUDO[@]}" apt-get update -qq
"${SUDO[@]}" apt-get install -y --no-install-recommends \
  git curl ca-certificates unzip \
  g++ clang cmake ninja-build libstdc++-14-dev \
  libx11-dev libxcursor-dev libxi-dev libxrandr-dev \
  libgl1-mesa-dev libfontconfig1-dev \
  xvfb
