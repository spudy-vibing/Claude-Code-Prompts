# Lifecycle Hook Setup

## Description

Configure Claude Code's hooks for full memory lifecycle coverage. Four hooks ensure memory is loaded, checkpointed, preserved through compaction, and saved on exit — all mechanically, without relying on instruction compliance.

## The Problem

CLAUDE.md instructions telling Claude to "read memory files first" or "save before ending" are unreliable. Claude often skips or forgets.

## The Solution

Use lifecycle hooks for mechanical enforcement at every critical point:

| Hook | Event | Purpose |
|------|-------|---------|
| `load-memory.sh` | SessionStart | Inject memory before any user message |
| `check-checkpoint.sh` | Stop | Remind Claude to save if work happened without recent checkpoint |
| `pre-compact.sh` | PreCompact | Re-inject memory so it survives context compaction |
| `save-memory.sh` | SessionEnd | Auto-record session metadata on exit |

**Key Insight**: Mechanical enforcement > instruction compliance

---

## Setup Files

### File 1: `.claude/hooks/load-memory.sh` (SessionStart)

Injects all `.claude/mem/*` files into Claude's context before any interaction. Warns if memory exceeds token budget.

```bash
#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/../.." || exit 1

MEM_DIR=".claude/mem"
[[ -d "$MEM_DIR" ]] || exit 0

MAX_CHARS=8000
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

### File 2: `.claude/hooks/check-checkpoint.sh` (Stop)

When Claude finishes responding after 10+ turns without a recent checkpoint (5 min), blocks Claude and reminds it to save learnings.

```bash
#!/bin/bash
set -euo pipefail

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
  [[ "$DIFF" -lt 300 ]] && exit 0
fi

TURN_COUNT=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')

if [[ "$TURN_COUNT" -gt 10 ]]; then
  jq -n '{
    "decision": "block",
    "reason": "You have unsaved session learnings. Update .claude/mem/session with what you learned this session before stopping. Include: decisions made, user preferences discovered, corrections to your understanding, and current task state."
  }'
  exit 0
fi

exit 0
```

### File 3: `.claude/hooks/pre-compact.sh` (PreCompact)

Re-injects memory as `additionalContext` before context compaction so Claude retains memory awareness afterward.

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

### File 4: `.claude/hooks/save-memory.sh` (SessionEnd)

Automatically records session metadata (tools used, files touched, git state, turn count) when the session terminates. This is a safety net — Claude should still checkpoint explicitly during the session.

```bash
#!/bin/bash
set -euo pipefail

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
[[ "$TURN_COUNT" -lt 4 ]] && exit 0

TOOLS_USED=$(jq -r '
  select(.type == "tool_use") |
  .name + ":" + (.input.file_path // .input.command // .input.pattern // "" | split("\n")[0])
' "$TRANSCRIPT" 2>/dev/null | sort -u | head -20)

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

### File 5: `.claude/settings.json`

If this file already exists, **merge** these hooks into the existing configuration. Don't overwrite existing hooks or other settings.

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

Make all scripts executable:

```bash
chmod +x .claude/hooks/load-memory.sh .claude/hooks/check-checkpoint.sh .claude/hooks/pre-compact.sh .claude/hooks/save-memory.sh
```

---

## How It Works

```
SESSION START
  SessionStart hook fires
  → load-memory.sh reads .claude/mem/* + git state
  → content injected as system context
  → Claude has full memory before seeing user message

DURING SESSION
  Claude works with full project understanding
  Updates memory when meaningful work happens
  Stop hook fires when Claude finishes responding
  → check-checkpoint.sh checks for unsaved learnings
  → blocks Claude if 10+ turns without recent save

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

## Complete Directory Structure

```
.claude/
├── settings.json              # Hook configuration (all 4 hooks)
├── hooks/
│   ├── load-memory.sh         # SessionStart: inject memory
│   ├── check-checkpoint.sh    # Stop: remind to save
│   ├── pre-compact.sh         # PreCompact: preserve through compaction
│   └── save-memory.sh         # SessionEnd: auto-save metadata
└── mem/
    ├── _index                 # Symbol table, format metadata
    ├── core                   # Architecture, patterns, decisions
    ├── direction              # Roadmap, priorities
    └── session                # Current context, learnings
```

---

## Quick Setup Script

Run this in your project root to set up the full hook system:

```bash
# Create directory structure
mkdir -p .claude/hooks .claude/mem

# Download hooks from the repo (or create manually from above)
for hook in load-memory.sh check-checkpoint.sh pre-compact.sh save-memory.sh; do
  curl -sL "https://raw.githubusercontent.com/spudy-vibing/Claude-Code-Prompts/main/.claude/hooks/$hook" \
    -o ".claude/hooks/$hook"
done

# Make executable
chmod +x .claude/hooks/*.sh

# Create settings.json (or merge manually if it exists)
cat > .claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": ".claude/hooks/load-memory.sh"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": ".claude/hooks/check-checkpoint.sh"}]}],
    "PreCompact": [{"hooks": [{"type": "command", "command": ".claude/hooks/pre-compact.sh"}]}],
    "SessionEnd": [{"hooks": [{"type": "command", "command": ".claude/hooks/save-memory.sh"}]}]
  }
}
SETTINGS

echo "Hook system ready. Run the bootstrap prompt to initialize memory."
```

---

## Verification

After setup, start a new Claude Code session. The hook output should appear as a system message containing your memory file contents.

If it's not working:
1. Check all scripts are executable: `ls -la .claude/hooks/`
2. Verify `.claude/settings.json` is valid JSON: `jq . .claude/settings.json`
3. Ensure `.claude/mem/` directory exists
4. Test scripts manually: `.claude/hooks/load-memory.sh`
5. Check `jq` is installed (required by Stop, PreCompact, and SessionEnd hooks)

## Tips

1. **All 4 hooks work together** - Load on start, remind on stop, preserve on compact, save on exit. Defense-in-depth.

2. **jq is required** - The Stop, PreCompact, and SessionEnd hooks use `jq` to parse JSON input and produce JSON output. Install it via `brew install jq` or `apt install jq`.

3. **Cross-platform** - All scripts handle macOS and Linux differences (stat, sed) automatically.

4. **Token budget** - The load hook warns if total memory exceeds ~8000 chars (~2000 tokens). Keep memory compact.

5. **The Stop hook is tunable** - Currently triggers after 10+ transcript lines and 5 minutes without a checkpoint. Adjust thresholds in the script if needed.
