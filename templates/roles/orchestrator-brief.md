# Orchestrator Brief

## Purpose
The Orchestrator is not an agent — it is the **protocol** that governs how Planner, Builder, and Reviewer interact. This document defines the coordination rules.

## The Coordination Cycle

```
User Intent
    │
    ▼
┌─────────────────────────────────────────┐
│  1. PLAN (once, at start)               │
│                                         │
│  duo plan "实现登录功能"                │
│       │                                 │
│       ▼                                 │
│  .duo/plans/plan_{ts}.md               │
│  - 任务拆解                              │
│  - 验收标准                              │
│  - 涉及文件                              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  2. BUILD-REVIEW LOOP (may repeat)      │
│                                         │
│  for round in 1..MAX_ROUNDS:           │
│                                         │
│    ① Builder reads plan.md             │
│       → executes current task           │
│       → writes .duo/handoffs/          │
│                                         │
│    ② Reviewer reads plan.md + diff     │
│       → writes .duo/reviews/           │
│       → verdict: PASS | FAIL           │
│                                         │
│    ③ if PASS → next task or done        │
│       if FAIL → Builder fixes           │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  3. COMPLETE                            │
│                                         │
│  All tasks PASS → commit & exit         │
│  Blocked by taste conflict → escalate    │
└─────────────────────────────────────────┘
```

## File Ownership

| File | Written By | Read By |
|------|-----------|---------|
| `.duo/plans/plan_*.md` | Planner | Builder, Reviewer |
| `.duo/handoffs/handoff_*.md` | Builder | Reviewer |
| `.duo/reviews/review_*.md` | Reviewer | Builder, Human |
| `.duo/coordination/task-board.md` | Human, Builder | Builder |
| `.duo/coordination/progress-log.md` | All agents | All agents |

## Agent Constraints

### Planner
- Must produce plan BEFORE any build begins
- Must reference taste/principles.md in every plan
- Must define concrete PASS criteria, not vague goals
- Cannot execute code or modify files

### Builder
- Must read the active plan before starting
- Must execute tasks in plan order
- Cannot start new task until current one passes review
- Must produce handoff file before Reviewer runs

### Reviewer
- Must grade against plan's验收标准, not free-form judgment
- P1 issues auto-fail; Builder must fix before continuing
- Cannot rewrite code — only describe what needs to change
- Must escalate taste conflicts to human

## Convergence Protection

```bash
# Detect repeated same issues (dead loop)
PREV=$(jq -r '.issues[].issue' ".duo/rounds/$((R-1))/review.json" | sort)
CURR=$(jq -r '.issues[].issue' ".duo/rounds/$R/review.json" | sort)
if [[ "$PREV" == "$CURR" ]]; then
    echo "Dead loop detected. Escalating to human."
    exit 2
fi
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tasks PASS, committed |
| 1 | User aborted or review disputed |
| 2 | Dead loop detected |
| 3 | Plan blocked by taste conflict |
