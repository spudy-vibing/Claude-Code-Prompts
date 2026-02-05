---
name: implementation-plan
description: Creates phased implementation plans from BRDs, architecture docs, user stories. Use when asked to "plan implementation", "create a build plan", "break this into phases", or given requirements docs to turn into actionable steps.
---

# Implementation Plan

Create a comprehensive, phased implementation plan from requirements documentation.

## Trigger

Invoke when the user provides:
- BRD (Business Requirements Document)
- Architecture diagrams or docs
- User flows or journey maps
- User stories or acceptance criteria
- Research or discovery documents
- Any combination of the above

## Input

1. Ask the user for input documents if not provided:
   ```
   What documents should I use to create the implementation plan?
   Please provide file paths (e.g., docs/brd.md, docs/architecture.md)
   ```

2. Read all provided documents to understand:
   - Feature scope and boundaries
   - Technical constraints and dependencies
   - User-facing requirements
   - Non-functional requirements (performance, security, accessibility)

## Planning Process

3. Analyze the documents and identify:
   - Core functionality clusters (group related features)
   - Technical layers involved (API, database, UI, integrations)
   - Dependency order (what must be built first)
   - Risk areas (complex logic, external dependencies, unknowns)

4. Structure the plan into **Phases**:
   - Each phase delivers testable, demonstrable functionality
   - Phases build on each other (no circular dependencies)
   - Early phases reduce risk (prove out unknowns first)
   - Phase size: 1-3 days of work typical

5. Break each phase into **Steps**:
   - Each step is independently actionable
   - Steps take 15-60 minutes each
   - Include specific file paths to create/modify
   - Include commands to run (migrations, tests, builds)

6. Add **Test Coverage Requirements** at phase boundaries:
   - Insert after phases that introduce significant new code
   - Insert at natural integration points (API complete, UI connected)
   - Specify qualitatively:
     - "Unit tests for all new service methods"
     - "Integration test for the complete user flow"
     - "E2E test covering the happy path"
   - Do NOT use arbitrary percentage targets

7. For **UX/Frontend phases**, add this instruction:
   ```
   AUTO-INVOKE: /frontend-design
   Before implementing UI for this phase, invoke the frontend-design
   skill with the component requirements below.
   ```
   Include component requirements: purpose, user interactions, data displayed.

## Output Format

8. Create the plan file at `docs/plans/YYYY-MM-DD-<feature-name>.md`:

```markdown
# Implementation Plan: <Feature Name>

**Created:** YYYY-MM-DD
**Source Documents:**
- `path/to/brd.md`
- `path/to/architecture.md`

**Estimated Phases:** N
**Key Risks:** <brief list>

---

## Phase 1: <Phase Name>

**Goal:** <What this phase delivers — testable outcome>
**Depends on:** None | Phase N

### Step 1.1: <Step Name>

**Files:**
- Create: `src/path/to/new-file.ts`
- Modify: `src/path/to/existing.ts`

**Tasks:**
1. Task description with specifics
2. Another task
3. Run: `npm test src/path/`

### Step 1.2: <Step Name>
...

---

## Phase 2: <Phase Name>

**Goal:** <Testable outcome>
**Depends on:** Phase 1

### Step 2.1: <Step Name>
...

---

### Coverage Checkpoint: After Phase 2

- [ ] Unit tests for UserService methods (create, update, delete)
- [ ] Integration test for /api/users endpoints
- [ ] Verify existing tests still pass

---

## Phase 3: <Phase Name> (UI)

**Goal:** <Testable outcome>
**Depends on:** Phase 2

> **AUTO-INVOKE: /frontend-design**
> Before implementing, invoke frontend-design with:
> - Component: UserProfileCard
> - Purpose: Display user info with edit capability
> - Data: name, email, avatar, role
> - Interactions: Edit button opens modal

### Step 3.1: <Step Name>
...

---

### Coverage Checkpoint: After Phase 3

- [ ] Component unit tests for UserProfileCard
- [ ] E2E test for complete user profile flow
- [ ] Accessibility audit (keyboard nav, screen reader)

---

## Execution Notes

- Run phases sequentially unless noted otherwise
- Each phase should end with passing tests
- Commit after each phase completion
```

## After Plan Creation

9. Summarize for the user:
   - Total phases and estimated scope
   - Key decision points or assumptions made
   - Any gaps in the source documents that need clarification

10. Ask:
    ```
    Plan created at docs/plans/YYYY-MM-DD-<feature>.md

    Ready to start execution? Options:
    1. Begin Phase 1 now
    2. Review and refine the plan first
    3. Clarify requirements before proceeding
    ```

## Principles

- **Testable phases**: Every phase ends with something you can demo or verify
- **No premature optimization**: Build the simple version first, optimize in later phases
- **Risk-first**: Tackle unknowns and integrations early, not last
- **Coverage at seams**: Test checkpoints at integration boundaries, not arbitrary intervals
- **UX deferred to specialists**: Don't inline UI design — invoke frontend-design skill
