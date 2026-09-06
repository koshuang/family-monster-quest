# CI strategy

## Goal

Keep CI behavior portable across providers and cheap to operate while proving the project with the real game engine, not only text-level checks.

The repository defines one provider-neutral verification contract:

```bash
bash .ci/run.sh
```

GitHub Actions and CircleCI are wrappers around that same contract. Provider configuration must not become a second source of truth for test commands.

## Current verification contract

The shared CI entrypoint currently performs these gates in order:

1. deterministic repository/project structure validation;
2. resolve a Godot executable;
3. verify the pinned Godot version;
4. run a headless editor import/script parse;
5. launch the main project headlessly as a runtime smoke test.

CI currently pins the official Godot `4.6.3-stable` Linux x86_64 build. `.ci/setup-godot.sh` downloads it from the official `godotengine/godot-builds` release and checks the expected SHA-256 before installing it into the CI cache location.

This closes an important gap: a green CI result means Godot itself can import, parse, and launch the current project. It does not yet prove the complete interactive parent → child → encounter → capture flow; that remains a separate acceptance gate until a deterministic Godot-level harness covers it.

## Provider roles

### GitHub Actions — canonical CI

GitHub Actions is the default required CI path for pushes to `main` and pull requests.

It should stay small and deterministic. New quality gates should first be added to `.ci/run.sh` or scripts called by it; the GitHub Actions workflow should only handle provider-specific setup.

### CircleCI — fallback / overflow CI

CircleCI is pre-wired but opt-in. The `run_ci` pipeline parameter defaults to `false` so the repository does not pay for duplicate CI on every commit.

Use CircleCI when:

- GitHub Actions is unavailable or quota-constrained;
- a second provider is useful to validate CI portability;
- a temporary overflow lane is needed.

The CircleCI job must execute the same `.ci/run.sh` contract rather than reimplementing checks.

## Reusable template boundary

The reusable part of this pattern is deliberately small:

- `.ci/run.sh` — repository-owned verification entrypoint;
- optional setup scripts under `.ci/` for pinned runtime/tool installation;
- `.github/workflows/ci.yml` — canonical provider wrapper;
- `.circleci/config.yml` — optional fallback wrapper;
- this strategy document / equivalent policy.

Language-, framework-, and product-specific checks belong inside `.ci/run.sh` or scripts it calls. The provider wrappers should remain nearly identical across repositories.

This makes the pattern suitable for a future starter template without forcing every repository to use the same programming language or toolchain.

## Rules

- One CI contract, multiple providers.
- Do not copy test/build command lists into both provider configs.
- Prefer the cheapest deterministic checks first.
- Pin externally downloaded runtimes/tools and verify their provenance/checksum when practical.
- Do not use production credentials in CI.
- Do not make both providers blocking by default; choose one authoritative provider unless there is a specific reason to require both.
- CI is not complete until the canonical provider is green on the current commit.
- Engine/runtime smoke is evidence of launchability, not proof of an interactive product happy path.
