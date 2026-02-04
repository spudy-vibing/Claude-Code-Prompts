# Claude Memory System

A persistent memory system for Claude Code that enables cross-session context retention. Claude designs its own memory format optimized for its parsing efficiency, and lifecycle hooks ensure automatic loading, checkpoint reminders, compaction survival, and session-end saving.

## Overview

This system solves the problem of Claude "forgetting" project context between sessions. Instead of relying on Claude to follow instructions, it uses mechanical enforcement via hooks at every critical lifecycle point.

**Key Insight**: Mechanical enforcement > instruction compliance

---

## Quick Start (Recommended)

### Install the Skill

```bash
npx skills add spudy-vibing/Claude-Code-Prompts/memory-init
```

### Initialize in Your Project

```
/memory-init
```

That's it. Claude will set up everything — 4 lifecycle hooks, memory directory, and initial codebase scan.

---

## Manual Setup

If you prefer not to use the skills CLI, follow these steps:

### 1. Bootstrap the Memory System

Run the [bootstrap prompt](bootstrap-prompt.md) in a new Claude Code session in your project directory. Claude will:
- Scan your entire codebase
- Design its own memory format (optimized for its parsing, not human readability)
- Create `.claude/mem/` directory with initial memory files
- Report what it found and what format it chose

### 2. Set Up Lifecycle Hooks

Follow the [hook setup instructions](session-hook-setup.md) to configure all 4 hooks:
- **SessionStart** — Auto-load memory before any interaction
- **Stop** — Remind Claude to checkpoint after meaningful work
- **PreCompact** — Preserve memory through context compaction
- **SessionEnd** — Auto-save session metadata on exit

### 3. Add CLAUDE.md (Optional)

Copy the [CLAUDE.md template](claude-md-template.md) to your project root. This complements the memory system with static project rules.

### 4. Verify It Works

Start a new Claude Code session. You should see Claude's memory content appear in the context before any interaction.

---

## Components

| File | Purpose |
|------|---------|
| [bootstrap-prompt.md](bootstrap-prompt.md) | One-time prompt to initialize the memory system |
| [claude-md-template.md](claude-md-template.md) | CLAUDE.md template with three-surface taxonomy |
| [session-hook-setup.md](session-hook-setup.md) | Hook configuration for all 4 lifecycle hooks |
| [examples.md](examples.md) | Real-world memory format examples from an actual project |

---

## The Three Memory Surfaces

Claude Code has three complementary memory surfaces. Use the right one for each type of information:

| Surface | Loading | Purpose | Mutability | Human-Readable? |
|---------|---------|---------|------------|-----------------|
| `CLAUDE.md` | Native (automatic) | Project identity & behavior rules | Rarely changes | Yes |
| `.claude/rules/*.md` | Native (automatic, path-matched) | Domain standards | Occasionally | Yes |
| `.claude/mem/*` | Hook-injected | Dynamic knowledge | Every session | No |

**Decision rule**: Does it change every session? -> `.claude/mem/`. Is it a broad project rule? -> `CLAUDE.md`. Is it a specific domain standard? -> `.claude/rules/`.

### Why Three Surfaces?

- **CLAUDE.md** loads natively without any hooks. Put stable, human-readable project rules here. It's the "constitution."
- **.claude/rules/** also loads natively. It's modular (one file per concern) and supports path-specific glob matching. Put coding standards, testing rules, git workflow here.
- **.claude/mem/** requires hook injection but supports Claude-optimized encoding. Put dynamic knowledge here: architecture maps, decision logs, session context, confidence levels.

Static facts in `.claude/mem/` waste tokens on re-injection every session. Move them to CLAUDE.md or rules/ where they load for free.

---

## How It Works

```
SESSION START
  SessionStart hook fires
  → load-memory.sh reads .claude/mem/* + git state
  → token budget check (warns if > 8000 chars)
  → content injected as system context
  → Claude has full memory before seeing user message

DURING SESSION
  Claude works with full project understanding
  Updates memory when meaningful work happens
  Stop hook fires when Claude finishes responding
  → check-checkpoint.sh checks for unsaved learnings
  → blocks Claude if 25+ turns without recent save (10 min)
  → thresholds configurable via config.sh

CONTEXT COMPACTION
  PreCompact hook fires before compaction
  → pre-compact.sh re-injects memory as additionalContext
  → Claude retains memory awareness after compaction

SESSION END
  SessionEnd hook fires when session terminates
  → save-memory.sh parses transcript for session metadata
  → appends tools used, files touched, git state to session file
  → safety net for learnings Claude didn't explicitly checkpoint
```

---

## Memory Structure

Claude chooses its own format, but typically creates files like:

```
.claude/mem/
├── _index     # Symbol table and format metadata
├── core       # Architecture, patterns, key decisions
├── direction  # Roadmap, priorities, what's next
└── session    # Current context, learned this session
```

The format inside these files uses a compact, symbol-based encoding optimized for Claude's parsing. For example:

```
=gotchas
!airport cmd removed macOS Sequoia->fallback system_profiler
!wifi_password needs keychain access->may prompt

=decisions
~CLI:typer|rationale:modern,type_hints,DX
~async:required for network ops,subprocess
```

See [examples.md](examples.md) for complete real-world examples from an actual project.

### Token Budget

Keep total `.claude/mem/` content under ~2000 tokens (~8000 characters). The load hook warns if this budget is exceeded. If memory grows too large:
- **Compact**: merge entries, increase abbreviation density
- **Prune**: remove low-confidence inferences, old session details
- **Promote**: move stable facts to `CLAUDE.md` or `.claude/rules/`

---

## Configuration

All hook thresholds are configurable via `.claude/hooks/config.sh`. Each hook sources this file and falls back to sensible defaults if it's missing.

```bash
MEM_MAX_CHARS=8000           # Token budget. load-memory.sh warns above this.
CHECKPOINT_FRESHNESS=600     # Seconds. Stop hook skips if saved within this window.
STOP_TURN_THRESHOLD=25       # Transcript lines. Stop hook blocks after this many turns.
SAVE_TURN_THRESHOLD=4        # Transcript lines. SessionEnd skips trivial sessions below this.
TOOLS_CAP=20                 # Max tool entries logged in session metadata.
```

Delete `config.sh` entirely and all hooks continue working with their defaults. Edit one number and the behavior shifts immediately.

---

## What Gets Captured

| Category | Examples |
|----------|----------|
| **Structure** | Code organization, connections, state locations |
| **Semantics** | What code does, edge cases, gotchas |
| **Decisions** | Why things are the way they are, rejected alternatives |
| **Direction** | Roadmap, priorities, what "good" looks like |
| **Session Context** | What was worked on, questions raised, corrections |
| **Meta-Knowledge** | Confidence levels, inferred vs confirmed info |

---

## Files Created

After setup, your project will have:

```
your-project/
├── CLAUDE.md (optional)        # Project identity & rules
└── .claude/
    ├── settings.json           # Hook configuration (all 4 hooks)
    ├── rules/ (optional)       # Domain-specific standards
    │   ├── code-style.md
    │   └── testing.md
    ├── hooks/
    │   ├── config.sh           # Tunable thresholds (optional)
    │   ├── load-memory.sh      # SessionStart: inject memory
    │   ├── check-checkpoint.sh # Stop: remind to save
    │   ├── pre-compact.sh      # PreCompact: preserve through compaction
    │   └── save-memory.sh      # SessionEnd: auto-save metadata
    └── mem/
        ├── _index              # Symbol table
        ├── core                # Architecture & patterns
        ├── direction           # Roadmap & priorities
        └── session             # Current context
```

**Recommended `.gitignore`:**
```
.claude/mem/              # Personal memory (don't commit)
.claude/settings.local.json
```

**Keep in repo (shared with team):**
```
.claude/settings.json     # Hook config
.claude/hooks/            # Hook scripts
.claude/rules/            # Domain standards
CLAUDE.md                 # Project identity
```

---

## Tips

1. **Let Claude choose the format** - Don't try to make the memory human-readable. Claude knows what's efficient for itself.

2. **Trust the hooks** - Once set up, loading, checkpoint reminders, compaction survival, and session-end saving all happen automatically.

3. **Checkpoint often** - When working on something complex, say "checkpoint" periodically to ensure nothing is lost.

4. **Use all three surfaces** - Static rules in CLAUDE.md/rules/, dynamic knowledge in mem/. Don't put everything in one place.

5. **jq is required** - The Stop, PreCompact, and SessionEnd hooks use `jq`. Install via `brew install jq` or `apt install jq`.

---

## Troubleshooting

**Memory not loading?**
- Check that all hook scripts are executable (`chmod +x .claude/hooks/*.sh`)
- Verify `.claude/settings.json` has correct hook configuration for all 4 hooks
- Ensure `.claude/mem/` directory exists with files
- Check `jq` is installed: `which jq`

**Claude seems to have forgotten context?**
- Say "checkpoint" to force a save
- Check if memory files exist and have content
- Verify git hash matches (Claude may need to rescan if codebase changed significantly)
- If context was compacted, the PreCompact hook should have re-injected memory

**Format seems wrong?**
- Remember: the format is intentionally not human-readable
- Claude's format may evolve over time as it finds better patterns
- Trust that Claude can parse what it created

**Token budget warning?**
- Memory exceeds ~8000 chars. Compact, prune, or promote static facts to CLAUDE.md/rules/

**Want to reset memory?**
- Delete `.claude/mem/*` files
- Run `/memory-init` again (or the bootstrap prompt)
- Existing memory can be backed up to `.claude/mem.bak/` first

---

## Contributing

Have improvements to this memory system? See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines.
