# Agent Instructions

Read and follow `docs/engineering-standards.md` before making changes.

## Working style

- Make the smallest useful change.
- Keep diffs localized.
- Do not change unrelated code.
- Prefer incremental progress over broad rewrites.

## Workflow

For non-trivial work:

1. Briefly state the plan.
2. Inspect the relevant files.
3. Add or update tests for behavior changes.
4. Implement the minimal change.
5. Run focused tests first, then broader relevant tests.
6. Summarize:
  - files changed
  - tests added/updated
  - commands run
  - remaining risks or follow-ups

## Specific expectations

- For bug fixes, reproduce with a failing test if feasible.
- For refactors, preserve behavior and prove it with tests.
- Avoid introducing duplication.
- Avoid speculative abstractions.
- Keep Rust handlers thin and business logic testable.
- Keep ReScript browser API usage isolated behind small wrappers/modules.

## Docker-related changes

- When changing runtime or deployment behavior, update the relevant Dockerfile, Compose files, and docs.
- Keep development and production Compose configuration separate.
- Do not commit secrets or real credentials.
- Persist database data in named volumes.
- Expose only required services publicly.

## Output expectations

Be concise. Prefer concrete results over long explanations.