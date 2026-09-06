#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.6.3-stable}"
GODOT_ASSET="Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/${GODOT_ASSET}"
GODOT_SHA256="d0bc2113065e481c9c2c2b2c37daa4e8be3fe9e27f0ab9ab0b6096e9a37907f3"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/family-monster-quest/godot/${GODOT_VERSION}"
ZIP_PATH="${CACHE_ROOT}/${GODOT_ASSET}"
BIN_PATH="${CACHE_ROOT}/godot"

mkdir -p "$CACHE_ROOT"

if [ -x "$BIN_PATH" ]; then
  printf '%s\n' "$BIN_PATH"
  exit 0
fi

if [ ! -f "$ZIP_PATH" ]; then
  curl -fsSL "$GODOT_URL" -o "$ZIP_PATH"
fi

printf '%s  %s\n' "$GODOT_SHA256" "$ZIP_PATH" | sha256sum -c - >/dev/null

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
unzip -q "$ZIP_PATH" -d "$tmp_dir"
source_bin="$(find "$tmp_dir" -maxdepth 1 -type f -name 'Godot_*_linux.x86_64' -print -quit)"
if [ -z "$source_bin" ]; then
  echo "Godot executable not found after extraction" >&2
  exit 1
fi

install -m 0755 "$source_bin" "$BIN_PATH"
printf '%s\n' "$BIN_PATH"
