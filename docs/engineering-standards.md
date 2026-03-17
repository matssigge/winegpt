# Engineering Standards

## Goals

Build and maintain a Rust backend and ReScript frontend with these priorities:

1. Correctness
2. Simplicity
3. Testability
4. Maintainability
5. Low operational overhead
6. Good enough performance without premature optimization

Optimize for small, understandable systems over cleverness.

---

## General Working Rules

- Make small, incremental changes.
- Keep the system compiling and tests passing.
- Prefer explicit code over implicit magic.
- Avoid speculative abstraction.
- Avoid unnecessary dependencies.
- Do not mix unrelated changes in one patch.
- Preserve behavior unless the task explicitly changes behavior.
- When refactoring, prove behavior preservation with tests.

---

## Change Process

For any non-trivial change:

1. Understand the relevant existing code first.
2. Identify the smallest useful change.
3. Add or update tests before changing behavior.
4. Implement the smallest change that makes the tests pass.
5. Refactor only if it simplifies the result.
6. Run focused tests, then broader relevant tests.
7. Summarize the change, risks, and follow-up work.

For bug fixes:

1. Reproduce the bug with a failing test if feasible.
2. Fix the root cause, not only the symptom.
3. Add a regression test.

---

## Testing Policy

### General

- Prefer test-first development for behavior changes.
- Every bug fix should include regression coverage.
- Every new feature should include tests for:
  - happy path
  - relevant edge cases
  - at least one failure path
- Do not delete or weaken tests just to make the suite pass.
- Prefer deterministic tests.
- Keep tests readable and behavior-oriented.

### Test Levels

Use the smallest test level that gives confidence:

- **Unit tests** for pure logic, parsing, validation, transformations, and state transitions.
- **Integration tests** for module boundaries, database interactions, HTTP handlers, and API contracts.
- **End-to-end tests** sparingly, only for critical cross-stack flows.

Prefer more coverage in unit and integration tests than in brittle end-to-end tests.

### Coverage Guidance

- Aim for high coverage in business logic and domain rules.
- Do not chase vanity coverage on trivial glue code.
- Cover error handling, validation, and boundary cases.
- Untested code paths should be a deliberate choice.

---

## Duplication and Abstraction

- Do not tolerate repeated business logic.
- Do not extract abstractions too early.
- First duplication may be acceptable.
- Second similar duplication should trigger review.
- Extract only when the shared concept is real and stable.

Good abstractions:
- reduce duplication
- clarify intent
- make testing easier

Bad abstractions:
- hide simple behavior behind indirection
- generalize for hypothetical future use
- couple unrelated concerns

---

## Architecture Principles

- Keep boundaries clear.
- Separate transport, business logic, and persistence.
- Keep side effects near the edges.
- Keep domain logic in focused, testable modules.
- Prefer narrow interfaces.
- Prefer composition over inheritance-like patterns.
- Avoid framework-driven architecture.

### Backend boundary preference

- HTTP layer: request parsing, auth hooks, response mapping
- Service/domain layer: business rules and orchestration
- Persistence layer: SQL and storage concerns
- Shared types: only when they represent real shared concepts

### Frontend boundary preference

- UI components: rendering and local UI behavior
- Hooks/modules: async flows, API interaction, browser integration
- Shared frontend domain types: explicit and narrow
- Browser API wrappers: isolated and testable

---

## Rust Backend Rules

### Stack Preference

Default choices unless there is a good reason otherwise:

- Axum
- Tokio
- Serde
- SQLx
- SQLite initially, Postgres if needed
- thiserror for library/domain error types
- anyhow only at application boundaries when appropriate
- tracing for structured logs

### Code Style

- Use stable Rust.
- Keep handlers thin.
- Put business logic in service/domain modules.
- Prefer explicit types where they improve clarity.
- Avoid unnecessary cloning and allocation.
- Prefer straightforward ownership/borrowing over complicated lifetime tricks.
- Avoid macros when normal functions are clearer.
- Panic only for impossible states or startup-time invariants, not normal control flow.

### Errors

- Use typed errors where the caller can take meaningful action.
- Add context to propagated errors.
- Return user-safe error messages at API boundaries.
- Log operational details; do not leak internals to clients.

### Database

- Prefer explicit SQL over heavy ORM usage.
- Keep queries close to the code that owns them unless reuse is clear.
- Use migrations for schema changes.
- Test migrations and query behavior.
- Treat schema changes as code changes that require review.

### API Design

- Prefer simple JSON APIs.
- Keep request/response types explicit.
- Validate inputs at the boundary.
- Avoid oversized handler functions.
- Keep backward compatibility in mind once endpoints are consumed externally.

---

## ReScript Frontend Rules

### General

- Keep components small and focused.
- Prefer explicit data flow.
- Keep side effects isolated.
- Model state precisely using variants, records, and option types.
- Avoid impossible states represented by multiple loosely related booleans.

### ReScript vs JavaScript

- Write frontend application code in ReScript by default.
- Do not implement new frontend behavior in JavaScript when it can reasonably be implemented in ReScript.
- Use JavaScript only for thin interop boundaries, such as:
  - browser APIs that are awkward to model directly in ReScript
  - third-party library bindings
  - tool-required config or runtime glue files
- Do not have ReScript modules import other ReScript modules through generated `.bs.js` files.
- When touching an existing JavaScript frontend module, prefer moving the touched behavior into ReScript instead of extending the JavaScript surface area.
- If a new JavaScript frontend file is truly necessary, document the reason in the commit message or PR description.

### React Usage

- Presentational components should stay mostly pure.
- Put async logic and browser API interaction into hooks/modules.
- Lift state only when necessary.
- Avoid deeply nested prop plumbing by introducing small local composition points, not global complexity by default.
- Prefer composable components with children over configurable components with lots of props

### Styling

- Use Tailwind
- Do extract markup to a new React component if a class list is reused for the same semantic purpose.
- Don't extract markup to a component just to avoid duplicated class lists
- Use clsx for conditional classes. Don't concatenate strings or use template strings.

### API Interaction

- Centralize API calls in dedicated modules.
- Keep transport details away from most components.
- Use typed request/response boundaries.
- Handle loading, empty, success, and error states explicitly.

### Browser and Mobile APIs

- Isolate browser APIs like camera/media access behind thin wrappers.
- Permission handling should be centralized.
- Components should not directly manage raw browser API complexity unless there is a strong reason.
- Treat mobile support as a first-class requirement in browser-facing code.

### UI Complexity

- Prefer simple and robust UI behavior over clever interactions.
- Avoid hidden state transitions.
- Keep forms, async flows, and permission flows easy to reason about.

---

## Refactoring Rules

- Refactor only with a clear goal.
- Preserve behavior unless explicitly changing it.
- Prefer a series of small refactors over one large rewrite.
- Add or update tests before refactoring risky code.
- Remove dead code when safe to do so.
- Do not combine refactoring with unrelated feature work.

---

## Performance Rules

- Prefer simple correct code first.
- Measure before optimizing.
- Optimize memory and latency only where it matters.
- Avoid complexity justified only by vague performance concerns.
- For this project, low operational footprint matters more than extreme throughput.

---

## Dependency Rules

Before adding a dependency, ask:

1. Does the standard library or current stack already solve this?
2. Is the dependency mature and maintained?
3. Does it reduce meaningful complexity?
4. Is the long-term cost worth it?

Prefer fewer dependencies.

---

## Code Review Checklist

Before considering work done, check:

- Does it compile?
- Are tests added or updated appropriately?
- Are error cases covered?
- Is behavior clear from the code?
- Is duplication reduced or at least not increased without reason?
- Are boundaries respected?
- Are names accurate and boring in a good way?
- Is there any speculative abstraction to remove?
- Is the diff doing more than the task requires?

---

## Docker and Deployment Rules

- Use Docker Compose for local development and single-host deployment.
- Name the Docker Compose project to avoid collisions with other projects.
- Keep one concern per container:
  - database
  - backend
  - frontend/reverse proxy if needed
- Persist database state in named volumes.
- Do not commit secrets in Compose files or `.env` files intended for real credentials.
- Keep development and production configuration separate.
- Prefer official or minimal base images.
- Run application processes as non-root where practical.
- Keep containers replaceable; persistent state belongs in volumes or external storage.
- Expose only the services that must be reachable from outside the host.
- Document all required environment variables and ports.
 
---

## Documentation Rules

Document decisions when they are not obvious.

Create a short ADR when:
- choosing a major library or framework
- defining a cross-cutting pattern
- making a tradeoff that future-you may question
- rejecting an alternative with real appeal

Keep docs short and current.

---

## Default Biases

When in doubt:

- choose simpler code
- choose explicit code
- choose narrower scope
- choose stronger tests
- choose fewer abstractions
- choose boring technology already in the stack
