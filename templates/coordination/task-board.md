# Task Board

> Shared task queue for Builder and Reviewer agents.
> Tasks flow: `backlog` → `todo` → `in_progress` → `in_review` → `done`

## Legend
- **Owner**: `builder` | `reviewer` | `human`
- **Priority**: P0 (critical) > P1 > P2 > P3
- **Blocked by**: task ID that must complete first

---

## Backlog
<!-- Tasks identified but not yet planned -->

| ID | Task | Priority | Owner | Blocked By | Notes |
|----|------|----------|-------|------------|-------|
| | | | | | |

## Todo
<!-- Tasks ready to be picked up -->

| ID | Task | Priority | Owner | Blocked By | Notes |
|----|------|----------|-------|------------|-------|
| | | | | | |

## In Progress
<!-- Currently being worked on -->

| ID | Task | Priority | Owner | Started | Notes |
|----|------|----------|-------|---------|-------|
| | | | | | |

## In Review
<!-- Builder done, waiting for Reviewer -->

| ID | Task | Priority | Handoff File | Notes |
|----|------|----------|-------------|-------|
| | | | | |

## Done
<!-- Completed and reviewed -->

| ID | Task | Completed | Review Verdict | Notes |
|----|------|-----------|---------------|-------|
| | | | | |

---
*Last updated by: {AGENT} at {TIMESTAMP}*
