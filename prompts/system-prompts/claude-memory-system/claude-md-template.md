# CLAUDE.md Template with Memory Protocol

## Description

Template for your project's CLAUDE.md file. Works alongside `.claude/rules/` for domain standards and `.claude/mem/` for dynamic knowledge. Together these three surfaces give Claude complete project context.

## The Three Memory Surfaces

Before customizing, understand what goes where:

| Surface | Purpose | Mutability | Human-Readable? |
|---------|---------|------------|-----------------|
| `CLAUDE.md` | Project identity & behavior | Rarely changes | Yes |
| `.claude/rules/*.md` | Domain standards (modular) | Occasionally | Yes |
| `.claude/mem/*` | Dynamic knowledge | Every session | No (Claude-optimized) |

**Decision rule**: Does it change every session? -> `.claude/mem/`. Is it a broad project rule? -> `CLAUDE.md`. Is it a specific domain standard? -> `.claude/rules/`.

## Template

```markdown
# [PROJECT NAME]

[One-line description of what the project is and does.]

## Memory Protocol

This project uses persistent memory at `.claude/mem/`. Memory auto-loads on session start via hook. Update memory before ending sessions. A Stop hook will remind you if you forget, and a SessionEnd hook records session metadata automatically.

## Key Rules

- [Most important behavioral rule]
- [Second most important rule]
- [Third rule]

## Current State

- Phase: [current phase/milestone]
- Focus: [what's actively being worked on]
- Stack: [key technologies]

## Workflow

- ASK before: [things requiring discussion]
- PROCEED with: [things Claude can do autonomously]
- Always: [universal requirements like running tests]

@.claude/rules/code-style.md
@.claude/rules/testing.md
```

## Variables

| Variable | Description |
|----------|-------------|
| `[PROJECT NAME]` | Your project's name |
| `[One-line description...]` | What your project does |
| All `[bracketed items]` | Customize for your project |

## Companion: .claude/rules/

Move domain-specific standards into `.claude/rules/` as separate files. Examples:

**`.claude/rules/code-style.md`**
```markdown
# Code Style

- Use TypeScript strict mode
- Prefer named exports
- Error handling: use Result types, not try/catch
```

**`.claude/rules/testing.md`**
```markdown
# Testing

Run: `npm test`
Lint: `npm run lint`
Type check: `npx tsc --noEmit`

- Add tests for all new functions
- Test both success and error cases
- Mock external dependencies
```

**`.claude/rules/git.md`**
```markdown
# Git Workflow

- Commit messages: imperative mood, 50 char first line
- Never force push to main
- Never commit secrets or credentials
```

Rules files support path-specific matching with frontmatter:

**`.claude/rules/api-style.md`**
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Rules
- All endpoints return typed responses
- Use middleware for auth checks
```

## Example Usage

1. Copy the CLAUDE.md template to your project root
2. Replace all `[bracketed placeholders]` with your specifics
3. Create `.claude/rules/` with one file per concern
4. Move coding standards, testing, git rules into their own rule files
5. Keep CLAUDE.md focused on identity, state, and workflow

## Tips

1. **Keep CLAUDE.md short** - It's the constitution, not the encyclopedia. Details go in rules/ and mem/.

2. **Use @imports** - Reference rules files from CLAUDE.md so they're discoverable.

3. **Be specific** - Real patterns from your codebase, not generic examples.

4. **Update CLAUDE.md when direction changes** - New phase? Different focus? Update it.

5. **Let .claude/mem/ handle the dynamic stuff** - Don't duplicate architecture maps or decision logs in CLAUDE.md. That's what mem/ is for.
