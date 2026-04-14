# duo-dev

A dual-agent workflow that separates **code execution** from **code review** using local CLI tools and the file system as the coordination layer.

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

## Why

AI coding agents are good at executing but bad at self-reviewing. This tool enforces a strict separation:

- **Builder** (Claude Code / Cursor) — explores code, executes tasks, writes code
- **Reviewer** (Codex) — verifies facts against source, catches errors, grades quality
- **Human** — sets priorities, resolves disputes, injects taste

Each agent session starts **clean**. All state lives in `.duo/` files — no memory, no context leakage between sessions.

## Install

**One-line install (recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/1Ckpwee/duo-dev/main/install.sh | bash
```

**Or clone and install:**

```bash
git clone https://github.com/1Ckpwee/duo-dev.git
cd duo-dev
./install.sh
```

This will:
- Copy templates to `~/.duo-dev/`
- Copy integration configs for Claude Code, Codex, and Cursor
- Link `duo` CLI to `~/.local/bin/`
- Add `.duo/` to your global gitignore
- Configure Claude Code, Codex, and Cursor (if installed)

## Uninstall

```bash
duo uninstall
```

This removes the CLI, `~/.duo-dev/`, and cleans integration configs from Claude Code / Codex / Cursor. Per-project `.duo/` directories are left untouched.

## Usage

### Initialize a project

```bash
duo init ~/my-project
```

This creates a `.duo/` directory (gitignored, never pushed to remote):

```
.duo/
├── roles/              # Agent role definitions
│   ├── builder-brief.md
│   ├── reviewer-brief.md
│   ├── planner-brief.md
│   └── orchestrator-brief.md
├── coordination/       # Shared state
│   ├── context-map.md      # Codebase topology
│   ├── task-board.md       # Task queue with priorities
│   └── progress-log.md    # Append-only activity log
├── quality/            # Standards & gates
│   ├── review-checklist.md
│   ├── execution-strategy.md
│   └── output-format.md
├── taste/              # Your engineering principles
│   └── principles.md
├── plans/              # Generated plans (from duo plan)
├── handoffs/           # Builder → Reviewer
└── reviews/            # Reviewer → Builder
```

### Three-agent workflow

```bash
# 1. Inject your taste
vim .duo/taste/principles.md

# 2. Generate a plan from intent
duo plan "Implement user login feature"

# 3. Execute plan (Builder + Reviewer loop)
duo loop
# Or step by step:
duo build
duo review

# Use --yes to skip confirmations (CI mode)
duo plan "Implement user login feature" --yes
duo loop --yes
```

### Commands

| Command | Description |
|---------|-------------|
| `duo init [dir]` | Bootstrap `.duo/` in a project |
| `duo plan "intent"` | Generate plan from user intent |
| `duo build [dir]` | Launch Claude Code as Builder |
| `duo review [dir]` | Launch Codex as Reviewer |
| `duo loop [dir]` | One full build → review cycle |
| `duo status [dir]` | Show current task/handoff/review state |
| `duo context [dir]` | Auto-generate context-map from codebase |
| `duo uninstall` | Remove duo-dev from this machine |

## How it works

### The three roles

- **Planner** — translates user intent into a concrete plan with acceptance criteria
- **Builder** (Claude Code / Cursor) — executes tasks against the plan
- **Reviewer** (Codex) — verifies against plan's acceptance criteria, catches errors

### The cycle

1. **You** describe intent: `duo plan "Implement login feature"`
2. **Planner** generates `.duo/plans/plan.md` with task breakdown + acceptance criteria
3. **Builder** reads plan.md, executes current task, generates a `handoff_*.md`
4. **Reviewer** grades against plan.md acceptance criteria, outputs `review_*.md`
5. Review verdict:
   - **PASS** → next task or commit
   - **PASS_WITH_NOTES** → minor issues noted, your call
   - **FAIL** → P1 blocker, Builder must fix in next session
6. **You** intervene at any point to adjust scope or resolve disputes

### Review severity

| Level | Meaning | Action |
|-------|---------|--------|
| P1 | Factual error, security issue, broken logic | Must fix (auto FAIL) |
| P2 | Wrong abstraction, missing context | Should fix |
| P3 | Style inconsistency | Nice to fix |
| P4 | Cosmetic nit | Optional |

### Taste injection

Edit `.duo/taste/principles.md` to inject your engineering principles. These are treated as **binding constraints**, not suggestions. Both agents grade their work against your principles.

## Tool support

| Tool | Role | Auto-configured by `install.sh` |
|------|------|------|
| [Claude Code](https://github.com/anthropics/claude-code) | Builder | `~/.claude/CLAUDE.md` |
| [Codex](https://github.com/openai/codex) | Reviewer | `~/.codex/AGENTS.md` |
| [Cursor](https://cursor.com) | Builder (IDE) | `~/.cursor/rules/duo-dev.mdc` |

You can substitute any coding agent — just have it read the builder/reviewer brief from `.duo/roles/`.

## Principles

- **Session isolation** — every session starts clean, no memory carryover
- **File-based coordination** — agents talk through files, not shared context
- **Progressive disclosure** — agents read only what they need for the current task
- **Human-in-the-loop** — you own the task board, the principles, and the final call

## License

MIT
