# Git Worktree Workflow Enforcement

This rule enforces the use of `git-wt` (k1LoW/git-wt) for all implementation tasks across all projects.

## MANDATORY WORKFLOW

When starting ANY implementation task that requires creating a feature branch, you **MUST** use `git wt` instead of `git checkout -b`.

### Required Commands

**Creating a worktree and branch:**
```bash
git wt <branch-name>
```
This command will:
- Create a new branch
- Create a worktree in an appropriate location
- Automatically switch your working directory to the new worktree

**Verify worktree creation:**
```bash
git worktree list
```

**After work is complete:**
```bash
git wt -d <branch-name>
```
This will remove the worktree after the branch is no longer needed.

### PROHIBITED Commands

**❌ DO NOT USE:**
```bash
git checkout -b <branch-name>  # PROHIBITED
git worktree add <path> <branch-name>  # Use git wt instead
```

### When to Apply This Rule

**✅ MUST use `git wt`:**
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
- Step 5 (Branch creation) must use `git wt <branch-name>`
- Never use `git checkout -b`

**For `/commit-and-pr` command:**
- Step 2 (Feature branch creation) must use `git wt <branch-name>`
- Never use `git checkout -b`

**For superpowers `using-git-worktrees` skill:**
- If this skill attempts to use `git worktree add`, intervene and use `git wt` instead
- The `git-wt` command provides better UX and automatic path management

## Why This Rule Exists

1. **Workspace Isolation**: Worktrees keep different features completely isolated
2. **Concurrent Development**: Work on multiple features simultaneously without stashing
3. **Safety**: Prevents accidental commits to wrong branches
4. **Consistency**: Standardizes workflow across all projects and sessions

## Verification

After creating a worktree with `git wt`, always verify:
```bash
git worktree list  # Confirm worktree exists
git branch --show-current  # Confirm you're on the new branch
pwd  # Confirm you're in the worktree directory
```

---

**This rule is automatically loaded for ALL Claude Code sessions via symlink at `~/.claude/rules/`.**
