# Progress Log

> Append-only log of actions and decisions. Never edit or delete entries.
> Format: `[TIMESTAMP] [AGENT] [ACTION_TYPE] message`

## Action Types
- `TASK_START` — Agent began working on a task
- `TASK_DONE` — Agent completed a task
- `DECISION` — A judgment call was made (include reasoning)
- `HANDOFF` — Handoff file generated
- `REVIEW` — Review completed
- `HUMAN` — Human intervention or override
- `BLOCKER` — Something is blocking progress
- `SCOPE_CHANGE` — Task scope was adjusted

---

## Log

<!-- Example entries:
[2026-04-09 14:00] [builder] [TASK_START] Starting T001: implement auth middleware
[2026-04-09 14:30] [builder] [DECISION] Used JWT over session tokens — aligns with principles.md stateless preference
[2026-04-09 15:00] [builder] [HANDOFF] Generated handoff_v0_auth.md — 3 files touched
[2026-04-09 15:15] [reviewer] [REVIEW] review_v0_auth.md — PASS_WITH_NOTES (1x P2, 2x P3)
[2026-04-09 15:30] [human] [SCOPE_CHANGE] Auth task expanded to include rate limiting
-->
