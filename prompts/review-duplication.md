Review this code for duplication and unnecessary abstraction.

Focus on:
- repeated business logic
- repeated validation rules
- repeated state handling
- duplicated transport/persistence glue
- abstractions that do not yet pay for themselves
- opportunities to simplify module boundaries

Output:
1. Real duplication that should be addressed now.
2. Duplication that can wait.
3. Abstractions that should be removed or flattened.
4. Suggested smallest safe refactor.