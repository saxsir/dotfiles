# Git Branch Workflow

This rule enforces using standard git branch workflow for all implementation tasks across all projects.

## MANDATORY WORKFLOW

When starting ANY implementation task that requires creating a feature branch, you **MUST** follow these steps:

### Required Commands

**Before creating a branch, update master/main:**
```bash
git switch master && git pull origin master
```

**Creating a feature branch:**
```bash
git checkout -b <branch-name>
```

**After work is complete:**
```bash
git switch master && git pull origin master && git branch -d <branch-name>
```

### Branch Naming Rules

- **New features**: `feat/<feature-name>` (e.g., `feat/add-docker-aliases`)
- **Bug fixes**: `fix/<description>` (e.g., `fix/zsh-startup-time`)
- **Refactoring**: `refactor/<component>` (e.g., `refactor/auth-module`)
- **Chores**: `chore/<description>` (e.g., `chore/update-dependencies`)

### When to Apply This Rule

**✅ MUST create a branch:**
- Implementing new features
- Fixing bugs
- Refactoring code
- Any task that requires a feature branch

**⚠️ Exceptions (branch not required):**
- Minor edits to CLAUDE.md or other documentation
- Quick typo fixes in existing branch
- Changes that don't require code review

### Integration with Existing Skills

**For `/fix-issue` command:**
- Step 5 (Branch creation): use `git switch master && git pull origin master && git checkout -b <branch-name>`

**For `/commit-and-pr` command:**
- Step 2 (Feature branch creation): use `git switch master && git pull origin master && git checkout -b <branch-name>`

## Why This Rule Exists

1. **Simplicity**: Standard git workflow familiar to all developers
2. **Safety**: Always work from the latest master/main
3. **Consistency**: Standardizes workflow across all projects and sessions

---

**This rule is automatically loaded for ALL Claude Code sessions via symlink at `~/.claude/rules/`.**
