# CI strategy

## Goal

Keep CI behavior portable across providers and cheap to operate.

The repository defines one provider-neutral verification contract:

```bash
bash .ci/run.sh
```

GitHub Actions and CircleCI are wrappers around that same contract. Provider configuration must not become a second source of truth for test commands.

## Provider roles

### GitHub Actions — canonical CI

GitHub Actions is the default required CI path for pushes to `main` and pull requests.

It should stay small and deterministic. New quality gates should first be added to `.ci/run.sh`; the GitHub Actions workflow should only handle provider-specific setup.

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
- `.github/workflows/ci.yml` — canonical provider wrapper;
- `.circleci/config.yml` — optional fallback wrapper;
- this strategy document / equivalent policy.

Language-, framework-, and product-specific checks belong inside `.ci/run.sh` or scripts it calls. The provider wrappers should remain nearly identical across repositories.

This makes the pattern suitable for a future starter template without forcing every repository to use the same programming language or toolchain.

## Rules

- One CI contract, multiple providers.
- Do not copy test/build command lists into both provider configs.
- Prefer the cheapest deterministic checks first.
- Do not use production credentials in CI.
- Do not make both providers blocking by default; choose one authoritative provider unless there is a specific reason to require both.
- CI is not complete until the canonical provider is green on the current commit.
