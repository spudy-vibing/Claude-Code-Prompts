# Claude Prompts Collection

A curated collection of reusable prompts and skills for Claude AI.

## Quick Start: Memory System Skill

Install persistent memory for Claude Code with one command:

```bash
npx skills add spudy-vibing/Claude-Code-Prompts/memory-init
```

Or browse on [skills.sh/spudy-vibing/Claude-Code-Prompts/memory-init](https://skills.sh/spudy-vibing/Claude-Code-Prompts/memory-init)

Then run `/memory-init` in your project.

---

## Overview

This repository contains battle-tested prompts and skills that help you get the most out of Claude. Whether you're coding, writing, analyzing data, or brainstorming creative ideas, you'll find resources here to accelerate your workflow.

## Directory Structure

```
├── memory-init/                 # Skill: Initialize persistent memory system
│   └── SKILL.md
└── prompts/
    └── system-prompts/
        └── claude-memory-system/  # Detailed docs and examples
```

## Available Skills

### [memory-init](memory-init/)

Initialize Claude's persistent memory system with self-designed format and auto-loading hooks.

**What it does:**
- Creates `.claude/mem/` directory for memory storage
- Sets up `SessionStart` hook to auto-load memory every session
- Bootstraps Claude to scan your codebase and create its own memory format
- Configures checkpoint behavior for session end

**Install:**
```bash
npx skills add spudy-vibing/Claude-Code-Prompts/memory-init
```

**Use:**
```
/memory-init
```

## Available Prompts

### [System Prompts](prompts/system-prompts/)

Custom instructions for Claude including:
- Persona definitions
- Behavioral guidelines
- Domain expertise configurations
- Output format specifications

#### [Claude Memory System](prompts/system-prompts/claude-memory-system/)

Detailed documentation for the memory system:
- **Bootstrap prompt** - Initialize Claude's self-designed memory format
- **CLAUDE.md template** - Project instructions with memory protocol
- **SessionStart hook** - Automatic memory loading via hooks
- **Real examples** - Memory format from an actual project

## How to Use

### Skills (Recommended)

```bash
# Install a skill
npx skills add spudy-vibing/Claude-Code-Prompts/memory-init

# Use in Claude Code
/memory-init
```

### Manual Prompts

1. **Browse** the `prompts/` directory
2. **Copy** the prompt you need
3. **Customize** placeholders (marked with `[brackets]`)
4. **Use** with Claude (claude.ai, API, or Claude Code)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Adding new prompts
- Creating new skills
- Improving existing content
- Reporting issues

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Star this repo** if you find it helpful!

Have a great prompt to share? [Open a PR](../../pulls) or [create an issue](../../issues)!
