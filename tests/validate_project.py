import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    ROOT / "project.godot",
    ROOT / "scenes" / "main.tscn",
    ROOT / "scripts" / "main.gd",
    ROOT / "scripts" / "content_catalog.gd",
    ROOT / "scripts" / "collection_state.gd",
    ROOT / "data" / "content.json",
    ROOT / "README.md",
    ROOT / "AGENTS.md",
]

for path in required_files:
    assert path.exists(), f"missing required file: {path.relative_to(ROOT)}"

project = (ROOT / "project.godot").read_text(encoding="utf-8")
scene = (ROOT / "scenes" / "main.tscn").read_text(encoding="utf-8")
script = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
content_text = (ROOT / "data" / "content.json").read_text(encoding="utf-8")
content = json.loads(content_text)

assert 'config/name="Family Monster Quest"' in project
assert 'run/main_scene="res://scenes/main.tscn"' in project
assert 'res://scripts/main.gd' in scene

for expected in [
    "Confirm task completion",
    "Switch Parent / Child Mode",
    "Creature collection",
    "CollectionState",
    "ContentCatalog",
]:
    assert expected in script, f"prototype contract marker missing: {expected}"

assert "read_20" in content.get("tasks", {})
assert "whispering_forest_light" in content.get("story_events", {})
assert len(content.get("creatures", {})) == 5

source_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in required_files
    if path.suffix in {".gd", ".json", ".md"}
)
for forbidden in ["pokemon", "pikachu", "pokeball"]:
    assert forbidden not in source_text.lower(), f"protected-brand placeholder found: {forbidden}"

print("Family Monster Quest project structure validation passed.")
