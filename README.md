# Claude Prompts Collection

A curated collection of reusable prompts for Claude AI, organized by category for easy discovery and use.

## Overview

This repository contains battle-tested prompts that help you get the most out of Claude. Whether you're coding, writing, analyzing data, or brainstorming creative ideas, you'll find prompts here to accelerate your workflow.

## Directory Structure

```
prompts/
└── system-prompts/          # Custom instructions and persona prompts
    └── claude-memory-system/  # Persistent cross-session memory system
```

## Available Prompts

### [System Prompts](prompts/system-prompts/)

Custom instructions for Claude including:
- Persona definitions
- Behavioral guidelines
- Domain expertise configurations
- Output format specifications

#### [Claude Memory System](prompts/system-prompts/claude-memory-system/)

A persistent memory system for Claude Code that enables cross-session context retention:
- **Bootstrap prompt** - Initialize Claude's self-designed memory format
- **CLAUDE.md template** - Project instructions with memory protocol
- **SessionStart hook** - Automatic memory loading via hooks
- **Real examples** - Memory format from an actual project

## How to Use

1. **Browse** the categories above to find relevant prompts
2. **Copy** the prompt you need
3. **Customize** placeholders (marked with `[brackets]`) for your specific use case
4. **Use** with Claude (claude.ai, API, or Claude Code)

## Prompt Format

Each prompt in this repository follows a consistent format:

```markdown
# Prompt Name

## Description
Brief explanation of what the prompt does

## Prompt
The actual prompt text

## Variables
- `[variable]`: Description of what to replace

## Example Usage
Demonstration of the prompt in action

## Tips
Best practices for using this prompt
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Adding new prompts
- Improving existing prompts
- Reporting issues
- Suggesting categories

## Best Practices

When using these prompts:

1. **Be specific** - Replace all placeholders with detailed context
2. **Iterate** - Refine prompts based on outputs
3. **Combine** - Mix prompts from different categories for complex tasks
4. **Adapt** - Modify prompts to fit your specific needs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors who have shared their prompts
- Inspired by the Claude community and prompt engineering best practices

---

**Star this repo** if you find it helpful!

Have a great prompt to share? [Open a PR](../../pulls) or [create an issue](../../issues)!
