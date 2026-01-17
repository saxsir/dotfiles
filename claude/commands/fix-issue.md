---
allowed-tools: Bash(gh issue view:*), Bash(gh issue comment:*), Bash(gh api:*), Bash(git status:*), Bash(git log:*), Bash(git checkout:*), Bash(git add:*), Bash(git commit:*)
description: Fix GitHub Issue Command
---

## Context

- Issue details: !`gh issue view $ARGUMENTS --json number,title,body,author,state,labels,comments`
- Git status: !`git status --short --branch`

## Your task

GitHub Issue #$ARGUMENTS を分析して修正してください。

### 修正手順

1. **Issue内容の理解**
   - Issue本文とコメントから問題の本質を把握
   - 再現手順や期待される動作を確認
   - 関連するラベルやマイルストーンを確認

2. **プラン作成 & ユーザー承認**
   - `EnterPlanMode` で実装計画を立案
   - 以下を含むプランを作成:
     - 問題の原因分析
     - 解決アプローチ
     - 変更対象ファイル
     - テスト方針
   - ユーザーの承認を待つ

3. **Issueにプランを追記**
   - 承認されたプランをIssueにコメントとして追加
   - コメントIDを記録（後で更新に使用）
   ```bash
   gh issue comment $ARGUMENTS --body "## 実装プラン\n..."
   ```

4. **Todoコメントの作成**
   - 実装ステップをチェックリスト形式でIssueにコメント
   - コメントIDを記録
   ```bash
   gh issue comment $ARGUMENTS --body "## 進捗\n- [ ] ステップ1\n- [ ] ステップ2\n..."
   ```

5. **ブランチ作成**
   - 適切な命名規則でブランチを作成:
     - `fix/<issue-number>/<short-description>`
     - `feat/<issue-number>/<short-description>`
     - `refactor/<issue-number>/<short-description>`

6. **実装（進捗をIssueに反映）**
   - 問題を解決するコード変更を実施
   - 各ステップ完了時にTodoコメントを更新
   ```bash
   gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
     -X PATCH -f body="## 進捗\n- [x] ステップ1\n- [ ] ステップ2\n..."
   ```
   - 必要に応じてテストを追加・更新
   - リント・型チェックを実行

7. **検証**
   - 変更が意図通りに動作することを確認
   - 既存機能に影響がないことを確認
   - テストがすべてパスすることを確認

8. **コミット**
   - 明確なコミットメッセージで変更を記録
   - コミットメッセージに `Fixes #$ARGUMENTS` を含める
   - Todoコメントを完了状態に更新

## コメント更新の補足

コメントIDの取得方法:
```bash
# 最新のコメントIDを取得
gh api repos/{owner}/{repo}/issues/$ARGUMENTS/comments --jq '.[-1].id'
```

## 重要な注意事項

- GitHub CLI (`gh`) を使用してIssue情報を取得・更新
- プランはユーザー承認後にのみIssueに追記
- 小さく段階的に変更を進める
- 各ステップでgit statusを確認
- 進捗はIssueのTodoコメントを更新して反映
- コミット前に必ずテストとリントを実行
