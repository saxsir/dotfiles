---
paths: ./claude/commands/**/*.md
---

# Claude Commands File Format

This file defines the format and best practices for writing custom slash commands (`.claude/commands/*.md`).

For the latest information, refer to: https://code.claude.com/docs/en/custom-slash-commands

## Arguments

- **All arguments**: Use `$ARGUMENTS` to capture all arguments passed to the command
- **Positional arguments**: Use `$1`, `$2`, etc. for specific arguments

Example:
```markdown
Review PR #$1 with priority $2 and assign to $3
```

## Bash Command Execution

Execute bash commands before the slash command runs using the `!` prefix:
```markdown
- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
```

Requires `allowed-tools` frontmatter with specific Bash commands.

## File References

Include file contents using the `@` prefix:
```markdown
Review the implementation in @src/utils/helpers.js
```

## Frontmatter Options

| Frontmatter | Purpose | Default |
|-------------|---------|---------|
| `allowed-tools` | List of tools the command can use | Inherits from conversation |
| `argument-hint` | Arguments hint shown in autocomplete | None |
| `context` | Set to `fork` to run in sub-agent context | Inline |
| `agent` | Agent type when `context: fork` is set | general-purpose |
| `description` | Brief description of the command | First line of prompt |
| `model` | Specific model string | Inherits from conversation |
| `disable-model-invocation` | Prevent Skill tool from calling this command | false |
| `hooks` | Define hooks scoped to this command | None |

## Example Command

```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
argument-hint: [message]
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Your task

Create a git commit with message: $ARGUMENTS
```

## Skills vs Slash Commands

Slash commands and Agent Skills serve different purposes. For more details, see: https://code.claude.com/docs/en/custom-slash-commands#skills-vs-slash-commands

### When to use Slash Commands

- You invoke the same prompt repeatedly
- The prompt fits in a single file
- You want explicit control over when it runs

Examples:
- `/review` → "Review this code for bugs and suggest improvements"
- `/explain` → "Explain this code in simple terms"

### When to use Skills

- Claude should discover the capability automatically (based on context)
- Multiple files or scripts are needed
- Complex workflows with validation steps
- Team needs standardized, detailed guidance

### Key Differences

| Aspect | Slash Commands | Agent Skills |
|--------|----------------|--------------|
| Complexity | Simple prompts | Complex capabilities |
| Structure | Single `.md` file | Directory with `SKILL.md` + resources |
| Discovery | Explicit invocation (`/command`) | Automatic (based on context) |
| Files | One file only | Multiple files, scripts, templates |

Both slash commands and Skills can coexist. Use the approach that fits your needs.
