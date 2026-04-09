# Review Checklist

> Used by the Reviewer agent to grade Builder output. A single P1 = FAIL verdict.

## Blocking Issues (any one → FAIL)

- [ ] **Factual error**: Code reference doesn't match actual source
- [ ] **Security vulnerability**: OWASP Top 10, hardcoded secrets, injection vectors
- [ ] **Broken logic**: Code that will error at runtime or produce wrong results
- [ ] **Missing tests**: New logic without corresponding test coverage
- [ ] **Scope violation**: Changes to files/modules outside the task boundary
- [ ] **Data loss risk**: Destructive operations without backup/rollback path

## Major Issues (accumulate → PASS_WITH_NOTES)

- [ ] **Wrong abstraction level**: Over-engineered or under-abstracted
- [ ] **Missing error handling**: At system boundaries (user input, APIs, DB)
- [ ] **Incomplete migration**: Partial refactor that leaves dead code paths
- [ ] **Inconsistent naming**: Breaks existing codebase conventions
- [ ] **Missing documentation**: Public API changes without updated docs
- [ ] **Performance regression**: O(n²) where O(n) is straightforward

## Minor Issues (note but don't block)

- [ ] **Style inconsistency**: Doesn't match output-format.md
- [ ] **Suboptimal naming**: Functional but could be clearer
- [ ] **Redundant code**: Could be simplified without behavior change
- [ ] **TODO left behind**: Placeholder that should have been resolved

## Positive Signals (call out explicitly)

- [ ] **Clean commit history**: Atomic, well-messaged commits
- [ ] **Good test coverage**: Edge cases considered
- [ ] **Followed principles.md**: Aligned with human's stated preferences
- [ ] **Minimal diff**: Achieved goal with minimum necessary changes
