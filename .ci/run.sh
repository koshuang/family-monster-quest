#!/usr/bin/env bash
set -euo pipefail

printf '==> Family Monster Quest CI contract\n'
python3 tests/validate_project.py
