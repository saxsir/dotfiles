---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*)
description: 現在の変更を確認し、コミットしてください。
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

現在の変更を確認し、コミットしてください。
ファイルがaddされていない場合、現在の作業に関連する変更をaddしてからコミットしてください。
