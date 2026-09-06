# Family Monster Quest

A parent-guided, child-facing monster-collecting RPG where real-world tasks unlock story events, exploration, and creature encounters.

## MVP

The first vertical slice proves one loop:

1. A parent creates or confirms a real-world task.
2. The child receives an in-game exploration event.
3. The child explores one small area.
4. A creature encounter is triggered.
5. The creature can be captured and added to the collection.

The MVP intentionally focuses on **explore → encounter → collect**, not combat.

## Product principles

- The child experience should feel like an RPG, not a todo list.
- Real-world actions change the game world; rewards are not simple point-for-chore trades.
- Parent interaction should stay lightweight and controllable.
- No paid gacha, dark patterns, or punishment loops.
- Start with a small playable vertical slice and validate with real child feedback before expanding.

## Planned stack

- Godot 4
- GDScript
- Blender for 3D asset adaptation
- glTF / GLB asset pipeline
- Local-first save data for the first prototype
- GitHub Actions for automated validation

## Current milestone

Build a local playable prototype with:

- one small map
- one controllable child character
- parent/child mode switch
- three task types
- one exploration event
- five original creatures
- one capture flow
- creature collection / index
- local save

See `AGENTS.md` and GitHub Issues for the executable development contract and backlog.

## Canonical product brief

The product intent and design rationale are maintained in the corresponding Notion project page. Repository docs should stay implementation-focused and should not diverge from that product brief.
