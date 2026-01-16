---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(git diff:*), Bash(git log:*)
description: Commit, push, and open a Draft PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Changed files stats: !`git diff --stat HEAD`

## Your task

Based on the above changes:

1. Create a new branch if on main (or master)
2. Create a single commit with an appropriate message (write in Japanese)
3. Push the branch to origin
4. Generate PR title and description (write in Japanese):
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
5. **IMPORTANT**: Present the generated PR title and description to the user for confirmation and allow them to make edits before proceeding
6. After user approval, create a draft pull request using `gh pr create --draft`

## Important Notes

- Never commit secrets (.env, credentials.json, etc.)
