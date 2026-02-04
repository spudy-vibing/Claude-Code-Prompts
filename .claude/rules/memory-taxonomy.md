# Memory Taxonomy: Three Surfaces

Claude Code has three memory surfaces. Use the right one for each type of information.

## CLAUDE.md — Identity & Behavior
- Loads natively (no hook needed)
- Human-readable, rarely changes
- What the project IS, tech stack, always/never rules
- Import references to .claude/rules/ for details

## .claude/rules/*.md — Domain Standards
- Loads natively, supports path-specific glob matching
- Modular: one file per concern (code-style, testing, api, security)
- Semi-static, edited by humans

## .claude/mem/* — Dynamic Knowledge
- Loaded via SessionStart hook
- Claude-optimized format, NOT human-readable
- Changes every session: architecture map, decisions, session context
- Token-budgeted (~2000 tokens / ~8000 chars max)

## Decision Rule

Ask: "Does this change every session?"
- Yes -> `.claude/mem/`
- No -> "Is it a broad project rule or specific domain standard?"
  - Broad rule -> `CLAUDE.md`
  - Domain-specific -> `.claude/rules/`
