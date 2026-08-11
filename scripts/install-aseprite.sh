#!/usr/bin/env bash
# Build and install Aseprite from source (personal use; do not redistribute the binary).
set -euo pipefail

ASEPRITE_REF="${ASEPRITE_REF:-v1.3.18.1}"
SKIA_TAG="${SKIA_TAG:-m124-08a5439a6b}"
DEPS_DIR="${ASEPRITE_DEPS_DIR:-$HOME/deps}"
SRC_DIR="${ASEPRITE_SRC_DIR:-$HOME/src/aseprite}"
OPT_DIR="${ASEPRITE_OPT_DIR:-$HOME/.local/opt/aseprite}"
LINK_BIN="${ASEPRITE_LINK_BIN:-$HOME/.local/bin/aseprite}"

aseprite_ok() {
  local bin="$1"
  [[ -x "$bin" ]] || return 1
  local root
  root="$(dirname "$(readlink -f "$bin" 2>/dev/null || echo "$bin")")"
  [[ -f "$root/data/gui.xml" ]] || return 1
  "$bin" --version >/dev/null 2>&1
}

if aseprite_ok "$LINK_BIN"; then
  echo "Aseprite already installed: $("$LINK_BIN" --version)"
  exit 0
fi
if aseprite_ok "$OPT_DIR/aseprite"; then
  mkdir -p "$(dirname "$LINK_BIN")"
  ln -sfn "$OPT_DIR/aseprite" "$LINK_BIN"
  echo "Aseprite already installed: $("$LINK_BIN" --version)"
  exit 0
fi

for cmd in git curl unzip cmake ninja clang clang++; do
  command -v "$cmd" >/dev/null || {
    echo "Missing $cmd. Run scripts/install-system-deps.sh first." >&2
    exit 1
  }
done

mkdir -p "$DEPS_DIR" "$(dirname "$SRC_DIR")"
SKIA_DIR="$DEPS_DIR/skia"

if [[ ! -f "$SKIA_DIR/out/Release-x64/libskia.a" ]]; then
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/skia.zip" \
    "https://github.com/aseprite/skia/releases/download/${SKIA_TAG}/Skia-Linux-Release-x64.zip"
  rm -rf "$SKIA_DIR"
  mkdir -p "$SKIA_DIR"
  unzip -q "$tmp/skia.zip" -d "$SKIA_DIR"
  if [[ ! -f "$SKIA_DIR/out/Release-x64/libskia.a" ]]; then
    nested="$(find "$SKIA_DIR" -path '*/out/Release-x64/libskia.a' | head -n1)"
    skia_root="$(cd "$(dirname "$nested")/../.." && pwd)"
    rm -rf "$SKIA_DIR"
    mv "$skia_root" "$SKIA_DIR"
  fi
  rm -rf "$tmp"
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
export CC=clang CXX=clang++
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

rm -rf "$OPT_DIR"
mkdir -p "$OPT_DIR" "$(dirname "$LINK_BIN")"
cp -a "$SRC_DIR/build/bin/aseprite" "$OPT_DIR/aseprite"
cp -a "$SRC_DIR/build/bin/data" "$OPT_DIR/data"
cp -a "$SRC_DIR/build/bin/icudtl.dat" "$OPT_DIR/icudtl.dat"
ln -sfn "$OPT_DIR/aseprite" "$LINK_BIN"
export PATH="$(dirname "$LINK_BIN"):$PATH"
"$LINK_BIN" --version
