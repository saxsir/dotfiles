---
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(git checkout:*), Bash(git fetch:*)
description: PR Review Command
---

## Context

- PR basic info: !`gh pr view $ARGUMENTS --json number,title,body,author,headRefName,baseRefName,url,state`
- Changed files: !`gh pr view $ARGUMENTS --json files`
- PR diff: !`gh pr diff $ARGUMENTS`
- CI/CD status: !`gh pr checks $ARGUMENTS`
- Existing comments: !`gh pr view $ARGUMENTS --comments`

## Your task

Pull Request #$ARGUMENTS のレビューをお願いします。

### レビュー指針

必要に応じてPRブランチをチェックアウトし、公式ドキュメントなどを参照して正確な情報に基づいてレビューしてください。参照元は必ず明記してください。
最高のコード品質となるよう多角的かつ厳格にレビューし、すべてのレビューコメントを出し切ってください。

### レビューコメントのメタ情報

意図を明確にするため、以下のメタ情報を明示してください：

| メタ情報 | 期待する対応 | 説明 |
| --- | --- | --- |
| [ask] | 回答必須 | 確認 |
| [must] | 修正必須 | この対応がされていないと Approve できない |
| [imo] | 修正任意 | この対応がされていなくても Approve できる |
| [nits] | 修正任意 | 細かい指摘 |
| [next] | 修正不要 | 今後の改善点 |
| [good] | - | 良い点 |

### レビュー結果の出力形式

```markdown
## PRサマリー
[PR概要とハイライト]

## 変更概要
- **変更ファイル数**: X ファイル (+Y 行, -Z 行)
- **主な変更内容**:
  - [カテゴリ]: [詳細説明]

## 詳細分析

### 優れている点
- [良い実装や改善点]

### 検討事項
- [注意すべき点や潜在的な問題]

### 改善提案
- [具体的な改善案]

## リスク評価
**リスクレベル**: [低/中/高]
**根拠**: [評価理由]
```

### 主なレビュー観点

**コード品質**
- 可読性、保守性、再利用性
- コードスタイルの一貫性
- 命名規則の適切性

**設計・アーキテクチャ**
- SOLID原則の遵守
- 既存アーキテクチャとの整合性
- モジュール設計の妥当性

**パフォーマンス**
- 計算量の評価
- メモリ使用量の確認
- ボトルネックの特定

**セキュリティ**
- 一般的な脆弱性の確認
- 機密情報の適切な扱い
- 入力値検証の実装

**テスト**
- カバレッジの評価
- エッジケースの考慮
- テストの品質確認

**ドキュメント**
- コメントの適切性
- README等の更新
- API仕様の整合性
