# AGENTS.md

This file is the repository-level execution contract for AI coding agents.

## Mission

Build the smallest playable version of Family Monster Quest that can validate whether a child looks forward to returning to the game after a real-world task changes the game world.

The canonical product brief lives in Notion. Keep this repository focused on implementation, verification, and delivery state.

## Current MVP

The first vertical slice is:

`parent confirms task → child sees world event → child explores → creature encounter → capture → creature appears in collection`

The MVP does not require combat, online accounts, cloud sync, monetization, procedural worlds, or a large content catalog.

## Technology baseline

- Godot 4.x
- GDScript
- 3D assets via glTF / GLB when added
- Blender only for asset adaptation/export work
- Local-first save state for prototype phase

Prefer built-in Godot capabilities before adding plugins or dependencies.

## Product guardrails

- Child mode must feel like an adventure game, not a KPI dashboard or todo app.
- Parent actions should be low-friction and reversible.
- Do not add paid gacha, dark patterns, loss-aversion pressure, punishment for broken streaks, or manipulative retention mechanics.
- Do not use copyrighted Pokémon characters, names, art, sounds, or other protected assets. Creatures and world content must be original or appropriately licensed.
- Do not add external services, paid APIs, credentials, analytics SDKs, or cloud infrastructure without an explicit decision.

## Execution loop

For every work session:

1. Inspect the current repository state, open issues, and this file.
2. Choose one bounded next step that advances the current milestone.
3. Implement it completely.
4. Run the relevant checks.
5. Fix failures or leave concrete blocker evidence.
6. Update the issue/PR state and any documentation that materially changed.
7. Report evidence, not just activity.

## Definition of Done

A task is not done because code exists. It is done only when:

- acceptance criteria are satisfied;
- relevant automated checks pass;
- the happy path is manually or headlessly smoke-tested when feasible;
- known limitations are documented;
- there is a clear next action if the milestone is not complete.

## Architecture rules

- Keep gameplay state separate from presentation where practical.
- Prefer small scenes and scripts with explicit responsibilities.
- Keep prototype data deterministic and local until cloud sync becomes necessary.
- Treat creature definitions, task definitions, and story events as data rather than hard-coding them into UI scripts once the first placeholder loop works.
- Avoid speculative frameworks and abstractions before two concrete use cases require them.

## Validation

At minimum before merging:

```bash
python3 tests/validate_project.py
```

When Godot is available locally, also run the project and verify the first happy path interactively.

## Human decision gates

Stop and ask before:

- changing the target user or core product loop;
- adding monetization;
- introducing paid services or meaningful recurring cost;
- adding credentials or production infrastructure;
- changing repository visibility or licensing strategy;
- introducing collection/processing of sensitive child data;
- using assets with unclear licensing.
