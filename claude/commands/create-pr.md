# Create Pull Request Command

現在のブランチの変更内容に基づいてdraft PRを作成してください。

## 変更情報（事前取得）

```bash
# 現在のブランチ情報
git rev-parse --abbrev-ref HEAD
git status --short --branch

# コミット履歴（ベースブランチから）
git log origin/main..HEAD --oneline || git log origin/master..HEAD --oneline

# 詳細な差分
git diff origin/main...HEAD || git diff origin/master...HEAD

# 変更ファイルの統計
git diff --stat origin/main...HEAD || git diff --stat origin/master...HEAD
```

## PR作成手順

### 1. 変更内容の分析
- 変更の種類を判定（機能追加、バグ修正、リファクタリング等）
- 影響範囲を特定
- 主要な変更点を抽出

### 2. PR説明文の生成
CLAUDE.mdで定義された形式に従って生成：

```markdown
## What
{{ なにを変えたか？の事実を記載する }}

## Why
{{ なぜこの変更が必要だったのか？を記載する }}
```

### 3. 関連情報の追加
- 関連するissue番号があれば `Closes #123` の形式で追加
- 必要に応じてスクリーンショットやログを追加

### 4. PR文言の確認
⚠️ **重要**: PR作成前に、生成した文言をユーザーに提示して確認・修正してもらう

### 5. Draft PR作成
ユーザーが承認したら、以下のコマンドでdraft PRを作成：

```bash
gh pr create --draft --title "タイトル" --body "本文"
```

## 注意事項

- PR作成前に必ずブランチをpush済みであることを確認
- 未pushの場合は `git push -u origin <branch-name>` を実行
- Draft PRとして作成し、準備ができたらユーザーが手動でReady for reviewに変更
