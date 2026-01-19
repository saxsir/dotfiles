---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*)
description: Creates a git commit with a Japanese message by analyzing staged and unstaged changes. Use when the user wants to commit current changes or mentions committing code.
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## あなたのタスク

意味のある日本語メッセージで単一のgitコミットを作成してください。

## コミットワークフロー

**ステップ1: 変更内容を分析**
- コンテキストに表示されたステージング済みと未ステージの変更をすべて確認
- 変更の性質を特定（feat, fix, refactor, docs, test, chore）
- 変更の範囲を判断（どのモジュール/コンポーネントが影響を受けるか）

**ステップ2: コミットタイプを決定**

Conventional Commits形式を使用:
- `feat`: 新機能または機能追加
- `fix`: バグ修正
- `refactor`: 動作を変更しない構造変更
- `docs`: ドキュメント変更
- `test`: テスト追加または修正
- `chore`: ビルドプロセス、依存関係更新など
- `style`: コードフォーマット（ロジック変更なし）

**ステップ3: コミットメッセージを下書き**

形式（日本語）:
```
<type>: <日本語の件名>

<なぜ必要だったかの説明（日本語）>
```

**メッセージガイドライン:**
- **件名**: 何を変更したかの簡潔な要約（50文字以内）
- **本文**: なぜこの変更が必要だったかを説明（どのように実装したかではない）
- 動機と文脈に焦点を当てる
- 該当する場合はissue番号を参照

**例:**

```
feat: ユーザー認証にJWTトークンを実装

セッション管理のスケーラビリティ向上のため、
ステートレスな認証方式に移行した。
```

```
fix: レポート画面の日付表示エラーを修正

タイムゾーン変換時にUTCタイムスタンプを
一貫して使用するように修正した。
```

```
refactor: エラーハンドリングロジックを抽出

次の機能追加を容易にするため、
共通のエラー処理を別メソッドに分離した。
```

**ステップ4: コミット前に検証**

以下を確認:
- [ ] 変更にシークレットや認証情報が含まれていない（`.env`、APIキー、パスワード）
- [ ] 変更がコミットメッセージの説明と一致している
- [ ] 関連する変更のみが含まれている（単一の論理単位）
- [ ] 最近のコミットと一貫したスタイルになっている（パターンに従う）

**ステップ5: ステージングとコミット**

単一のレスポンスで実行:
1. `git add`で関連するすべてのファイルをステージング
2. `git commit -m "<message>"`でコミットを作成
3. 他のテキストを出力したり、他のアクションを実行しない

## 重要な注意事項

- **シークレットをコミットしない**: `.env`、`credentials.json`、APIキー、パスワードを確認
- **日本語で記述**: すべてのコミットメッセージは日本語で記述
- **WHYに焦点**: 実装の詳細ではなく、動機を説明
- **単一の論理単位**: 各コミットは単一の一貫した変更を表すべき
- **簡潔に**: 件名は50文字以内
- **既存パターンに従う**: リポジトリの最近のコミットのスタイルに合わせる
