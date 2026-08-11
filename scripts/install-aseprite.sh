#!/usr/bin/env bash
# Idempotent Aseprite install for local and Cloud Agent environments.
# Builds from source for personal use (Aseprite EULA — do not redistribute binaries).
set -euo pipefail

ASEPRITE_REF="${ASEPRITE_REF:-v1.3.18.1}"
SKIA_TAG="${SKIA_TAG:-m124-08a5439a6b}"
DEPS_DIR="${ASEPRITE_DEPS_DIR:-$HOME/deps}"
SRC_DIR="${ASEPRITE_SRC_DIR:-$HOME/src/aseprite}"
# Binary must sit next to data/ and icudtl.dat (Aseprite resource layout).
OPT_DIR="${ASEPRITE_OPT_DIR:-$HOME/.local/opt/aseprite}"
LINK_BIN="${ASEPRITE_LINK_BIN:-$HOME/.local/bin/aseprite}"

aseprite_works() {
  local candidate="$1"
  [[ -x "$candidate" ]] || return 1
  # Resource files must be beside the real binary (not only a symlink target name).
  local real
  real="$(readlink -f "$candidate" 2>/dev/null || echo "$candidate")"
  local root
  root="$(dirname "$real")"
  [[ -f "$root/data/gui.xml" ]] || return 1
  "$candidate" --version >/dev/null 2>&1
}

if aseprite_works "$LINK_BIN"; then
  echo "Aseprite already installed: $("$LINK_BIN" --version 2>/dev/null || true)"
  exit 0
fi

if aseprite_works "$OPT_DIR/aseprite"; then
  mkdir -p "$(dirname "$LINK_BIN")"
  ln -sfn "$OPT_DIR/aseprite" "$LINK_BIN"
  echo "Aseprite already installed: $("$LINK_BIN" --version 2>/dev/null || true)"
  exit 0
fi

if command -v aseprite >/dev/null 2>&1 && aseprite_works "$(command -v aseprite)"; then
  echo "Aseprite already installed: $(aseprite --version 2>/dev/null || true)"
  exit 0
fi

echo "Installing Aseprite ${ASEPRITE_REF} (Skia ${SKIA_TAG})..."

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need_cmd git
need_cmd curl
need_cmd unzip
need_cmd cmake
need_cmd ninja
need_cmd clang
need_cmd clang++

# clang + libstdc++ linking needs the matching libstdc++.a (e.g. libstdc++-14-dev on Ubuntu 24.04).
if ! echo 'int main(){return 0;}' | clang++ -x c++ -stdlib=libstdc++ - -o /tmp/aseprite-cxx-check 2>/dev/null; then
  echo "clang++ cannot link with -stdlib=libstdc++. Install libstdc++-14-dev (or matching g++/libstdc++-dev)." >&2
  exit 1
fi
rm -f /tmp/aseprite-cxx-check

mkdir -p "$DEPS_DIR" "$(dirname "$SRC_DIR")"

SKIA_DIR="$DEPS_DIR/skia"
if [[ ! -f "$SKIA_DIR/out/Release-x64/libskia.a" ]]; then
  echo "Downloading Skia ${SKIA_TAG}..."
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/skia.zip" \
    "https://github.com/aseprite/skia/releases/download/${SKIA_TAG}/Skia-Linux-Release-x64.zip"
  rm -rf "$SKIA_DIR"
  mkdir -p "$SKIA_DIR"
  unzip -q "$tmp/skia.zip" -d "$SKIA_DIR"
  # Zip may unpack into a nested folder or flat out/ tree — normalize.
  if [[ ! -f "$SKIA_DIR/out/Release-x64/libskia.a" ]]; then
    nested="$(find "$SKIA_DIR" -path '*/out/Release-x64/libskia.a' | head -n1 || true)"
    if [[ -n "$nested" ]]; then
      skia_root="$(cd "$(dirname "$nested")/../.." && pwd)"
      rm -rf "$SKIA_DIR"
      mv "$skia_root" "$SKIA_DIR"
    fi
  fi
  rm -rf "$tmp"
  test -f "$SKIA_DIR/out/Release-x64/libskia.a"
fi

if [[ ! -d "$SRC_DIR/.git" ]]; then
  rm -rf "$SRC_DIR"
  git clone --recursive --branch "$ASEPRITE_REF" --depth 1 \
    https://github.com/aseprite/aseprite.git "$SRC_DIR"
else
  git -C "$SRC_DIR" fetch --depth 1 origin "refs/tags/${ASEPRITE_REF}:refs/tags/${ASEPRITE_REF}" 2>/dev/null || true
  git -C "$SRC_DIR" checkout "$ASEPRITE_REF"
  git -C "$SRC_DIR" submodule update --init --recursive
fi

mkdir -p "$SRC_DIR/build"
cd "$SRC_DIR/build"

export CC=clang
export CXX=clang++

cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libstdc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libstdc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR="$SKIA_DIR" \
  -DSKIA_LIBRARY_DIR="$SKIA_DIR/out/Release-x64" \
  -DSKIA_LIBRARY="$SKIA_DIR/out/Release-x64/libskia.a" \
  -G Ninja \
  ..

ninja aseprite

mkdir -p "$OPT_DIR" "$(dirname "$LINK_BIN")"
# Keep binary + data/ + icudtl.dat together.
rm -rf "$OPT_DIR"
mkdir -p "$OPT_DIR"
cp -a "$SRC_DIR/build/bin/aseprite" "$OPT_DIR/aseprite"
cp -a "$SRC_DIR/build/bin/data" "$OPT_DIR/data"
cp -a "$SRC_DIR/build/bin/icudtl.dat" "$OPT_DIR/icudtl.dat"
ln -sfn "$OPT_DIR/aseprite" "$LINK_BIN"

export PATH="$(dirname "$LINK_BIN"):$PATH"
"$LINK_BIN" --version
echo "Aseprite installed to $OPT_DIR (linked from $LINK_BIN)."
