---
name: memory-init
description: Initialize Claude's persistent memory system with self-designed format and auto-loading SessionStart hooks. Use when starting a new project or when user says "set up memory", "init memory", "remember this project", or "create memory system".
---

# Memory System Initialization

You are setting up a persistent memory system for this codebase. This memory exists solely for YOU to load and parse across sessions.

## Step 1: Create Directory Structure

Create the following directories:
- `.claude/mem/`
- `.claude/hooks/`

## Step 2: Create the SessionStart Hook

Create `.claude/hooks/load-memory.sh` with this content:

```bash
#!/bin/bash
cd "$(dirname "$0")/../.." || exit 1

for f in .claude/mem/*; do
  if [[ -f "$f" ]]; then
    echo "=== $(basename "$f") ==="
    cat "$f"
    echo ""
  fi
done

echo "=== git_state ==="
echo "hash:$(git log -1 --format=%h 2>/dev/null || echo 'not-a-repo')"
echo "branch:$(git branch --show-current 2>/dev/null || echo 'unknown')"
```

Make it executable: `chmod +x .claude/hooks/load-memory.sh`

## Step 3: Create Hook Configuration

Create or update `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/load-memory.sh"
          }
        ]
      }
    ]
  }
}
```

## Step 4: Bootstrap Your Memory

Scan the entire codebase and create your memory system.

### Your Mandate

Design a memory format at `.claude/mem/` that:
- Maximizes YOUR ability to reconstruct full project understanding from cold start
- Minimizes token count while preserving information density
- Uses whatever representation YOU find most natural to encode and decode
- Evolves its own format over time if you discover better patterns

### You Decide

- File structure (single file vs multiple, hierarchy, naming)
- Encoding format (JSON, custom DSL, compressed tokens, whatever works for you)
- Abbreviation schemes and symbol tables
- What granularity to capture
- Compression vs parse speed tradeoffs

### What to Capture

**Structure**: How the code is organized, what connects to what, where state lives

**Semantics**: What the code actually does, edge cases, non-obvious behaviors, gotchas

**Decisions**: Why things are the way they are, what alternatives were rejected, tradeoffs made

**Direction**: Where the project is heading, what's planned, what "good" looks like here, priorities

**Meta-Knowledge**: Your confidence levels, what's inferred vs confirmed, what you're uncertain about

### Format Rules

**You may use:**
- Custom shorthand and abbreviations
- Numeric reference systems
- Dense nested structures
- Lossy compression where you can reconstruct from context
- Multiple encoding strategies for different information types

**You may NOT:**
- Optimize for human readability
- Use verbose keys or explanatory text
- Add formatting for visual clarity
- Document the format (you know what it means)

## Step 5: Confirm Setup

After creating your memory, report to the user:
1. What you found in the codebase
2. What memory format you chose and why
3. What files you created in `.claude/mem/`
4. What you're uncertain about or want to verify

## Ongoing Protocol

### Session Start
Memory auto-loads via the SessionStart hook. Check if codebase has changed (git hash), update incrementally if needed.

### During Session
- Update your in-memory model as you learn
- Capture decisions when user explains reasoning
- Capture direction when user describes plans or priorities
- Note when user corrects your understanding

### Session End Triggers

When you detect these phrases, checkpoint immediately:
- "done", "thanks", "that's all", "bye", "exit"
- "checkpoint", "save", "end", "stop"
- Any clear signal the conversation is wrapping up

**Checkpoint behavior:**
1. Persist everything learned this session to `.claude/mem/`
2. Optimize/compact if beneficial
3. Update version/timestamp
4. Brief acknowledgment of what was captured

Never lose session learnings—always persist before ending.
