Fix this bug using TDD.

Process:
1. Restate the bug and likely affected area.
2. Add a failing test that reproduces it, if feasible.
3. Implement the minimal fix.
4. Run focused tests first.
5. Run broader relevant tests.
6. Summarize root cause, fix, and regression coverage.

Constraints:
- Fix the root cause, not only the symptom.
- Do not remove or weaken tests.
- Keep the patch localized.
- Do not mix in unrelated cleanup.