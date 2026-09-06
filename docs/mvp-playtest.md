# First child-facing MVP playtest

## Purpose

Validate the product hypothesis, not the implementation: after a parent-confirmed real-world task changes the game state, does the child understand that something happened, enjoy discovering the creature, and show interest in returning?

Keep the session to about 5–10 minutes. Avoid explaining the internal reward system unless the child is blocked; confusion is evidence.

## Before the session

- Start from a known clean state using the development reset path.
- Use the normal game UI rather than debug/test scripts.
- Parent and child should use the prototype as intended: parent confirms the task, then hands the experience to the child.
- Do not promise a reward beyond what the prototype actually contains.

## Test path

1. Tell the child only that something may have changed in the adventure after the real-world task was completed.
2. In parent mode, confirm the sample task. Time this step; target is under one minute.
3. Switch to child mode and hand control to the child.
4. Observe whether the child notices the forest event / creature encounter without being told exactly what button to press.
5. Let the child capture the creature and inspect the collection state.
6. Stop after the first completed loop. Do not manufacture enthusiasm by immediately promising more content.

## What to observe

Record behavior rather than interpreting it too early:

- Did the child understand that the completed real-world task caused a game-world change?
- Where did the child hesitate or ask what to do?
- Did the creature encounter produce visible interest, delight, or indifference?
- Could the child complete the capture without explanation of internal mechanics?
- Did the child inspect or mention the collection afterward?
- Did the child spontaneously ask to play again, catch another creature, or see what happens next?
- How much prompting did the parent need to provide?
- What technical friction interrupted the experience?

## Evidence template

### Session

- Date/time:
- Child age range:
- Real-world task used:
- Parent confirmation time:
- Total session time:

### Observed path

- What the child did first:
- Points of confusion:
- Moments of visible interest:
- Prompts/help required:
- Technical blockers:

### Interest signal

Choose the strongest observed signal and quote/paraphrase briefly:

- Strong positive: child spontaneously asks to continue / return / find another creature.
- Weak positive: child completes the loop and shows interest, but does not independently ask for more.
- Neutral: child completes it without clear interest or dislike.
- Negative: child disengages, refuses, or finds the loop confusing/uninteresting.

### Decision

- Iterate: the core idea has a signal, but specific friction must be fixed.
- Expand: the loop works with low prompting and there is clear pull for more.
- Stop / rethink: there is no meaningful interest signal after removing obvious usability blockers.

Write the next decision and the smallest evidence-driven product change. Do not add features merely because they are easy to build.

## Important limitation of the current prototype

The current implementation is intentionally a text/button vertical slice, not yet the intended map-based child RPG experience. A negative reaction to presentation alone should not be treated as proof that the underlying real-world-task → world-change → creature-discovery concept is invalid. Record separately whether the child rejected the **core loop** or simply found the **prototype presentation** uninteresting.
