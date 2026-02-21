# Memory System Templates (JSON)

Templates for the BetterAgentX memory system in JSON format.

## Files

### 1. active-context.json
**Purpose:** Current project context

**Structure:**
- `project`: General project information
- `currentFocus`: Current focus and objectives
- `techStack`: Technology stack
- `team`: Team information
- `constraints`: Constraints and limitations
- `nextSteps`: Next steps
- `blockers`: Current blockers

**When to update:**
- Project phase change
- New feature started
- Objective change
- Technology change

---

### 2. decision-log.json
**Purpose:** Technical decision log (ADR - Architecture Decision Records)

**Structure:**
- `decisions[]`: Array of decisions
  - `id`: Unique identifier (ADR-001, ADR-002, etc.)
  - `status`: accepted | rejected | deprecated | superseded
  - `context`: Decision context
  - `decision`: The decision made
  - `consequences`: Positive/negative consequences
  - `alternatives`: Alternatives considered

**When to update:**
- Architectural decision
- Technology selection
- Design pattern selection
- Important trade-off

---

### 3. patterns.json
**Purpose:** Reusable patterns and solutions

**Structure:**
- `patterns[]`: Array of patterns
  - `id`: Unique identifier (PATTERN-001, etc.)
  - `category`: architectural | design | implementation | testing | deployment | security
  - `problem`: Problem it solves
  - `solution`: Proposed solution
  - `implementation`: Code and dependencies
  - `useCases`: Use cases

**When to update:**
- Reusable solution identified
- Problem solved elegantly
- Anti-pattern discovered
- Best practice learned

---

### 4. progress.json
**Purpose:** Task tracking and progress

**Structure:**
- `tasks[]`: Array of tasks
  - `id`: Unique identifier (TASK-001, etc.)
  - `status`: todo | in-progress | blocked | completed | cancelled
  - `priority`: critical | high | medium | low
  - `dependencies`: Dependent tasks
  - `blockers`: Blockers
- `milestones[]`: Project milestones
- `summary`: Summary and metrics

**When to update:**
- Task completed
- New task started
- Milestone reached
- Status change

---

## Usage

### During init.sh
Templates are copied to `.kiro/memory/` in new projects.

### Manual Update
```bash
cp templates/memory/*.json .kiro/memory/
```

### Validation
```bash
# Validate JSON
jq empty .kiro/memory/*.json
```

---

## Date Format

Use ISO 8601 format:
```
"date": "2026-02-14"
"lastUpdated": "2026-02-14T18:00:00Z"
```

## IDs

- Decisions: `ADR-001`, `ADR-002`, etc.
- Patterns: `PATTERN-001`, `PATTERN-002`, etc.
- Tasks: `TASK-001`, `TASK-002`, etc.
- Milestones: `MILESTONE-001`, `MILESTONE-002`, etc.

---

**Version:** 1.0.0  
**Format:** JSON  
**Last updated:** 2026-02-14
