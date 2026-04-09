## Duo Dev Workflow
When a project contains a `.duo/` directory, this project uses the dual-agent workflow:
- **Claude Code** = Builder agent (executes tasks, writes code, generates handoffs)
- **Codex** = Reviewer agent (reviews handoffs, grades quality, catches errors)
- **Cursor** = IDE-integrated Builder (same role as Claude Code, different interface)

### Builder Mode (when you see `.duo/`)
1. Read `.duo/roles/builder-brief.md` for your full role definition
2. Pick tasks from `.duo/coordination/task-board.md`
3. Follow `.duo/taste/principles.md` as binding constraints
4. Generate handoff files in `.duo/handoffs/` when completing work
5. Update `progress-log.md` and `task-board.md` after every significant action

### CLI Shortcut
- `duo init <dir>` — bootstrap .duo/ in any project
- `duo build` — launch Claude Code as Builder
- `duo review` — launch Codex as Reviewer
- `duo loop` — run one full build→review cycle
