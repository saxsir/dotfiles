---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
description: Performs Kent Beck's Tidy First refactoring by making structural changes separate from behavioral changes. Use when the user wants to refactor code, clean up structure, or mentions tidying or Kent Beck principles.
---

## Context

- Git status: !`git status --short --branch`
- Git diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## あなたのタスク

Kent Beckの「Tidy First」リファクタリングをコードベースに適用してください。これは動作を変更せずにコードの構造を改善する**構造的変更**を行うことを意味します。

## Tidy First ワークフロー

進捗チェックリストをコピーして追跡してください：

```
Tidying進捗:
- [ ] ステップ1: すべてのテストが通ることを確認（Greenフェーズ）
- [ ] ステップ2: 必要な構造改善を特定
- [ ] ステップ3: 一度に1つのtidyingを実施
- [ ] ステップ4: 各tidying後にテストを実行
- [ ] ステップ5: 構造変更を個別にコミット
- [ ] ステップ6: コードがきれいになるまで繰り返す
```

### ステップ1: すべてのテストが通ることを確認

**重要**: Greenフェーズ（すべてのテストが通っている状態）でのみtidyingを行ってください。

- すべてのテストを実行して現在の状態を確認
- テストが失敗している場合は、tidyingの前にまず修正
- 壊れたコードをtidyingしてはいけません

### ステップ2: 必要な構造改善を特定

以下のようなtidyingの機会を探してください：

**対処すべきcode smell:**
- 重複したコードブロック
- 長いメソッド（20行以上）
- 不明瞭な変数名・メソッド名
- 深くネストした条件分岐
- デッドコード（未使用の変数、メソッド）
- 説明のないマジックナンバー
- 一貫性のないフォーマット

**優先すべきtidying:**
- 重複を除去するもの
- 明確性と可読性を向上させるもの
- 次の動作変更を容易にするもの

### ステップ3: 一度に1つのtidyingを実施

**重要**: 1コミットにつき1つのtidyingのみ。複数の構造変更を混在させないでください。

**一般的なtidyingパターン:**

1. **Extract Method**: コードブロックを名前付きメソッドに抽出
2. **Rename**: 変数、メソッド、クラスにより明確な名前を付ける
3. **Extract Variable**: 複雑な式に名前を付ける
4. **Inline**: 不要な間接参照を削除
5. **Move**: コードをより適切な場所に移動
6. **Delete Dead Code**: 未使用のコードを削除
7. **Normalize Format**: 一貫したフォーマットを適用

**例 - Extract Method:**
```
変更前:
  if (user.age >= 18 && user.hasLicense && !user.isSuspended) {
    // ... 複雑なロジック
  }

変更後:
  if (canDrive(user)) {
    // ... 複雑なロジック
  }
```

### ステップ4: 各tidying後にテストを実行

**動作が変更されていないことを検証:**

- 各構造変更の後に完全なテストスイートを実行
- テストは以前と同じ結果で通るはず
- テストが失敗した場合、tidyingが動作を変更した（すぐに修正）
- 自動テストがない場合は、手動で動作を確認

### ステップ5: 構造変更を個別にコミット

**コミット規律:**

- コミットメッセージ: `refactor: <構造変更の説明>`（日本語）
- 例: `refactor: ユーザー認証ロジックをメソッドに抽出`
- 構造変更と動作変更を1つのコミットに混在させない
- コミットは小さく焦点を絞ったものにする

### ステップ6: コードがきれいになるまで繰り返す

tidyingサイクルを継続:
- 1つのtidying → テスト → コミット → 次のtidying

以下の状態になったら停止:
- コードが明確で整理されている
- 明らかな重複が残っていない
- 次の動作変更が容易に実装できる

## 基本原則

**構造変更と動作変更を分離する:**
- **構造変更（STRUCTURAL CHANGES）**: 動作を変えずにコードを再配置
  - 例: rename, extract method, move code, format
  - コミットメッセージ: `refactor: ...`
  - 検証: テストが同じ結果で通ること

- **動作変更（BEHAVIORAL CHANGES）**: 機能を追加または修正
  - 例: バグ修正、機能追加、アルゴリズム変更
  - コミットメッセージ: `feat: ...` または `fix: ...`
  - 検証: テストが新しい動作を確認すること

**これらを同じコミットに混在させてはいけません。**

**常にまずtidying、その後動作変更:**
1. 変更を容易にするためにコードをtidying
2. tidyingを個別にコミット
3. 動作変更を実施
4. 動作変更を個別にコミット

## 重要な注意事項

- Greenフェーズ（すべてのテストが通っている状態）でのみtidyingする
- すべてのtidyingの後に必ずテストを実行
- 次のtidyingの前に各tidyingを個別にコミット
- 日本語で意味のあるコミットメッセージを使用
- 時間節約のためにテストをスキップしない
- tidyingがテストを壊した場合、それは動作を変更した（すぐに修正）
