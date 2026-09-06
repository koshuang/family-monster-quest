# Safe Playtest Reset

The first child-facing acceptance test needs to be repeatable without deleting files manually.

## Intended behavior

- Reset is available only from Parent mode.
- It is deliberately two-step to avoid accidental loss: first press arms reset; second press confirms.
- Confirmation clears task/event state and creature collection, then returns the prototype to the known initial state.
- Missing/corrupt save behavior continues to fall back safely.
- Child mode never exposes reset controls.

## Acceptance criteria

- Parent can reset a completed demo without developer intervention.
- A single accidental press does not delete progress.
- After confirmation the save file and in-memory state are both reset.
- Deterministic Godot coverage verifies the flow.
- Existing task mapping, world-cue, collection, persistence, and protected-IP tests stay green.
