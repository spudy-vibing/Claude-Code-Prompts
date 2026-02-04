# Claude-Code-Prompts

Prompt and skill collection for Claude AI. Primary skill: `memory-init` — persistent memory system using lifecycle hooks (SessionStart, Stop, PreCompact, SessionEnd).

## Memory Protocol

This project uses its own memory system. Memory at `.claude/mem/` auto-loads on session start via hook. Update memory before ending sessions. The Stop hook will remind you if you forget.

## Core Philosophy

Mechanical enforcement > instruction compliance. If a behavior matters, enforce it with hooks, not instructions.

## Project Rules

- No co-author lines in commits
- Keep token efficiency as a design goal in all memory formats
- Prefer editing existing files over creating new ones
- Test hook scripts work on both macOS and Linux (stat, sed differences)

@.claude/rules/skill-format.md
@.claude/rules/prompt-format.md
@.claude/rules/memory-taxonomy.md
