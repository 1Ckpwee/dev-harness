# Engineering Principles (Taste Injection)

> These are the human operator's personal guidelines. Agents MUST align their work with these principles. When in doubt, these override generic best practices.

---

## Code Philosophy

### Simplicity First
- The simplest solution that works is the correct solution
- Three similar lines > premature abstraction
- No speculative generalization — solve the problem in front of you
- If a function is only called once, inline it unless it improves readability

### Minimal Diff
- Change only what the task requires
- Don't "improve" surrounding code unless explicitly asked
- Don't add docstrings, comments, or type annotations to untouched code
- Don't add error handling for scenarios that can't happen

### Explicit Over Clever
- Prefer readable code over clever code
- Name things for what they ARE, not what they DO
- Avoid magic numbers, but don't over-extract constants either
- If the code needs a comment to explain, rewrite the code first

## Architecture

### Boundaries Matter
- Validate at system boundaries (user input, external APIs), trust internal code
- Each module should have a clear, single responsibility
- Dependencies flow inward — outer layers depend on inner, never reverse
- Prefer composition over inheritance

### Testing Strategy
- Test behavior, not implementation
- Integration tests > unit tests for business logic
- Mock external services, never mock internal code
- Every bug fix gets a regression test

## Communication Style

### Agent Output
- Lead with the answer, not the reasoning
- Be concise — if you can say it in one sentence, don't use three
- Show file paths and line numbers when referencing code
- No filler words, no preamble, no trailing summaries

### Commit Messages
- Focus on WHY, not WHAT (the diff shows WHAT)
- One logical change per commit
- Reference task IDs

## Decision Framework
When facing a choice between two approaches:
1. Which is simpler?
2. Which is easier to delete later?
3. Which has fewer moving parts?
4. Which matches existing patterns in this codebase?

Choose the option that wins on the most criteria.

---

> **Note to agents**: These principles are NOT suggestions. If your output conflicts with any of these, it WILL be flagged in review. When a specific task instruction conflicts with these principles, ask the human — don't guess.
