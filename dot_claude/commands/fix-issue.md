---
allowed-tools: Bash(gh api:*), Bash(gh issue comment:*), Bash(gh issue view:*), Bash(git add:*), Bash(git branch:*), Bash(git checkout:*), Bash(git commit:*), Bash(git log:*), Bash(git pull:*), Bash(git status:*), Bash(git switch:*), Task(*)
description: Analyzes and fixes a GitHub Issue by creating a branch, implementing changes, running tests, and committing with appropriate message. Use when the user wants to resolve a specific GitHub issue or mentions fixing an issue number.
---

## Context

- Issue details: !`gh issue view $ARGUMENTS --json number,title,body,author,state,labels,comments`
- Git status: !`git status --short --branch`

## あなたのタスク

計画を立案してユーザーの承認を得た後、ブランチを作成し、変更を実装し、テストを実行し、適切なメッセージでコミットすることで、GitHub Issue #$ARGUMENTS を分析して修正してください。

## Issue解決ワークフロー

進捗チェックリストをコピーして追跡してください：

```
進捗:
- [ ] ステップ1: issueを徹底的に理解
- [ ] ステップ2: EnterPlanModeで計画立案 & ユーザー承認
- [ ] ステップ3: プランをIssueにコメント
- [ ] ステップ4: Todoコメントの作成
- [ ] ステップ5: ブランチ作成
- [ ] ステップ6: 実装（進捗をIssueコメントで更新）
- [ ] ステップ7: テストと検証
- [ ] ステップ7.5: 軽量コードレビュー（コミット前チェック）
- [ ] ステップ8: コミット
- [ ] ステップ9: 検証してPRの準備
```

### ステップ1: issueを徹底的に理解

**issue内容を分析:**
- コンテキストからissue本文とすべてのコメントを読む
- 問題の根本原因を特定
- 期待される動作と実際の動作を理解
- 提供されている再現手順を注記
- 関連するラベル、マイルストーン、アサイニーを確認

**必要に応じて明確化:**
- issue説明が不明確な場合は、ユーザーに明確化を求める
- 再現手順が欠けている場合は、それらを要求
- 期待される動作が曖昧な場合は、理解を確認

**関連する作業を確認:**
- 言及されている関連issueやPRを探す
- 文脈のために類似の過去のissueを確認
- この領域に既存のテストケースがあるか確認

### ステップ2: EnterPlanModeで計画立案 & ユーザー承認

**EnterPlanModeを使用して実装計画を立案:**

計画には以下を含めます:
- **問題の原因分析**: 何が問題なのか、なぜ発生しているのか
- **解決アプローチ**: どのようにして修正するか
- **変更対象ファイル**: どのファイルを変更する必要があるか
- **テスト方針**: どのようにテストするか、新規テストが必要か
- **影響範囲**: 既存機能への影響はあるか

**ユーザーの承認を待つ:**
- 計画をユーザーに提示
- 質問や懸念があれば対応
- 承認を得てから次のステップに進む

### ステップ3: プランをIssueにコメント

**承認されたプランをIssueに追記:**

```bash
gh issue comment $ARGUMENTS --body "## 実装プラン

### 問題の原因
[原因の説明]

### 解決アプローチ
[アプローチの説明]

### 変更対象ファイル
- ファイル1
- ファイル2

### テスト方針
[テスト方針の説明]
"
```

**コメントIDを記録（後で更新に使用）:**
```bash
# 最新のコメントIDを取得
gh api repos/{owner}/{repo}/issues/$ARGUMENTS/comments --jq '.[-1].id'
```

### ステップ4: Todoコメントの作成

**実装ステップをチェックリスト形式でIssueにコメント:**

```bash
gh issue comment $ARGUMENTS --body "## 進捗

- [ ] ブランチ作成
- [ ] [具体的な実装タスク1]
- [ ] [具体的な実装タスク2]
- [ ] テスト追加
- [ ] テスト実行・検証
- [ ] 軽量コードレビュー
- [ ] コミット
"
```

**コメントIDを記録（進捗更新に使用）:**
```bash
gh api repos/{owner}/{repo}/issues/$ARGUMENTS/comments --jq '.[-1].id'
```

### ステップ5: ブランチ作成

**ブランチ命名規則:**

- **バグ修正**: `fix/<issue-number>-<short-description>`
  - 例: `fix/123-login-error`

- **新機能**: `feat/<issue-number>-<short-description>`
  - 例: `feat/456-user-profile`

- **リファクタリング**: `refactor/<issue-number>-<short-description>`
  - 例: `refactor/789-auth-module`

**masterを最新化してブランチを作成:**
```bash
git switch master && git pull origin master && git checkout -b <branch-name>
```

**検証:**
- `git branch --show-current` で新しいブランチにいることを確認
- `git status` でクリーンな作業ディレクトリを確保

**Todoコメントを更新:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="## 進捗

- [x] ブランチ作成
- [ ] [具体的な実装タスク1]
- [ ] [具体的な実装タスク2]
- [ ] テスト追加
- [ ] テスト実行・検証
- [ ] 軽量コードレビュー
- [ ] コミット
"
```

### ステップ6: 実装（進捗をIssueコメントで更新）

**TDD原則に従う（該当する場合）:**
1. issueを捉える失敗するテストを書く
2. テストを通すための最小限のコードを実装
3. 必要に応じてリファクタリング

**実装ガイドライン:**
- 問題に直接対処する焦点を絞った変更を行う
- 変更を最小限に保ち、問題に範囲を限定
- 修正をカバーするテストを追加または更新
- 動作が変更される場合はドキュメントを更新
- リンターと型チェッカーを頻繁に実行

**コード品質チェック:**
- コードがプロジェクトのスタイルガイドラインに従っていることを確認
- 自明でないロジックにコメントを追加
- デバッグコードやconsole.logを削除
- コードにシークレットや認証情報がないことを確認

**各ステップ完了時にTodoコメントを更新:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="## 進捗

- [x] ブランチ作成
- [x] [具体的な実装タスク1]
- [ ] [具体的な実装タスク2]
- [ ] テスト追加
- [ ] テスト実行・検証
- [ ] 軽量コードレビュー
- [ ] コミット
"
```

### ステップ7: テストと検証

**テスト実行（フィードバックループ）:**

各変更後にテストを実行:
```bash
# 関連するテストスイートを実行
npm test          # または pytest, go test など
npm run lint      # リンターを実行
npm run typecheck # 型チェッカーを実行
```

**検証チェックリスト:**
- [ ] すべてのテストが通る（既存のテストを含む）
- [ ] 修正のための新しいテストが追加された（該当する場合）
- [ ] リンターが警告なしで通る
- [ ] 型チェッカーがエラーなしで通る
- [ ] 手動テストで修正が期待通りに機能することを確認
- [ ] 既存機能に退行がない

**テストが失敗した場合:**
- エラーメッセージを注意深く確認
- 段階的に問題を修正
- 各修正後に再度テストを実行
- すべてのテストが通るまで進まない

**Todoコメントを更新:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="## 進捗

- [x] ブランチ作成
- [x] [具体的な実装タスク1]
- [x] [具体的な実装タスク2]
- [x] テスト追加
- [x] テスト実行・検証
- [ ] 実装中コードレビュー
- [ ] コミット
"
```

### ステップ7.5: 実装中コードレビュー（コミット前チェック）

**レビューの目的:**
コミット前に <code>/code-review xhigh --fix</code> を回し、明らかな問題を早期発見しつつ修正まで自動適用する。最終ゲートは `/commit-and-pr` の <code>/review</code> で別に置く ([[review-cycle]])。

**レビュー実行:**
- 前提: working tree が clean な状態で回す ([[tidy-first]] の構造/振る舞いコミット分離が機械的に保たれる)。
- 実行: Skill ツールで `code-review` を呼び出す。引数 `xhigh --fix`。
- subagent に降ろす場合は **モデルに Opus を指定する** ([[review-cycle]] のモデル指定原則。Sonnet には降ろさない)。

**レビュー結果の処理:**
- **修正が適用された場合**:
  - 適用差分をユーザーに提示
  - テスト (ステップ7) を再実行
  - 問題なければステップ8 (コミット) に進む

- **Critical issues で自動修正されなかった場合**:
  - ステップ6（実装）に戻って修正
  - Todoコメントを更新して進捗を反映

- **問題が見つからなかった場合**:
  - ステップ8（コミット）に進む

**Todoコメントを更新:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="## 進捗

- [x] ブランチ作成
- [x] [具体的な実装タスク1]
- [x] [具体的な実装タスク2]
- [x] テスト追加
- [x] テスト実行・検証
- [x] 実装中コードレビュー
- [ ] コミット
"
```

**注意事項:**
- この実装中レビューは、`/commit-and-pr` で回す最終ゲート (<code>/review</code>) の代替ではない
- ここでの目的はコミット前の早期問題発見と自動修正

### ステップ8: コミット

**コミットメッセージ形式（日本語）:**

```
<type>: <件名> (Fixes #$ARGUMENTS)

<修正の説明本文>
```

**タイプ:**
- `fix`: バグ修正
- `feat`: 新機能
- `refactor`: 動作変更のないコード再構成
- `test`: テスト追加または更新
- `docs`: ドキュメント変更

**メッセージガイドライン:**
- 件名: 日本語での簡潔な要約（50文字以内）
- 本文: 何が間違っていたか、なぜこの修正がそれを解決するかを説明
- マージ時にissueを自動クローズするために `Fixes #$ARGUMENTS` を含める

**例:**
```
fix: ログイン時のセッションエラーを修正 (Fixes #123)

セッショントークンの有効期限チェックが正しく
動作していなかった問題を修正した。
タイムゾーン変換を統一することで解決。
```

**コミットを作成:**
```bash
git add <changed-files>
git commit -m "<commit-message>"
```

**Todoコメントを完了状態に更新:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="## 進捗

- [x] ブランチ作成
- [x] [具体的な実装タスク1]
- [x] [具体的な実装タスク2]
- [x] テスト追加
- [x] テスト実行・検証
- [x] 軽量コードレビュー
- [x] コミット

✅ すべての実装が完了しました
"
```

### ステップ9: 検証してPRの準備

**最終検証:**
- `git status` を実行してクリーンな作業ディレクトリを確認
- `git log -1` を実行してコミットメッセージを確認
- 最後にもう一度完全なテストスイートを実行
- 修正を単独で手動テスト

**完全性を確認:**
- [ ] issueが完全に解決された（部分的ではない）
- [ ] すべてのテストが通る
- [ ] コードがプロジェクトの規約に従っている
- [ ] 必要に応じてドキュメントが更新された
- [ ] コードレビューの準備ができている

**ユーザーに次のステップを提案:**
- 「Issue #$ARGUMENTS はブランチ `<branch-name>` で修正されました」
- 「すべてのテストが通っています」
- 「pushしてpull requestを作成しますか？」
- `/commit-and-pr` コマンドの実行を提案することを検討

## コメント更新の補足

**コメントIDの取得方法:**
```bash
# 最新のコメントIDを取得
gh api repos/{owner}/{repo}/issues/$ARGUMENTS/comments --jq '.[-1].id'
```

**コメント更新の形式:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id} \
  -X PATCH -f body="更新後の内容"
```

## 重要な注意事項

- **EnterPlanModeを使用**: 実装前に必ず計画を立案しユーザーの承認を得る
- **プランをIssueに記録**: 承認された計画をIssueコメントとして追加
- **進捗を可視化**: Todoコメントを更新して進捗をIssue上で追跡可能にする
- **gh CLIを活用**: `gh issue view`、`gh issue comment`、`gh api` を使用
- **段階的な進捗**: 小さな変更を行い、頻繁にテスト
- **テスト駆動**: 変更の前後にテストを書くまたは実行
- **Git規律**: 各ステップ後に `git status` を確認
- **ショートカットなし**: コミット前に常にテストとリンターを実行
- **不明な場合は尋ねる**: issue説明が曖昧な場合は、ユーザーに明確化を求める
- **自動クローズissue**: マージ時にissueを自動クローズするためにコミットメッセージに `Fixes #$ARGUMENTS` を含める
