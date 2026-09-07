# Family Monster Quest — Domain Model

This document defines the current domain language and interaction model before storage/UI formats. It is intentionally smaller than a production architecture spec: the goal is to keep future development domain-led without over-engineering the playtest MVP.

## Core domain hypothesis

A real-world action confirmed by a parent changes the child's game world in a way that creates curiosity and invites exploration.

The core causal chain is:

`Real-world action → confirmed completion → world change → exploration opportunity → creature encounter → companionship/collection`

The game should preserve this causal relationship in the domain model. UI screens, JSON files, save files, and future APIs are representations of this model, not the model itself.

## Ubiquitous language

- **Task**: a parent-defined or template-defined real-world activity the child can complete.
- **Task Completion**: a fact that a Task was completed and accepted by the parent.
- **World Change**: a meaningful change caused by accepted real-world progress, such as a location becoming interesting or an event becoming available.
- **Story Event**: a domain opportunity unlocked by prior progress and associated with a location/context.
- **Location**: a place the child may choose to explore.
- **Encounter**: the moment an unlocked Story Event reveals a Creature.
- **Creature**: an original collectible companion definition.
- **Companion / Befriended Creature**: a Creature that the child has successfully added to their collection.
- **Creature Collection**: the child's set of befriended creatures.
- **Adventure Progress**: current runtime progress through tasks, unlocked events, consumed encounters, and current location.
- **Parent Gate**: local authorization boundary protecting Parent-only operations such as confirmation/reset.
- **Playtest Reset**: an administrative operation that clears demo progress but does not redefine domain rules.

## Candidate bounded contexts / subdomains

For the current MVP, keep these conceptual boundaries without turning them into services:

### Habit / Task Context
Owns the meaning of Task and accepted Task Completion.

Current rule:
- Only a parent-authorized action may accept a completion.
- Accepted completion is a domain fact; it should not directly mutate UI or write JSON.

### Adventure Context
Owns Adventure Progress, locations, unlocked Story Events, encounter availability, and consumed events.

Current rule:
- A Task Completion may unlock one or more Story Events according to domain/content rules.
- The child must choose to enter the relevant Location before the encounter becomes active.
- Consumed one-time encounters must not replay accidentally.

### Collection Context
Owns the Creature Collection and companionship rules.

Current rules:
- A creature can be befriended only from a valid active encounter.
- Befriending the same creature twice must not duplicate the collection entry.
- Collection membership is domain state, independent of how it is displayed or serialized.

### Parent Administration Context
Owns authorization for Parent-only commands and playtest administration.

Current rules:
- Child mode cannot execute Parent-only commands without successful parent authorization.
- Reset confirmation is not authentication.
- A failed persistence reset must not be reported as a successful domain reset.

## Candidate domain objects

These are design targets, not a requirement to create one class per noun immediately.

### Task
Reference/domain definition.

Possible fields:
- `TaskId`
- title / description
- category
- completion criteria

Behavior belongs outside persistence shape. A task should not know about JSON or Godot Controls.

### TaskCompletion
A domain fact/value describing accepted completion.

Possible fields:
- `TaskId`
- accepted timestamp (optional for MVP)

### StoryEvent
Reference/domain definition describing the condition and consequence of a world event.

Possible fields:
- `StoryEventId`
- triggering task/rule
- `LocationId`
- `CreatureId`
- one-time/repeatability policy

### AdventureProgress (aggregate candidate)
Owns invariants around world progression.

Possible state:
- accepted task completions
- unlocked story events
- consumed story events
- current location

Candidate behavior:
- `confirm_task_completion(task_id)`
- `unlock_story_event(event_id)`
- `enter_location(location_id)`
- `start_encounter()` / `available_encounter()`
- `consume_encounter(event_id)`

Important invariant:
A location visit alone does not manufacture an encounter. The event must first have been unlocked by valid progress.

### CreatureCollection (aggregate candidate)
Owns companionship membership.

Candidate behavior:
- `befriend(creature_id)`
- `has(creature_id)`
- `count()`

Important invariant:
Collection membership is duplicate-safe.

### ParentGate
A policy/application boundary for protected commands. The PIN storage mechanism belongs to Infrastructure.

Candidate behavior exposed to the application layer:
- `is_parent_authorized()`
- `authorize(pin)`

The raw PIN/hash/file format is not part of the game domain.

## Current use cases

Use cases express interactions between models. They should be understandable without knowing Godot node names or JSON schemas.

### 1. ConfirmTaskCompletion
Actor: Parent

Preconditions:
- Parent is authorized.
- Task exists and can be completed.

Flow:
1. Accept Task Completion.
2. Determine domain consequences for this task.
3. Unlock the matching Story Event/world change.
4. Persist updated progress through a port.

Outcome:
- The child-facing world contains a new observable exploration opportunity.

### 2. EnterLocation
Actor: Child

Preconditions:
- Child mode is active.
- Location exists.

Flow:
1. Move Adventure Progress to the chosen Location.
2. Check whether an unlocked, unconsumed Story Event applies there.

Outcome:
- Either no encounter is available, or a valid encounter becomes visible.

### 3. BefriendCreature
Actor: Child

Preconditions:
- A valid encounter is active.
- Encounter has not already been consumed.

Flow:
1. Add Creature to Creature Collection with duplicate-safe semantics.
2. Consume/resolve the Story Event encounter.
3. Persist Adventure Progress and Collection state.

Outcome:
- Creature appears in the collection and the encounter no longer remains pending.

### 4. UnlockParentMode
Actor: Parent

Preconditions:
- Parent Gate has been configured.

Flow:
1. Validate parent credential through a port/policy.
2. On success, permit Parent-only commands.

Outcome:
- Parent operations become available.

### 5. ResetPlaytestProgress
Actor: Parent

Preconditions:
- Parent is authorized.
- Reset has been explicitly confirmed as a separate safety step.

Flow:
1. Ask Progress Repository/Store to clear persisted playtest progress.
2. If persistence clearing fails, stop and retain current in-memory progress.
3. If successful, create known initial Adventure Progress and Collection state.

Outcome:
- Demo progress is reset without weakening Parent Gate authorization.

## Dependency direction

```text
Godot UI / Input
      |
      v
Application Use Cases
      |
      v
Domain Model

Infrastructure adapters (JSON, save files, future cloud)
      ^
      |
Application ports/interfaces
```

Rules:
- Domain imports nothing from Presentation or Infrastructure.
- Application orchestrates Domain and depends only on inward contracts/ports.
- Godot UI calls application use cases; it should not be the owner of game invariants.
- File/JSON code implements persistence/content ports and maps external data to domain values.

## Data comes after behavior

For a new feature, do not begin with “what JSON field/table do we add?”. Begin with:

1. What new domain concept exists?
2. What invariant must always remain true?
3. What command/use case changes the domain?
4. What outcome/domain event should result?
5. What state must be durable?
6. Only then: what is the smallest external representation needed?

Example — adding a long-term reading streak narrative:

Wrong starting point:
- Add `streak_count`, `day_3_reward`, `day_7_reward` fields to JSON.

Preferred starting point:
- Define what `ReadingProgress` or milestone progression means.
- Define how accepted completions advance it.
- Define milestone invariants and what world event becomes available.
- Then map that state to a save representation.

## Migration path from the current prototype

Do not rewrite everything before Issue #5 playtest evidence. Refactor opportunistically as behavior changes are required.

Recommended sequence after playtest evidence justifies further development:

1. Extract `AdventureProgress` state transitions from `scripts/main.gd` into domain code with pure tests.
2. Keep `CreatureCollection` as a domain object and strengthen invariants as needed.
3. Introduce application use cases for confirm-task / enter-location / befriend-creature.
4. Make Godot scene code a thin presenter/input adapter.
5. Introduce explicit progress/content ports only where concrete infrastructure coupling exists.
6. Move JSON/save mapping behind adapters without changing domain APIs.

This sequence preserves working behavior while steadily improving boundaries.

## Architecture decision test

Before adding an abstraction, ask:

- Does this represent a real domain concept or invariant?
- Does it decouple a use case from an external mechanism we genuinely need to replace/test?
- Does it make behavior easier to test without Godot UI/file I/O?

If the answer is no, keep the design simpler.
