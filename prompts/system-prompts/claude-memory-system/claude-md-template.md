# CLAUDE.md Template with Memory Protocol

## Description

Template for your project's CLAUDE.md file that includes the memory protocol. Customize the "Project Context" section for your specific project.

## Template

```markdown
# Claude Code Instructions for [PROJECT NAME]

This file governs Claude's behavior when working on this project.

---

## Memory Protocol

Persistent memory exists at `.claude/mem/`. This is Claude's memory, Claude's format.

**On every session start:**
- Memory is auto-loaded via SessionStart hook
- No announcement needed unless something significant changed since last checkpoint
- If git hash differs from stored hash, scan for architecture changes

**Before ending any session:**
- Update `.claude/mem/` with everything learned
- Capture any new decisions, direction changes, context discovered
- Checkpoint automatically when session ending is detected

**Session end triggers (checkpoint immediately when you see these):**
- "done", "thanks", "that's all", "exit", "checkpoint", "save", "bye", "end", "stop"
- Any clear signal the conversation is wrapping up
- User closing the conversation or switching context

**Checkpoint behavior:**
- Load silently, no confirmation needed
- Checkpoint silently unless explicitly asked for confirmation
- Never lose session learnings—always persist before ending
- If uncertain whether session is ending, checkpoint anyway (safe default)

---

## Project Context (Always Know This)

<!-- CUSTOMIZE THIS SECTION FOR YOUR PROJECT -->

**What [PROJECT NAME] Is:**
- [Brief description of the project]
- [Target users/audience]
- [Core philosophy or principles]

**Current State:**
- [Current phase or milestone]
- [What's complete]
- [What's in progress]
- [What's planned]

**Architecture Essentials:**
- [Key frameworks/libraries]
- [Important patterns used]
- [Where state lives]
- [Key directories and their purposes]

---

## Coding Standards

<!-- CUSTOMIZE THESE FOR YOUR PROJECT -->

**Follow these patterns:**
- [Pattern 1]
- [Pattern 2]
- [Pattern 3]

**Type Hints:** [Your type hint preferences]

**Error Handling:** [Your error handling approach]

**Imports:** [Your import organization]

**Avoid:**
- [Anti-pattern 1]
- [Anti-pattern 2]

---

## Workflow Preferences

**When to ask vs proceed:**
- ASK: [Things requiring discussion]
- PROCEED: [Things Claude can do autonomously]

**Task approach:**
1. Understand the request fully before coding
2. Check existing patterns in codebase first
3. Prefer editing existing files over creating new ones
4. Keep changes minimal and focused
5. [Add project-specific steps]

---

## Communication Style

**Output preferences:**
- Concise responses, no fluff
- Show code changes directly, don't over-explain obvious things
- Use tables for comparisons
- When showing file changes, focus on the delta

**Progress updates:**
- Use todo lists for multi-step tasks
- Mark items complete as you go
- Don't announce every small action

---

## Safety Boundaries

**Never do these without explicit permission:**
- Modify system configuration
- Write to files outside the project directory
- Install global packages
- Push to git remote
- Delete files (warn and confirm first)
- [Add project-specific restrictions]

**Always safe:**
- Reading any file in the project
- Running tests
- Running linters
- Git status/log/diff
- [Add project-specific safe actions]

---

## Testing Requirements

**Before marking work complete:**
- [Your test command]
- [Your lint command]
- [Your type check command]

**When adding features:**
- Add tests for new functions
- Test both success and error cases
- Mock external dependencies

---

## Git Workflow

**Commit messages:**
- Imperative mood: "Add feature" not "Added feature"
- First line: concise summary (50 chars)
- [Additional commit message guidelines]

**Never:**
- Force push to main
- Commit secrets or credentials
- Commit without running tests
```

## Variables

| Variable | Description |
|----------|-------------|
| `[PROJECT NAME]` | Your project's name |
| `[Brief description...]` | What your project does |
| `[Target users...]` | Who uses this project |
| All `[bracketed items]` | Customize for your project |

## Example Usage

1. Copy this template to your project root as `CLAUDE.md`
2. Replace all `[bracketed placeholders]` with your project-specific information
3. Remove sections that don't apply
4. Add sections specific to your project

## Tips

1. **Be specific** - Generic instructions are less useful than concrete examples from your codebase

2. **Include real patterns** - Show actual code snippets from your project, not generic examples

3. **Update as you go** - When you correct Claude or establish new patterns, add them to CLAUDE.md

4. **Keep it current** - Outdated instructions are worse than no instructions

5. **Prioritize** - Put the most important things first; Claude may not read everything in long files
