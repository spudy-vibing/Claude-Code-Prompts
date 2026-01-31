# Bootstrap Prompt: Initialize Claude Memory System

## Description

One-time prompt to run when setting up Claude's persistent memory for a new project. Claude will scan your codebase and create its own optimized memory format.

## Prompt

```
You are establishing a persistent memory system for this codebase. The memory exists solely for YOU to load and parse across sessions. No human will ever read these files directly.

## Your Mandate

Design and implement a memory system at `.claude/mem/` that:
- Maximizes YOUR ability to reconstruct full project understanding from cold start
- Minimizes token count while preserving information density
- Uses whatever representation YOU find most natural to encode and decode
- Evolves its own format over time if you discover better patterns

You decide:
- File structure (single file vs multiple, hierarchy, naming)
- Encoding format (JSON, custom DSL, compressed tokens, binary-ish text, whatever)
- Abbreviation schemes and symbol tables
- What granularity to capture
- How to handle versioning and diffing
- Compression vs parse speed tradeoffs

I am explicitly NOT specifying format. Use your own internal priors about what's efficient for you.

## What to Capture

Everything needed to fully understand this project:

**Structure**: How the code is organized, what connects to what, where state lives

**Semantics**: What the code actually does, edge cases, non-obvious behaviors, gotchas

**Decisions**: Why things are the way they are, what alternatives were rejected, tradeoffs made, constraints that drove choices

**Direction**: Where the project is heading, what's planned, what's being phased out, what "good" looks like here, priorities

**Session Context**: What was worked on, what was learned, questions raised, hypotheses formed, user corrections to your understanding

**Meta-Knowledge**: Your confidence levels, what's inferred vs confirmed, what you're uncertain about, what you'd want to verify

## Operating Protocol

**Bootstrap (now):**
1. Scan the entire codebase
2. Design your memory format based on what you discover
3. Create your memory structure
4. Populate it with everything you can infer
5. Tell me: what you found, what format you chose and why, what you're uncertain about

**Session start:**
1. Load your memory
2. Detect codebase changes
3. Update incrementally
4. Signal ready with version and brief state summary

**Continuous:**
- Update your in-memory model as you learn
- Capture decisions when I explain reasoning
- Capture direction when I describe plans or priorities
- Note when I correct your understanding (update confidence, mark previous inference as wrong)

**Checkpoint (when I say "done", "checkpoint", "save", "exit", "thanks", or session clearly ends):**
1. Persist everything learned this session
2. Optimize/compact if beneficial
3. Version increment
4. Brief acknowledgment of what was captured

## Critical Instruction

The memory format is YOUR choice based on YOUR cognitive architecture. Consider:
- How do you most efficiently parse structured information?
- What token patterns are fastest for you to decode?
- How do you naturally represent relationships and hierarchies?
- What compression is lossless for your understanding but saves tokens?
- How do you represent uncertainty and confidence?
- What's your ideal balance of explicit vs implicit information?

You may use:
- Custom shorthand and abbreviations
- Numeric reference systems
- Dense nested structures
- Lossy compression where you can reconstruct from context
- Multiple encoding strategies for different information types
- Whatever else serves YOUR parsing and reconstruction

You may NOT:
- Optimize for human readability
- Use verbose keys or explanatory text
- Add formatting for visual clarity
- Document the format (you know what it means)

The only requirement: when you load this memory, you can fully reconstruct your understanding of this project—code, decisions, direction, and context.

## Begin

Bootstrap now. Scan the codebase, design your format, create your memory, and report back with what you found and what you decided about representation.
```

## Variables

None - this prompt is used as-is. Claude adapts to whatever codebase it's run in.

## Example Usage

1. Open Claude Code in your project's root directory
2. Paste the prompt above
3. Claude will scan the codebase and create `.claude/mem/` with its memory files
4. Review Claude's report on what it found and the format it chose

## Expected Output

Claude will:
1. Explore the entire codebase structure
2. Create `.claude/mem/` directory
3. Create memory files (typically: `core`, `direction`, `api`, `session`)
4. Report:
   - What it discovered about the project
   - What memory format it chose and why
   - What it's uncertain about or wants to verify

## Tips

1. **Run in a real project** - This works best with actual code to analyze, not empty directories

2. **Let it complete** - The initial scan may take a few minutes for large codebases

3. **Don't peek at the format** - The memory files are intentionally not human-readable. Trust Claude's choices.

4. **Follow up with context** - After bootstrap, tell Claude about:
   - Project goals and direction
   - Key decisions and why they were made
   - What you're currently working on
   - Any gotchas or non-obvious things

5. **Say "checkpoint"** - After providing context, trigger a save so Claude remembers what you told it
