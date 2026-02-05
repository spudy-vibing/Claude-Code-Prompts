# Implementation Plan

Creates phased, actionable implementation plans from requirements documents. Transforms BRDs, architecture docs, and user stories into step-by-step build plans with testable phase boundaries.

## Quick Start

### Install

```bash
npx skills add spudy-vibing/Claude-Code-Prompts/implementation-plan
```

### Use

```
/implementation-plan
```

Provide your requirements documents when prompted, or reference them directly:

```
/implementation-plan docs/brd.md docs/architecture.md
```

---

## What It Does

1. **Reads** your requirements docs (BRDs, architecture, user stories, research)
2. **Analyzes** scope, dependencies, technical layers, and risk areas
3. **Structures** work into phases that deliver testable outcomes
4. **Breaks down** phases into 15-60 minute actionable steps
5. **Adds** test coverage checkpoints at integration boundaries
6. **Chains** to `/frontend-design` for UI phases automatically
7. **Outputs** a plan file at `docs/plans/YYYY-MM-DD-<feature>.md`

---

## Input

The skill accepts any combination of:

| Document Type | Examples |
|---------------|----------|
| BRD | Business requirements, feature specs |
| Architecture | System diagrams, technical constraints |
| User flows | Journey maps, wireframes |
| User stories | Acceptance criteria, edge cases |
| Research | Discovery docs, competitor analysis |

---

## Output

A structured plan file with:

```markdown
# Implementation Plan: <Feature>

**Source Documents:** <list>
**Estimated Phases:** N
**Key Risks:** <brief list>

## Phase 1: <Name>
**Goal:** <testable outcome>
**Depends on:** None

### Step 1.1: <Name>
**Files:** Create/Modify list
**Tasks:** Numbered actions + commands

---

### Coverage Checkpoint: After Phase N
- [ ] Unit tests for X
- [ ] Integration test for Y

---

## Execution Notes
- Run phases sequentially
- Each phase ends with passing tests
- Commit after each phase
```

---

## Principles

| Principle | What It Means |
|-----------|---------------|
| **Testable phases** | Every phase ends with something you can demo or verify |
| **Risk-first** | Tackle unknowns and integrations early, not last |
| **No premature optimization** | Build simple first, optimize in later phases |
| **Coverage at seams** | Test checkpoints at integration boundaries, not arbitrary intervals |
| **UX deferred** | UI phases auto-invoke `/frontend-design` skill |

---

## After Plan Creation

The skill asks what to do next:

1. **Begin Phase 1 now** — Start implementation immediately
2. **Review and refine** — Adjust the plan before starting
3. **Clarify requirements** — Go back to stakeholders with questions

---

## Tips

1. **Better input = better output** — Spend time on your BRD; the plan quality depends on it
2. **Run gap analysis after** — Compare the plan against source docs to catch missed requirements
3. **Commit after each phase** — The plan is designed for incremental, shippable progress
4. **Trust the phase order** — Risk-first sequencing prevents late-stage surprises

---

## Related

- Works well with the [memory-init](../memory-init/) skill for tracking plan execution across sessions
- Pairs with `/frontend-design` for UI implementation phases
