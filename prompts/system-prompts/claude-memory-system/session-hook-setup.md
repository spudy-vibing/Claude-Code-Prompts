# SessionStart Hook Setup

## Description

Configure Claude Code's SessionStart hook to automatically inject memory files into Claude's context before any user interaction. This ensures Claude has full project memory without relying on instruction compliance.

## The Problem

CLAUDE.md instructions telling Claude to "read memory files first" are unreliable. Claude often skips or forgets.

## The Solution

Use the SessionStart hook to mechanically inject memory content before Claude sees any user message.

**Key Insight**: Mechanical enforcement > instruction compliance

---

## Setup Files

### File 1: `.claude/settings.json`

Create this file in your project's `.claude/` directory:

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

### File 2: `.claude/hooks/load-memory.sh`

Create this script:

```bash
#!/bin/bash
# SessionStart hook: Load memory files into Claude's context
# This runs automatically at session start before any user interaction

cd "$(dirname "$0")/../.." || exit 1

# Output memory files content
for f in .claude/mem/*; do
  if [[ -f "$f" ]]; then
    echo "=== $(basename "$f") ==="
    cat "$f"
    echo ""
  fi
done

# Output current git hash for verification
echo "=== git_state ==="
echo "hash:$(git log -1 --format=%h 2>/dev/null || echo 'not-a-repo')"
echo "branch:$(git branch --show-current 2>/dev/null || echo 'unknown')"
```

Make it executable:

```bash
chmod +x .claude/hooks/load-memory.sh
```

### File 3: `.claude/mem/` Directory

Create the memory directory structure:

```bash
mkdir -p .claude/mem
```

After running the [bootstrap prompt](bootstrap-prompt.md), Claude will populate this with files like:

```
.claude/mem/
├── core       # architecture, patterns, decisions
├── direction  # roadmap, priorities, what's next
├── api        # commands, types, contracts
└── session    # current context, learned this session
```

---

## How It Works

```
1. User starts Claude Code session
   ↓
2. SessionStart hook fires (runs on: new, resume, clear, compact)
   ↓
3. load-memory.sh executes
   ↓
4. Script outputs all .claude/mem/* file contents
   ↓
5. Output becomes <system-reminder> in Claude's context
   ↓
6. Claude has full memory before seeing any user message
```

## Complete Directory Structure

After setup, your `.claude/` directory should look like:

```
.claude/
├── settings.json          # Hook configuration
├── hooks/
│   └── load-memory.sh     # Memory loader script
└── mem/
    ├── core               # Architecture, patterns, decisions
    ├── direction          # Roadmap, priorities
    ├── api                # Commands, types, contracts
    └── session            # Current context
```

---

## Quick Setup Script

Run this in your project root to set up everything at once:

```bash
# Create directory structure
mkdir -p .claude/hooks .claude/mem

# Create settings.json
cat > .claude/settings.json << 'EOF'
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
EOF

# Create load-memory.sh
cat > .claude/hooks/load-memory.sh << 'EOF'
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
EOF

# Make executable
chmod +x .claude/hooks/load-memory.sh

echo "Setup complete. Run the bootstrap prompt to initialize memory."
```

---

## Verification

After setup, start a new Claude Code session. The hook output should appear as a system message containing your memory file contents.

If it's not working:
1. Check that `.claude/hooks/load-memory.sh` is executable
2. Verify `.claude/settings.json` syntax is valid JSON
3. Ensure `.claude/mem/` directory exists (even if empty initially)
4. Try running the script manually: `.claude/hooks/load-memory.sh`

## Tips

1. **The hook runs on all session types** - New sessions, resumed sessions, cleared sessions, and compacted sessions all trigger SessionStart

2. **Output becomes context** - Whatever the script outputs becomes part of Claude's system context

3. **Keep memory files lean** - Large memory files increase token usage on every session

4. **Git state helps with changes** - The git hash output lets Claude detect when code has changed since last session
