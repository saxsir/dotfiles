---
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git rev-parse:*), Bash(git push:*), Bash(gh pr create:*)
description: Create Pull Request Command
---

## Context

- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Git status: !`git status --short --branch`
- Commits from base branch: !`git log origin/main..HEAD --oneline 2>/dev/null || git log origin/master..HEAD --oneline`
- Diff from base branch: !`git diff origin/main...HEAD 2>/dev/null || git diff origin/master...HEAD`
- Changed files stats: !`git diff --stat origin/main...HEAD 2>/dev/null || git diff --stat origin/master...HEAD`

## Your task

現在のブランチの変更内容に基づいてdraft PRを作成してください。

### PR作成手順

1. **変更内容の分析**
   - 変更の種類を判定（機能追加、バグ修正、リファクタリング等）
   - 影響範囲を特定
   - 主要な変更点を抽出

2. **PR説明文の生成**
   - CLAUDE.mdで定義された形式に従って生成:
     ```
     ## What
     {{ なにを変えたか？の事実を記載する }}

     ## Why
     {{ なぜこの変更が必要だったのか？を記載する }}
     ```

3. **関連情報の追加**
   - 関連するissue番号があれば `Closes #123` の形式で追加
   - 必要に応じてスクリーンショットやログを追加

4. **PR文言の確認**
   - PR作成前に、生成した文言をユーザーに提示して確認・修正してもらう

5. **Draft PR作成**
   - ユーザーが承認したら、`gh pr create --draft` でdraft PRを作成

## 注意事項

- PR作成前に必ずブランチをpush済みであることを確認
- 未pushの場合は `git push -u origin <branch-name>` を実行
- Draft PRとして作成し、準備ができたらユーザーが手動でReady for reviewに変更
