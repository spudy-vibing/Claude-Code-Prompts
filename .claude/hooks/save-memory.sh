#!/bin/bash
set -euo pipefail

# SessionEnd hook: persist session metadata to .claude/mem/session
# Runs when session terminates — Claude is no longer interactive at this point.
# Extracts what happened (tools, files, git state) so next-session Claude
# can reconstruct context without needing semantic understanding.

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

# Count conversation turns — skip trivial sessions
TURN_COUNT=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
[[ "$TURN_COUNT" -lt 4 ]] && exit 0

# Extract tool usage summary (what files were edited, what commands ran)
TOOLS_USED=$(jq -r '
  select(.type == "tool_use") |
  .name + ":" + (.input.file_path // .input.command // .input.pattern // "" | split("\n")[0])
' "$TRANSCRIPT" 2>/dev/null | sort -u | head -20)

# Extract git state at end of session
GIT_HASH=$(git log -1 --format=%h 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Remove old =last_session section if it exists (preserve everything else)
if [[ -f "$SESSION_FILE" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' '/^=last_session$/,/^=[a-z]/{ /^=[a-z]/!d; /^=last_session/d; }' "$SESSION_FILE" 2>/dev/null || true
    sed -i '' '/^=tools_used$/,/^=[a-z]/{ /^=[a-z]/!d; /^=tools_used/d; }' "$SESSION_FILE" 2>/dev/null || true
  else
    sed -i '/^=last_session$/,/^=[a-z]/{ /^=[a-z]/!d; /^=last_session/d; }' "$SESSION_FILE" 2>/dev/null || true
    sed -i '/^=tools_used$/,/^=[a-z]/{ /^=[a-z]/!d; /^=tools_used/d; }' "$SESSION_FILE" 2>/dev/null || true
  fi
  # Remove trailing blank lines
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$SESSION_FILE" 2>/dev/null || true
  else
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$SESSION_FILE" 2>/dev/null || true
  fi
fi

# Append last session metadata
cat >> "$SESSION_FILE" <<FOOTER

=last_session
_t:$TIMESTAMP
_sid:${SESSION_ID:0:8}
_h:$GIT_HASH
_b:$GIT_BRANCH
_turns:$TURN_COUNT
FOOTER

# Append tools summary if meaningful
if [[ -n "$TOOLS_USED" ]]; then
  echo "=tools_used" >> "$SESSION_FILE"
  echo "$TOOLS_USED" | while read -r line; do
    [[ -n "$line" ]] && echo "+$line" >> "$SESSION_FILE"
  done
fi

exit 0
