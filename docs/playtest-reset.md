# Safe Playtest Reset

The first child-facing acceptance test needs to be repeatable without deleting files manually.

## Intended behavior

- Reset is available only from authenticated Parent mode.
- A parent sets a local 4-digit PIN before handing the prototype to a child.
- Once a PIN exists, app restart defaults to Child mode; returning to Parent mode requires the PIN.
- The raw PIN is never stored; only a one-way hash is persisted in a separate local parent-gate file.
- Reset is deliberately two-step to avoid accidental loss: first press arms reset; second press confirms.
- Confirmation clears task/event state and creature collection, then returns the prototype to the known initial state.
- Parent authentication survives a demo-progress reset because it is stored separately from playtest progress.
- If the progress file cannot be removed, the reset stops and reports failure instead of clearing only in-memory state.
- Child mode never exposes reset controls.

## Acceptance criteria

- Parent can reset a completed demo without developer intervention.
- Child mode cannot reach Parent mode or reset without the parent PIN.
- A single accidental reset press does not delete progress.
- After confirmation the persisted playtest progress and in-memory progress are both reset.
- Reset failure does not produce a false success state.
- Deterministic Godot coverage verifies PIN setup/unlock, restart behavior, reset confirmation, and state clearing.
- Existing task mapping, world-cue, collection, persistence, and protected-IP tests stay green.

## Security boundary

This PIN is a local family-device gate for the MVP, not a high-security credential system. It is intended to prevent casual child access to Parent mode and destructive controls. Cloud accounts, remote recovery, stronger credential storage, and production-grade authentication remain outside this prototype.
