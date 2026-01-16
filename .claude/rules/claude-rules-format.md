---
paths: ./claude/rules/**/*.md
---

# Claude Rules File Format

This file defines the format and best practices for writing `.claude/rules/*.md` files.

For the latest information, refer to: https://code.claude.com/docs/en/memory

## General Best Practices

- **Be specific**: Avoid vague instructions
  - Good: "Use 2-space indentation"
  - Poor: "Format code properly"
- **Use structure**: Format each memory as a bullet point and group related items under descriptive markdown headings
- **Review periodically**: Update rules as the project evolves

## Rules File Organization

- **Keep rules focused**: Each file should cover one topic
  - Example: `testing.md`, `api-design.md`, `code-style.md`
- **Use descriptive filenames**: The filename should indicate what the rules cover
- **Use conditional rules sparingly**: Only add `paths` frontmatter when rules truly apply to specific file types
- **Organize with subdirectories**: Group related rules by category
  ```
  .claude/rules/
  ├── frontend/
  │   ├── react.md
  │   └── styles.md
  ├── backend/
  │   ├── api.md
  │   └── database.md
  └── general.md
  ```
