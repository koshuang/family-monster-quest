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

Use DDD and Clean Architecture as the default design discipline, but keep it lightweight enough for the MVP.

### Domain-first rule

Before changing JSON, save schemas, Godot node structure, or persistence formats for a new capability:

1. name the domain concept in ubiquitous language;
2. define the domain state/invariants;
3. define the interaction or use case and its inputs/outcomes;
4. define the domain transition/events that matter;
5. only then choose serialization, storage, scene/UI wiring, or infrastructure details.

Data formats are adapters. They must represent the domain model; they must not define it.

### Layer responsibilities

- **Domain**: entities, value objects, policies/rules, invariants, domain transitions. No Godot UI, file I/O, JSON, or infrastructure dependencies.
- **Application**: use cases that orchestrate domain objects through ports. It may depend on Domain, but not on concrete UI/storage implementations.
- **Interface / Presentation**: Godot scenes, Controls, input handling, view models/presenters. Translate user intent into application use cases and render outcomes.
- **Infrastructure**: JSON/content loading, local save files, platform APIs, future cloud adapters. Implements ports defined inward.

Dependency direction must point inward: Infrastructure/Presentation → Application → Domain.

### Modeling guidance

- Model behavior before tables/files. Prefer explicit methods/use cases such as `confirm_task_completion`, `unlock_story_event`, `enter_location`, `befriend_creature`, `reset_playtest_progress` over UI-driven state mutation.
- Keep aggregate boundaries small and explicit. Current likely boundaries are `AdventureProgress` and `CreatureCollection`; do not create one giant game-state object by default.
- Treat task definitions, story definitions, locations, and creature catalog entries as reference content. Runtime progress should refer to stable IDs and enforce domain invariants independently of JSON shape.
- Domain rules must be testable without rendering a Godot scene or touching disk whenever practical.
- Persistence/content adapters should convert between domain objects and external representations through explicit mapping.
- Do not introduce repositories/interfaces solely for ceremony. Add a port when the application layer genuinely needs to depend on a capability whose implementation should remain replaceable or testable.
- Avoid speculative frameworks and abstractions before two concrete use cases require them.
- Do not introduce microservices, CQRS, event sourcing, a DI framework, or a generic event bus without a concrete need.

See `docs/domain-model.md` for the current ubiquitous language, interaction model, and candidate boundaries.

## CI contract

All provider-neutral verification must be reachable through:

```bash
bash .ci/run.sh
```

GitHub Actions is the canonical CI provider. CircleCI is an opt-in fallback/overflow provider. Do not duplicate test/build command lists in both provider configs; add repository-specific gates to `.ci/run.sh` or scripts it invokes.

Before merging, run:

```bash
bash .ci/run.sh
```

When Godot is available locally, also run the project and verify the first happy path interactively.

See `docs/ci-strategy.md` for provider roles and CI portability rules.

## Human decision gates

Stop and ask before:

- changing the target user or core product loop;
- adding monetization;
- introducing paid services or meaningful recurring cost;
- adding credentials or production infrastructure;
- changing repository visibility or licensing strategy;
- introducing collection/processing of sensitive child data;
- using assets with unclear licensing.
