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
"$GODOT_BIN" --headless --editor --path . --quit

printf '==> Headless project launch smoke\n'
"$GODOT_BIN" --headless --path . --quit-after 2

printf '==> Deterministic Godot happy-path interaction test\n'
"$GODOT_BIN" --headless --path . --script res://tests/test_happy_path.gd
