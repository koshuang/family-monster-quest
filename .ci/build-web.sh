#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.6.3-stable}"
TEMPLATE_ASSET="Godot_v${GODOT_VERSION}_export_templates.tpz"
TEMPLATE_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/${TEMPLATE_ASSET}"
TEMPLATE_SHA256="3fbe2c0e2dec9d537ab9ec97bcf8da91dcf23357fc51f67092dd068d839290a8"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/family-monster-quest/export-templates/${GODOT_VERSION}"
TPZ_PATH="${CACHE_ROOT}/${TEMPLATE_ASSET}"
TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/4.6.3.stable"

mkdir -p "$CACHE_ROOT" "$TEMPLATE_DIR" build/web

if [ ! -f "$TPZ_PATH" ]; then
  tmp_tpz="$(mktemp "${TPZ_PATH}.tmp.XXXXXX")"
  trap 'rm -f "$tmp_tpz"' EXIT
  curl -fL --retry 3 --retry-delay 5 "$TEMPLATE_URL" -o "$tmp_tpz"
  printf '%s  %s\n' "$TEMPLATE_SHA256" "$tmp_tpz" | sha256sum -c -
  mv "$tmp_tpz" "$TPZ_PATH"
  trap - EXIT
fi

printf '%s  %s\n' "$TEMPLATE_SHA256" "$TPZ_PATH" | sha256sum -c -

if [ ! -f "$TEMPLATE_DIR/web_release.zip" ]; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  unzip -q "$TPZ_PATH" -d "$tmp_dir"
  cp -a "$tmp_dir/templates/." "$TEMPLATE_DIR/"
fi

GODOT_BIN="$(bash .ci/setup-godot.sh)"
"$GODOT_BIN" --headless --path . --export-release Web build/web/index.html

test -s build/web/index.html
find build/web -maxdepth 1 -type f -printf '%f\n' | sort
