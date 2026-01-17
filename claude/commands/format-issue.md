---
allowed-tools: Bash(gh issue view:*), Bash(gh issue edit:*)
description: Format GitHub Issue Description Command
---

## Context

- Issue details: !`gh issue view $ARGUMENTS --json number,title,body,author,state,labels,comments,url`
- Closed by (if any): !`gh issue view $ARGUMENTS --json closedByPullRequestsReferences`

## Your task

GitHub Issue #$ARGUMENTS のdescriptionを指定のフォーマットに書き直してください。

### フォーマット仕様

以下のフォーマットに沿って、Issue descriptionを書き直してください：

```markdown
## 背景・解決したい課題 (Why)
<!-- このIssueを書くに至った状況・条件を説明してください -->
<!-- 背景から導かれる問題やアイデアを記載してください -->

[ここに背景と課題を記載]

## 終了条件・ゴール（Solution）
<!-- このIssueが完了したと言える状態を具体的に記載してください -->
<!-- ※1イテレーション（2週間）で終わらない場合は子Issueに分けましょう -->

[ここにゴールを記載]

## 関連情報
<!-- 関連するIssue、PR、ドキュメント、参考資料などがあれば記載してください -->

[ここに関連情報を記載]
```

### 作業手順

1. **Issue内容の分析**
   - Issue本文とコメントから必要な情報を抽出
   - 背景・課題・ゴールを特定
   - 不足している情報を確認

2. **フォーマットへの変換**
   - 元のIssue内容を3つのセクションに整理:
     - **背景・解決したい課題**: なぜこのIssueが必要か、どんな問題があるか
     - **終了条件・ゴール**: どうなれば完了か、何を実現するか
     - **関連情報**: 関連Issue、PR、ドキュメント、参考URLなど

3. **不足情報の扱い**
   - 元のIssueから読み取れない情報がある場合:
     - ユーザーに質問して確認
     - または `[あとで書く]` として埋める

4. **確認と更新**
   - フォーマット済みのdescriptionをユーザーに提示
   - 内容の確認を依頼
   - ユーザーの承認後、`gh issue edit $ARGUMENTS --body "..."` で更新

## 重要な注意事項

- 元のIssue内容を正確に理解し、情報の欠落や誤解がないようにする
- 背景や課題が不明確な場合は、必ずユーザーに確認する
- フォーマット後は必ず一度ユーザーに見せて承認を得てから更新する
- GitHub CLI (`gh`) を使用してIssue情報の取得と更新を行う
