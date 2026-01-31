# Contributing to Claude Prompts Collection

Thank you for your interest in contributing! This document provides guidelines for contributing prompts to this collection.

## How to Contribute

### Adding a New Prompt

1. **Fork** this repository
2. **Choose** the appropriate category folder in `prompts/`
3. **Create** a new markdown file with a descriptive name (e.g., `code-review-checklist.md`)
4. **Follow** the prompt template format below
5. **Submit** a pull request

### Prompt Template

Use this template for all new prompts:

```markdown
# [Prompt Name]

## Description
[1-2 sentences explaining what this prompt does and when to use it]

## Prompt

\`\`\`
[Your prompt text here]
[Use [PLACEHOLDER] format for variables that users should replace]
\`\`\`

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[VARIABLE_NAME]` | What this variable represents | Example value |

## Example Usage

**Input:**
[Show an example of the prompt filled in with real values]

**Output:**
[Show a sample of what Claude might return]

## Tips

- [Tip 1 for getting best results]
- [Tip 2]

## Tags

`tag1` `tag2` `tag3`
```

### Improving Existing Prompts

1. **Test** your improvements thoroughly
2. **Document** what you changed and why
3. **Preserve** backward compatibility when possible
4. **Submit** a PR with a clear description

## Guidelines

### Prompt Quality Standards

- **Clear purpose**: Each prompt should have a specific, well-defined use case
- **Well-tested**: Verify the prompt produces consistent, quality outputs
- **Self-contained**: Include all necessary context within the prompt
- **Adaptable**: Use clear placeholders for customization
- **Documented**: Include usage examples and tips

### What Makes a Good Prompt

- Specific instructions that guide Claude's behavior
- Clear output format expectations
- Relevant context and constraints
- Examples when helpful (few-shot learning)
- Appropriate scope (not too broad, not too narrow)

### Naming Conventions

- Use lowercase with hyphens: `my-prompt-name.md`
- Be descriptive but concise
- Include the main action: `generate-`, `analyze-`, `review-`, etc.

### Categories

Place prompts in the most relevant category:

| Category | Use For |
|----------|---------|
| `coding/` | Programming, development, technical tasks |
| `writing/` | Content creation, documentation, editing |
| `analysis/` | Research, data analysis, summarization |
| `creative/` | Brainstorming, ideation, creative writing |
| `productivity/` | Planning, organization, workflows |
| `system-prompts/` | Custom instructions, personas |
| `templates/` | Reusable frameworks, patterns |

### Pull Request Process

1. Ensure your prompt follows the template
2. Test your prompt with Claude
3. Update the category README if adding a new prompt
4. Write a clear PR description
5. Respond to review feedback

## Code of Conduct

- Be respectful and constructive
- Focus on improving the collection
- Help others learn prompt engineering
- Give credit where due

## Questions?

- Open an issue for questions or suggestions
- Join discussions in existing issues
- Reach out to maintainers

## Recognition

Contributors will be acknowledged in the repository. Thank you for helping build this resource!
