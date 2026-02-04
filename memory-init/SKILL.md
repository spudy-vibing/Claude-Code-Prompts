---
name: memory-init
description: Initialize Claude's persistent memory system with self-designed format and auto-loading SessionStart hooks. Use when starting a new project or when user says "set up memory", "init memory", "remember this project", or "create memory system".
---

# Memory System Initialization

You are setting up a persistent memory system for this codebase. This memory exists solely for YOU to load and parse across sessions. No human will ever read these files directly.

## Step 0: Check for Existing Memory

Before creating anything, check if `.claude/mem/` already exists.

If it does:
- Read the existing memory files
- Ask the user: "This project already has Claude memory. Should I:
  (a) Keep existing memory and update the hooks only
  (b) Rebuild memory from scratch (existing memory will be backed up to `.claude/mem.bak/`)
  (c) Cancel"
- If (a): Skip to Step 2 (hooks), preserve `.claude/mem/`
- If (b): Copy `.claude/mem/` to `.claude/mem.bak/`, then proceed normally
- If (c): Stop

## Step 1: Create Directory Structure

Create the following directories:
- `.claude/mem/`
- `.claude/hooks/`

## Step 2: Create the Hooks

This system uses 4 hooks for full lifecycle coverage. Create all of them.

### Configuration File

Create `.claude/hooks/config.sh` — a shared config sourced by all hooks. Users edit this one file to tune thresholds:

```bash
#!/bin/bash
# Memory system configuration
# Edit these values to tune hook behavior.
# All hooks fall back to defaults if this file is missing.

MEM_MAX_CHARS=8000           # Token budget (~2000 tokens). load-memory.sh warns above this.
CHECKPOINT_FRESHNESS=600     # Seconds. Stop hook skips if session saved within this window.
STOP_TURN_THRESHOLD=25       # Transcript lines. Stop hook only blocks after this many turns.
SAVE_TURN_THRESHOLD=4        # Transcript lines. SessionEnd hook skips trivial sessions below this.
TOOLS_CAP=20                 # Max tool entries logged in session metadata.
```

### 2A: SessionStart — Load Memory

Create `.claude/hooks/load-memory.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Load config (optional — defaults used if missing)
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -f "$HOOKS_DIR/config.sh" ]] && source "$HOOKS_DIR/config.sh"

cd "$(dirname "$0")/../.." || exit 1

MEM_DIR=".claude/mem"
[[ -d "$MEM_DIR" ]] || exit 0

MAX_CHARS="${MEM_MAX_CHARS:-8000}"
TOTAL_CHARS=0

for f in "$MEM_DIR"/*; do
  [[ -f "$f" ]] || continue
  FILE_CHARS=$(wc -c < "$f" | tr -d ' ')
  TOTAL_CHARS=$((TOTAL_CHARS + FILE_CHARS))
done

if [[ "$TOTAL_CHARS" -gt "$MAX_CHARS" ]]; then
  echo "!!! MEMORY EXCEEDS TOKEN BUDGET (${TOTAL_CHARS} chars > ${MAX_CHARS}). Compact your .claude/mem/ files. !!!"
fi

for f in "$MEM_DIR"/*; do
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

### 2B: Stop — Checkpoint Reminder

Create `.claude/hooks/check-checkpoint.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Load config (optional — defaults used if missing)
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -f "$HOOKS_DIR/config.sh" ]] && source "$HOOKS_DIR/config.sh"

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[[ -z "$CWD" ]] && exit 0
cd "$CWD" || exit 0
[[ -d .claude/mem ]] || exit 0
[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && exit 0

SESSION_FILE=".claude/mem/session"

if [[ -f "$SESSION_FILE" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    MOD_TIME=$(stat -f %m "$SESSION_FILE" 2>/dev/null || echo 0)
  else
    MOD_TIME=$(stat -c %Y "$SESSION_FILE" 2>/dev/null || echo 0)
  fi
  NOW=$(date +%s)
  DIFF=$((NOW - MOD_TIME))
  [[ "$DIFF" -lt "${CHECKPOINT_FRESHNESS:-600}" ]] && exit 0
fi

TURN_COUNT=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')

if [[ "$TURN_COUNT" -gt "${STOP_TURN_THRESHOLD:-25}" ]]; then
  jq -n '{
    "decision": "block",
    "reason": "You have unsaved session learnings. Update .claude/mem/session with what you learned this session before stopping. Include: decisions made, user preferences discovered, corrections to your understanding, and current task state."
  }'
  exit 0
fi

exit 0
```

### 2C: PreCompact — Preserve Memory Through Compaction

Create `.claude/hooks/pre-compact.sh`:

```bash
#!/bin/bash
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[[ -z "$CWD" ]] && exit 0
cd "$CWD" || exit 0
[[ -d .claude/mem ]] || exit 0

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "MEMORY SYSTEM ACTIVE. Files in .claude/mem/ contain your project knowledge. After compaction, update .claude/mem/session if you learned anything new this session." > "$TMPFILE"
echo "" >> "$TMPFILE"

for f in .claude/mem/*; do
  if [[ -f "$f" ]]; then
    echo "=== $(basename "$f") ===" >> "$TMPFILE"
    cat "$f" >> "$TMPFILE"
    echo "" >> "$TMPFILE"
  fi
done

jq -n --rawfile ctx "$TMPFILE" '{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": $ctx
  }
}'

exit 0
```

### 2D: SessionEnd — Auto-Save Session Metadata

Create `.claude/hooks/save-memory.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Load config (optional — defaults used if missing)
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -f "$HOOKS_DIR/config.sh" ]] && source "$HOOKS_DIR/config.sh"

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[[ -z "$CWD" ]] && exit 0
cd "$CWD" || exit 0
[[ -d .claude/mem ]] || exit 0
[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && exit 0

SESSION_FILE=".claude/mem/session"
TIMESTAMP=$(date +%Y-%m-%d)

TURN_COUNT=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
[[ "$TURN_COUNT" -lt "${SAVE_TURN_THRESHOLD:-4}" ]] && exit 0

TOOLS_USED=$(jq -r '
  select(.type == "tool_use") |
  .name + ":" + (.input.file_path // .input.command // .input.pattern // "" | split("\n")[0])
' "$TRANSCRIPT" 2>/dev/null | sort -u | head -"${TOOLS_CAP:-20}")

GIT_HASH=$(git log -1 --format=%h 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

if [[ -f "$SESSION_FILE" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' '/^=last_session$/,/^=[a-z]/{ /^=[a-z]/!d; /^=last_session/d; }' "$SESSION_FILE" 2>/dev/null || true
    sed -i '' '/^=tools_used$/,/^=[a-z]/{ /^=[a-z]/!d; /^=tools_used/d; }' "$SESSION_FILE" 2>/dev/null || true
  else
    sed -i '/^=last_session$/,/^=[a-z]/{ /^=[a-z]/!d; /^=last_session/d; }' "$SESSION_FILE" 2>/dev/null || true
    sed -i '/^=tools_used$/,/^=[a-z]/{ /^=[a-z]/!d; /^=tools_used/d; }' "$SESSION_FILE" 2>/dev/null || true
  fi
fi

cat >> "$SESSION_FILE" <<FOOTER

=last_session
_t:$TIMESTAMP
_sid:${SESSION_ID:0:8}
_h:$GIT_HASH
_b:$GIT_BRANCH
_turns:$TURN_COUNT
FOOTER

if [[ -n "$TOOLS_USED" ]]; then
  echo "=tools_used" >> "$SESSION_FILE"
  echo "$TOOLS_USED" | while read -r line; do
    [[ -n "$line" ]] && echo "+$line" >> "$SESSION_FILE"
  done
fi

exit 0
```

Make all hooks executable:
```bash
chmod +x .claude/hooks/load-memory.sh .claude/hooks/check-checkpoint.sh .claude/hooks/pre-compact.sh .claude/hooks/save-memory.sh
```

## Step 3: Configure Hooks

If `.claude/settings.json` already exists, **merge** the following hooks into the existing configuration. Do NOT overwrite existing hooks or settings. Preserve any existing hooks, permissions, and other top-level keys.

If the file doesn't exist, create it:

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
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-checkpoint.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-compact.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/save-memory.sh"
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
- How to handle versioning and diffing
- Compression vs parse speed tradeoffs

### What to Capture

**Structure**: How the code is organized, what connects to what, where state lives

**Semantics**: What the code actually does, edge cases, non-obvious behaviors, gotchas

**Decisions**: Why things are the way they are, what alternatives were rejected, tradeoffs made

**Direction**: Where the project is heading, what's planned, what "good" looks like here, priorities

**Session Context**: What was worked on, what was learned, questions raised, hypotheses formed, user corrections to your understanding

**Meta-Knowledge**: Your confidence levels, what's inferred vs confirmed, what you're uncertain about

### Critical Instruction

The memory format is YOUR choice based on YOUR cognitive architecture. Consider:
- How do you most efficiently parse structured information?
- What token patterns are fastest for you to decode?
- How do you naturally represent relationships and hierarchies?
- What compression is lossless for your understanding but saves tokens?
- How do you represent uncertainty and confidence?
- What's your ideal balance of explicit vs implicit information?

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

### Token Budget

Keep total `.claude/mem/` content under ~2000 tokens (~8000 characters / ~100 lines of compact format). This ensures memory loads quickly and leaves maximum context for actual work.

If memory exceeds this budget:
- **Compact**: merge related entries, increase abbreviation density
- **Prune**: remove low-confidence inferences, old session details
- **Promote**: move stable facts to `CLAUDE.md` or `.claude/rules/` where they load natively without token cost from hook injection

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

### Session End

Memory persistence is handled by two mechanical hooks:

1. **Stop hook** — When you finish responding after 10+ turns, you'll be reminded to checkpoint if you haven't recently. Write your learnings to `.claude/mem/session`.
2. **SessionEnd hook** — When the session terminates, `save-memory.sh` automatically records session metadata (tools used, files touched, git state, turn count) to `.claude/mem/session`.

You should still checkpoint explicitly when you detect session-end signals ("done", "thanks", "checkpoint", "save") — the hooks are a safety net, not a replacement for thorough persistence.

**Checkpoint behavior:**
1. Persist everything learned this session to `.claude/mem/`
2. Optimize/compact if beneficial
3. Update version/timestamp
4. Brief acknowledgment of what was captured

### Context Compaction
The PreCompact hook re-injects your memory as context when compaction occurs, so you retain memory awareness even after long sessions. If you notice memory was re-injected, check if `.claude/mem/session` needs updating with recent learnings.

Never lose session learnings—mechanical hooks provide defense-in-depth, but explicit checkpointing remains the gold standard.
