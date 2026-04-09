# Output Format Specification

> All agent outputs must conform to these formats for consistency and parseability.

## Code Changes

### Commit Messages
```
<type>(<scope>): <subject>

<body — optional, explain WHY not WHAT>

Refs: T{task_id}
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

### Branch Naming
```
harness/{task_id}-{short-description}
```

## Handoff Files

Path: `.harness/handoffs/handoff_v{version}_{topic}.md`

```markdown
# Handoff v{N}: {Topic}

**Task**: T{id} — {description}
**Agent**: builder
**Date**: {YYYY-MM-DD HH:MM}
**Status**: complete | partial | blocked

## Changes Made
- `path/to/file.ext` — what changed and why

## Decisions
- Decision: {what}. Reason: {why}. Alternative considered: {what else}.

## Open Questions
1. {question} — context: {why it matters}

## Review Focus
- [ ] {specific area to scrutinize}

## Files Touched
- `path/to/file1.ext`
- `path/to/file2.ext`
```

## Review Files

Path: `.harness/reviews/review_v{version}_{topic}.md`

```markdown
# Review v{N}: {Topic}

**Reviewing**: handoff_v{N}_{topic}.md
**Agent**: reviewer
**Date**: {YYYY-MM-DD HH:MM}
**Verdict**: PASS | PASS_WITH_NOTES | FAIL

## Issues

### P1 — Blockers
- **{title}** (`file:line`): {description}
  - Source says: `{actual code}`
  - Builder wrote: `{what builder produced}`
  - Fix: {suggested fix}

### P2 — Major
...

### P3 — Minor
...

## What's Good
- {positive observation}

## Scope Check
{in-scope | drifted — details}

## Next Actions
1. {specific instruction for builder}
```

## Progress Log Entries
```
[YYYY-MM-DD HH:MM] [agent] [ACTION_TYPE] message
```
Single line, no multiline entries. Keep it scannable.
