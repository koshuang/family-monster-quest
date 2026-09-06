#!/usr/bin/env bash
set -euo pipefail

printf '==> Family Monster Quest CI contract\n'
python3 tests/validate_project.py

if command -v godot >/dev/null 2>&1; then
  GODOT_BIN="$(command -v godot)"
else
  GODOT_BIN="$(bash .ci/setup-godot.sh)"
fi

printf '==> Godot version\n'
"$GODOT_BIN" --version

printf '==> Headless editor import / script parse\n'
timeout 45s "$GODOT_BIN" --headless --editor --path . --quit

printf '==> Headless project launch smoke\n'
timeout 15s "$GODOT_BIN" --headless --path . --quit-after 2

printf '==> Deterministic task-to-story mapping test\n'
timeout 15s "$GODOT_BIN" --headless --path . --script res://tests/test_content_mapping.gd

printf '==> Creature data and collection semantics test\n'
timeout 15s "$GODOT_BIN" --headless --path . --script res://tests/test_creatures.gd

printf '==> Deterministic Godot happy-path interaction test\n'
timeout 15s "$GODOT_BIN" --headless --path . --script res://tests/test_happy_path.gd
