# SDD (Spec-Driven Development) Integrations

> Reference guide — these frameworks are optional and detected by file presence.

## Detection

| Framework | Detection |
|---|---|
| OpenSpec | `openspec/` folder with `specs/` and `changes/` |
| spec-kit | `spec.md`, `constitution.md`, `boundaries.md`, `glossary.md` files |
| TaskMaster | MCP server `user-task-master-ai` |

## 1. OpenSpec

Two-folder architecture: `openspec/specs/` (specs) + `openspec/changes/` (active proposals).

### Workflow
Draft → Review → Implement → Complete → Archive

### Spec Format
```markdown
# [capability] Specification

## Requirements
### Requirement: [Name]
#### Scenario: [Name]
- GIVEN [precondition]
- WHEN [action]
- THEN [expected result]
```

## 2. GitHub Spec Kit

| File | Purpose |
|---|---|
| `spec.md` | Core functional specification |
| `constitution.md` | Architectural principles |
| `boundaries.md` | System scope |
| `glossary.md` | Domain terminology |

## 3. TaskMaster (MCP)

AI-powered task management. Tools:
- `get_tasks` / `next_task` / `set_task_status`
- `parse_prd` / `expand_task`

### Task Structure
```
.taskmaster/
├── docs/prd.txt
└── tasks/tasks.json
```

## Combined Workflow

1. **Requirements** — analytic creates PRD → OpenSpec specs
2. **Planning** — planner creates implementation plan
3. **Design** — architect follows constitution.md, writes design docs
4. **Implementation** — developer implements per specs
5. **Review** — code-reviewer verifies against specs
6. **Documentation** — doc-writer updates documentation
