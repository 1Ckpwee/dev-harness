# Execution Strategy

> Defines how agents coordinate across sessions. Each session is stateless — all state lives in `.harness/` files.

## Core Principles

### 1. Session Isolation
Every agent session starts **clean** — no memory of previous sessions. Context comes exclusively from `.harness/` files. This prevents context pollution and hallucinated continuity.

### 2. File-Based State Sync
Agents communicate ONLY through the file system:
- `task-board.md` — what to work on
- `progress-log.md` — what was done
- `handoffs/` — detailed inter-agent briefings
- `reviews/` — quality feedback

### 3. Progressive Disclosure
Agents read only what they need for the current task. The context-map provides a birds-eye view; handoff files provide task-specific deep context. This prevents context window saturation.

## Agent Rotation Protocol

```
┌─────────────┐     handoff file     ┌──────────────┐
│   Builder    │ ──────────────────→  │   Reviewer    │
│ (Claude Code │                      │   (Codex)     │
│  or Cursor)  │ ←──────────────────  │              │
└─────────────┘     review file      └──────────────┘
       ↑                                     │
       │          human override             │
       └──────────── ← ─────────────────────┘
```

### Cycle Steps
1. **Human** populates `task-board.md` with prioritized tasks
2. **Builder** picks next unblocked task → executes → writes handoff
3. **Reviewer** reads handoff + source → writes review
4. If PASS → task moves to `done`, next task begins
5. If FAIL → task returns to `todo` with review notes attached
6. **Human** intervenes at any point to adjust scope, resolve disputes, or inject new tasks

## Concurrency Rules
- Only ONE builder session active at a time per task
- Reviewer MUST NOT start until handoff file exists
- Multiple tasks CAN be in different stages simultaneously
- Human can override any task state at any time

## Escalation Protocol
If an agent encounters any of these, it MUST stop and log a `BLOCKER`:
- Ambiguous requirements with multiple valid interpretations
- Conflicting guidance between task-board and principles.md
- Changes that would affect more than 10 files
- Any operation that deletes data or drops tables
