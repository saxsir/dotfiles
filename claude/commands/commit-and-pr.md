---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git push:*), Bash(git rev-parse:*), Bash(gh pr create:*)
description: Commit, Push, and Create PR Command
---

## Context

- Git status: !`git status --short --branch`
- Git diff (staged + unstaged): !`git diff HEAD`
- Changed files stats: !`git diff --stat HEAD`
- Recent commits: !`git log --oneline -5`
- Current branch: !`git rev-parse --abbrev-ref HEAD`

## Your task

変更をコミット→プッシュ→draft PR作成まで一気に実行します。

### 実行手順

1. **変更内容の確認と分析**
   - ステージングされている変更とされていない変更を確認
   - 変更の意図と影響範囲を把握
   - コミットメッセージの内容を考える

2. **必要なファイルをステージング**
   - 関連する変更ファイルを `git add` でステージング

3. **コミットメッセージの作成**
   - 最近のコミット履歴のスタイルに合わせて、明確なコミットメッセージを作成
   - 形式: `<type>: <subject>`

4. **コミット実行**

5. **プッシュ**
   - `git push -u origin <branch-name>`

6. **PR説明文の生成**
   - CLAUDE.mdの形式に従ってPR説明文を生成
   - 形式:
     ```
     ## What
     {{ なにを変えたか？の事実を記載する }}

     ## Why
     {{ なぜこの変更が必要だったのか？を記載する }}
     ```

7. **PR文言の確認**
   - PR作成前に、生成したタイトルと説明文をユーザーに提示して確認・修正してもらう

8. **Draft PR作成**
   - ユーザーが承認したら、`gh pr create --draft` でdraft PRを作成

## 注意事項

- コミット前にgit statusで変更を必ず確認
- PRタイトルと説明文は必ずユーザー確認を経てから作成
- Draft PRとして作成（Ready for reviewはユーザーが手動で切り替え）
- 秘密情報（.env、credentials.jsonなど）をコミットしないよう注意
