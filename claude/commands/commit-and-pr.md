---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git branch:*), Task(*)
description: Creates a commit, pushes to remote, and opens a draft pull request with Japanese title and description. Use when the user wants to commit changes and create a PR, or mentions creating a pull request.
---

## Arguments

- `--skip-review`: コードレビューステップをスキップ（オプション）

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Changed files stats: !`git diff --stat HEAD`
- Base branch name: !`git rev-parse --abbrev-ref origin/HEAD`
- Recent commits on current branch: !`git log --oneline -20`

## あなたのタスク

コミットを作成し、リモートにpushして、日本語のタイトルと説明で Draft Pull Request を開いてください。

## Commit and PR ワークフロー

進捗チェックリストをコピーして追跡してください：

```
進捗:
- [ ] ステップ1: ベースブランチを特定して変更を確認
- [ ] ステップ2: フィーチャーブランチを作成（必要な場合）
- [ ] ステップ3: 日本語メッセージでコミットを作成
- [ ] ステップ4: ブランチをリモートにpush
- [ ] ステップ5: PRのタイトルと説明を生成
- [ ] ステップ6: PR内容についてユーザーの承認を得る
- [ ] ステップ7: コードレビューを実行（--skip-reviewが指定されていない場合）
- [ ] ステップ8: Draft Pull Requestを作成
```

### ステップ1: ベースブランチを特定して変更を確認

**ベースブランチを判断:**
- `git rev-parse --abbrev-ref origin/HEAD` で main ブランチを確認（通常は `main` または `master`）
- ベースからの分岐以降のすべてのコミットと変更を確認

**変更を包括的に分析:**
- `git diff <base-branch>...HEAD` を実行してベースブランチからの完全なdiffを確認
- `git log --oneline <base-branch>..HEAD` を実行してこのブランチのすべてのコミットを確認
- PRに含まれるすべての変更の完全な文脈を理解

### ステップ2: フィーチャーブランチを作成（必要な場合）

**現在main/masterにいる場合:**
- わかりやすいブランチ名を作成:
  - `feat/<feature-name>` 新機能の場合
  - `fix/<issue-number>-<description>` バグ修正の場合
  - `refactor/<component-name>` リファクタリングの場合
- `git checkout -b <branch-name>` を使用

**すでにフィーチャーブランチにいる場合:**
- 現在のブランチで続行

### ステップ3: 日本語メッセージでコミットを作成

**コミットメッセージのガイドライン:**
- Conventional Commits形式を使用: `<type>: <件名>`
- 日本語で記述
- 件名: 簡潔な要約（50文字以内）
- 本文: なぜ変更が必要だったかを説明

**例:**
```
feat: ユーザー認証にJWTトークンを実装

セッション管理のスケーラビリティ向上のため、
ステートレスな認証方式に移行した。
```

**コミット前に検証:**
- [ ] シークレットや認証情報がない（.env、APIキー、パスワード）
- [ ] 変更がコミットメッセージと一致している
- [ ] 関連する変更のみが含まれている

### ステップ4: ブランチをリモートにpush

**上流追跡付きでpush:**
```
git push -u origin <branch-name>
```

これにより追跡が設定され、今後のpushが簡単になります。

### ステップ5: PRのタイトルと説明を生成

**PRタイトル（日本語）:**
- 変更の簡潔な要約
- 形式に従う: `<type>: <日本語の説明>`
- 例: `feat: ユーザー認証機能の実装`

**PR説明の構造:**

まず、PRテンプレートを確認:
1. `.github/PULL_REQUEST_TEMPLATE.md` などを探す
2. テンプレートが存在する場合は、その構造に従う
3. テンプレートがない場合は、以下のデフォルト形式を使用

**デフォルトPRテンプレート（日本語）:**

```markdown
## What（何を変更したか）
<!-- 変更内容を事実ベースで記載 -->
- 変更点1
- 変更点2
- 変更点3

## Why（なぜ変更が必要だったか）
<!-- 変更の背景・動機を記載 -->

この変更により〇〇が改善される。

## 🔗 Related Issues
<!-- 関連するIssueがあれば記載 -->
Closes #123

## 💡 Discussion Points / Technical Concerns
<!-- レビューで議論したい点や技術的な懸念があれば記載 -->
- 議論点1
- 懸念点2
```

**説明の重要なポイント:**
- **What**: 行われた変更の事実的なリスト
- **Why**: 動機と文脈を説明（実装の詳細ではない）
- `Closes #<issue-number>` または `Fixes #<issue-number>` で関連issueを参照
- レビュアーのための議論ポイントを含める

### ステップ6: PR内容についてユーザーの承認を得る

**ユーザーに提示:**
- 生成されたPRタイトルを表示
- 完全なPR説明を表示
- 確認を求め、編集を許可

**ユーザーは以下が可能:**
- そのまま承認
- タイトル/説明の修正を要求
- より多くの文脈や議論ポイントを追加

**ステップ7に進む前にユーザーの承認を得る必要があります。**

### ステップ7: コードレビューを実行（--skip-reviewが指定されていない場合）

**デフォルトの動作:**
- `--skip-review` オプションが指定されていない限り、PR作成前にコードレビューを実行
- pr-review-toolkit を使用して包括的なレビューを実施

**レビュー内容:**
- **code-reviewer**: コード品質の一般的なチェック
- **pr-test-analyzer**: テストカバレッジの確認
- **silent-failure-hunter**: エラーハンドリングの検証（エラーハンドリングを変更した場合）
- **comment-analyzer**: コメント精度の確認（コメント/ドキュメントを追加・修正した場合）
- **type-design-analyzer**: 型設計のレビュー（型を追加・修正した場合）

**レビュー実行方法:**
```bash
# /review-pr スキル（pr-review-toolkit）を使用
Task tool を使って適切なエージェントを起動
```

**レビュー結果の処理:**
- **Critical issues が見つかった場合**:
  - 停止してユーザーに報告
  - 修正を促す
  - PR作成は中止

- **Warnings が見つかった場合**:
  - ユーザーに結果を提示
  - 続行するか、修正してから進むか確認

- **問題が見つからなかった場合**:
  - ステップ8に進む

**レビューをスキップする場合:**
- `--skip-review` オプションが指定されている場合は、このステップを飛ばしてステップ8へ
- 緊急時やhotfixの場合に使用

### ステップ8: Draft Pull Requestを作成

**ユーザーの承認後:**
```bash
gh pr create --draft --title "<title>" --body "<description>"
```

**Draft PRのメリット:**
- 作業中であることを示す
- CIチェックを実行できる
- 早期のフィードバックを得られる
- 完了時にreadyに変換できる

**作成後:**
- Draft PRが正常に作成されたことを確認
- `gh pr view --web` で作成したDraft PRをブラウザで開く

## 重要な注意事項

- **シークレットをコミットしない**: `.env`、`credentials.json`、APIキー、パスワードを確認
- **包括的な分析**: 最新のコミットだけでなく、ベースブランチからのすべてのコミットと変更を確認
- **日本語**: コミットメッセージとPR内容の両方を日本語で記述
- **ユーザーの承認が必要**: PRを作成する前に必ず確認を得る
- **デフォルトでDraft**: 新しいPRには常に `--draft` フラグを使用
