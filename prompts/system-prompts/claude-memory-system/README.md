# Claude Memory System

A persistent memory system for Claude Code that enables cross-session context retention. Claude designs its own memory format optimized for its parsing efficiency, and a SessionStart hook ensures automatic loading.

## Overview

This system solves the problem of Claude "forgetting" project context between sessions. Instead of relying on Claude to follow instructions to load memory, it uses mechanical enforcement via hooks.

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

That's it. Claude will set up everything and scan your codebase.

---

## Manual Setup

If you prefer not to use the skills CLI, follow these steps:

### 1. Bootstrap the Memory System

Run the [bootstrap prompt](bootstrap-prompt.md) in a new Claude Code session in your project directory. Claude will:
- Scan your entire codebase
- Design its own memory format (optimized for its parsing, not human readability)
- Create `.claude/mem/` directory with initial memory files
- Report what it found and what format it chose

### 2. Add CLAUDE.md Instructions (Optional)

Copy the [CLAUDE.md template](claude-md-template.md) to your project root and customize the "Project Context" section for your specific project.

### 3. Set Up the SessionStart Hook

Follow the [hook setup instructions](session-hook-setup.md) to configure automatic memory loading. This creates:
- `.claude/settings.json` with hook configuration
- `.claude/hooks/load-memory.sh` script

### 4. Verify It Works

Start a new Claude Code session. You should see Claude's memory content appear in the context before any interaction.

---

## Components

| File | Purpose |
|------|---------|
| [bootstrap-prompt.md](bootstrap-prompt.md) | One-time prompt to initialize the memory system |
| [claude-md-template.md](claude-md-template.md) | CLAUDE.md template with memory protocol |
| [session-hook-setup.md](session-hook-setup.md) | Hook configuration for auto-loading |
| [examples.md](examples.md) | Real-world memory format examples from an actual project |

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    SESSION START                            │
├─────────────────────────────────────────────────────────────┤
│  1. SessionStart hook fires                                 │
│  2. load-memory.sh reads all .claude/mem/* files            │
│  3. Content injected into Claude's context as system msg    │
│  4. Claude has full memory before seeing user message       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    DURING SESSION                           │
├─────────────────────────────────────────────────────────────┤
│  • Claude works with full project understanding             │
│  • Updates in-memory model as it learns                     │
│  • Captures decisions, corrections, new context             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    SESSION END                              │
├─────────────────────────────────────────────────────────────┤
│  • Triggered by: "done", "thanks", "checkpoint", etc.       │
│  • Claude persists everything learned to .claude/mem/       │
│  • Memory files updated for next session                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Memory Structure

Claude chooses its own format, but typically creates files like:

```
.claude/mem/
├── _index     # Symbol table and format metadata
├── core       # Architecture, patterns, key decisions
├── direction  # Roadmap, priorities, what's next
├── api        # Commands, types, contracts
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

## Checkpoint Triggers

Claude automatically saves memory when it detects session end signals:

- "done", "thanks", "that's all", "bye", "exit"
- "checkpoint", "save", "end", "stop"
- Any clear signal the conversation is wrapping up

You can also explicitly say "checkpoint" at any time to save current state.

---

## Files Created

After setup, your project will have:

```
your-project/
└── .claude/
    ├── settings.json       # Hook configuration
    ├── hooks/
    │   └── load-memory.sh  # Auto-load script
    └── mem/
        ├── _index          # Symbol table
        ├── core            # Architecture & patterns
        ├── direction       # Roadmap & priorities
        └── session         # Current context
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
```

---

## Tips

1. **Let Claude choose the format** - Don't try to make the memory human-readable. Claude knows what's efficient for itself.

2. **Trust the hook** - Once set up, you don't need to ask Claude to load memory. It happens automatically.

3. **Checkpoint often** - When working on something complex, say "checkpoint" periodically to ensure nothing is lost.

4. **Review direction file** - If you want to see what Claude thinks the roadmap is, you can read `.claude/mem/direction` (it may be cryptic but gives insight).

5. **Git ignore or commit** - Decide whether `.claude/mem/` should be in version control. Committing it shares context across machines; ignoring keeps sessions isolated.

---

## Troubleshooting

**Memory not loading?**
- Check that `.claude/hooks/load-memory.sh` is executable (`chmod +x`)
- Verify `.claude/settings.json` has correct hook configuration
- Ensure `.claude/mem/` directory exists with files

**Claude seems to have forgotten context?**
- Say "checkpoint" to force a save
- Check if memory files exist and have content
- Verify git hash matches (Claude may need to rescan if codebase changed significantly)

**Format seems wrong?**
- Remember: the format is intentionally not human-readable
- Claude's format may evolve over time as it finds better patterns
- Trust that Claude can parse what it created

**Want to reset memory?**
- Delete `.claude/mem/*` files
- Run `/memory-init` again (or the bootstrap prompt)

---

## Contributing

Have improvements to this memory system? See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines.
