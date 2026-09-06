from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    ROOT / "project.godot",
    ROOT / "scenes" / "main.tscn",
    ROOT / "scripts" / "main.gd",
    ROOT / "README.md",
    ROOT / "AGENTS.md",
]

for path in required_files:
    assert path.exists(), f"missing required file: {path.relative_to(ROOT)}"

project = (ROOT / "project.godot").read_text(encoding="utf-8")
scene = (ROOT / "scenes" / "main.tscn").read_text(encoding="utf-8")
script = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")

assert 'config/name="Family Monster Quest"' in project
assert 'run/main_scene="res://scenes/main.tscn"' in project
assert 'res://scripts/main.gd' in scene

for expected in [
    "Confirm task completion",
    "Switch Parent / Child Mode",
    "Capture Cloudlet",
    "Creature collection",
]:
    assert expected in script, f"prototype happy-path marker missing: {expected}"

for forbidden in ["pokemon", "pikachu", "pokeball"]:
    assert forbidden not in script.lower(), f"protected-brand placeholder found: {forbidden}"

print("Family Monster Quest project structure validation passed.")
