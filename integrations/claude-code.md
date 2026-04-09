## Dev Harness Workflow
When a project contains a `.harness/` directory, this project uses the dual-agent workflow:
- **Claude Code** = Builder agent (executes tasks, writes code, generates handoffs)
- **Codex** = Reviewer agent (reviews handoffs, grades quality, catches errors)
- **Cursor** = IDE-integrated Builder (same role as Claude Code, different interface)

### Builder Mode (when you see `.harness/`)
1. Read `.harness/roles/builder-brief.md` for your full role definition
2. Pick tasks from `.harness/coordination/task-board.md`
3. Follow `.harness/taste/principles.md` as binding constraints
4. Generate handoff files in `.harness/handoffs/` when completing work
5. Update `progress-log.md` and `task-board.md` after every significant action

### CLI Shortcut
- `harness init <dir>` — bootstrap .harness/ in any project
- `harness build` — launch Claude Code as Builder
- `harness review` — launch Codex as Reviewer
- `harness loop` — run one full build→review cycle
