---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git branch:*)
description: Commit, push, and open a Draft PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Changed files stats: !`git diff --stat HEAD`
- Base branch name: !`git rev-parse --abbrev-ref origin/HEAD`
- Recent commits on current branch: !`git log --oneline -20`

## Your task

Based on the above changes:

1. Identify the base branch (main or master) and review all commits and changes since branching from it
2. Create a new branch if on main (or master)
3. Create a single commit with an appropriate message (write in Japanese)
4. Push the branch to origin
5. Generate PR title and description (write in Japanese):
   - **Analyze the full diff from the base branch (main/master) to understand all changes that will be included in the PR**
   - Review all commits since branching from base to understand the complete context
   - Use git log and git diff commands to gather this information as needed
   - First check if the repository has a pull request template (`.github/PULL_REQUEST_TEMPLATE.md` or similar)
   - If a template exists, follow that template structure
   - If no template exists, use this default format:
     ```
     ## What
     {{ what was changed - facts }}

     ## Why
     {{ why this change was necessary }}

     ## 🔗 Related Issues

     ## 💡 Discussion Points / Technical Concerns
     ```
6. **IMPORTANT**: Present the generated PR title and description to the user for confirmation and allow them to make edits before proceeding
7. After user approval, create a draft pull request using `gh pr create --draft --web` (this will open the PR in browser after creation)

## Important Notes

- Never commit secrets (.env, credentials.json, etc.)
