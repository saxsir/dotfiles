---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git log:*), Bash(git fetch:*), Bash(command -v difit:*), Bash(difit:*), Bash(npx difit:*), Bash(jq:*), Task(*)
description: origin/master (main) との diff を /review と /pr-review-toolkit:review-pr で並列レビューし、findings を 1 つの difit に注入してセルフレビューする。draft PR 前の最終確認に使う
---

## Context

- Base branch (remote/branch): !`git rev-parse --abbrev-ref origin/HEAD`
- Current branch: !`git branch --show-current`
- Commits vs base: !`git log --oneline origin/HEAD..HEAD`
- Diff stat vs base: !`git diff --stat origin/HEAD..HEAD`
- Uncommitted changes: !`git status --short`

## あなたのタスク

origin/master (main) との差分を 2 つのレビュー skill で並列レビューし、findings を 1 つの difit に注入して開く。

## ワークフロー

進捗を追跡:

```
- [ ] ステップ1: 事前チェック（diff の有無、uncommitted の確認）
- [ ] ステップ2: 2 つのレビュー skill を並列実行
- [ ] ステップ3: findings をマージして --comment 引数に変換
- [ ] ステップ4: difit を起動してユーザーにセルフレビューを促す
```

### ステップ1: 事前チェック

Context の結果から base ブランチ名を確定する。**`<BASE>` は必ず `origin/<branch>` 形式の remote-tracking ref（例: `origin/master`、`origin/main`）を使うこと。local の `master`/`main` は使わない。**

remote-tracking を最新化するため、先に `git fetch origin <branch>` を実行する（`<branch>` は `git rev-parse --abbrev-ref origin/HEAD` が指す名前の branch 部分、通常は `master` または `main`）。

- `<BASE>..HEAD` の diff がゼロかつ uncommitted もゼロ → 「レビュー対象なし」と表示して終了
- uncommitted changes がある場合は警告:

```
⚠️  uncommitted changes があります。
difit HEAD <base> は committed diff のみ表示します。
先にコミットしてから /self-review を再実行することを推奨します。
```

uncommitted がある場合でも、レビュー自体は続行する（committed diff があれば）。

### ステップ2: 2 つのレビュー skill を並列実行

**Task tool で以下の 2 エージェントを同時に dispatch する（1 回のメッセージで 2 つの Task 呼び出し）。**

---

**エージェント A — review-local-changes**

```
Skill ツールで skill 名 `review-local-changes` を呼び出してください。

引数: `--json --min-impact medium`

追加指示（skill に渡してください）:
- レビュー対象は uncommitted changes だけでなく `git diff <BASE>..HEAD` の変更も含める
- 各ファイルの変更は `git diff <BASE>..HEAD -- <ファイル>` で確認する
- GitHub への post は行わない（output only）

最終的に以下の JSON 形式で findings を返してください:
{
  "issues": [
    {
      "file": "src/foo.ts",
      "lines": "42-48",
      "severity": "critical|high|medium|low",
      "description": "...",
      "evidence": "...",
      "suggestion": "（任意）"
    }
  ]
}
```

**（`<BASE>` は実際の remote-tracking ref に置き換えること。例: `origin/master`、`origin/main`。local の `master`/`main` は使わない）**

---

**エージェント B — pr-review-toolkit:review-pr**

```
Skill ツールで skill 名 `pr-review-toolkit:review-pr` を呼び出してください。

追加指示（skill に渡してください）:
- レビュー対象は `git diff <BASE>..HEAD` の範囲（uncommitted があれば含む）
- GitHub には post しない（findings は output only）

最終的に以下の JSON 形式で findings を返してください:
[
  {
    "file": "src/bar.ts",
    "line_start": 10,
    "line_end": 15,
    "severity": "Critical|Important|Suggestion",
    "body": "..."
  }
]
```

**（`<BASE>` は実際の remote-tracking ref に置き換えること。例: `origin/master`、`origin/main`。local の `master`/`main` は使わない）**

---

両エージェントの結果を受け取ったら次へ進む。

### ステップ3+4: difit 表示を Task エージェントに委譲

ステップ2で得た findings を渡す **Task エージェントを 1 つ dispatch する**。
Task エージェントは allowed-tools の制限を受けないため、jq・bash 変数代入など自由に使える。

**Task エージェントへのプロンプト（<...> を実際の値に置き換えて渡す）:**

```
difit-review skill を使って、以下の findings を difit に表示してください。

対象 diff: HEAD vs <base>（例: `difit HEAD origin/master`）。`<base>` は必ず remote-tracking ref（`origin/master` / `origin/main` など）であること。local の `master`/`main` を渡さない。

[/review からの findings]
<ステップ2 エージェント A の出力をそのまま貼り付け>

[pr-review-toolkit からの findings]
<ステップ2 エージェント B の出力をそのまま貼り付け>

表示ルール:
- body 先頭に severity 絵文字（🔴critical / 🟠high|important / 🟡medium / 🟢low|suggestion）
- body に origin タグ [/review] または [pr-review-toolkit] を付与
- findings がゼロなら --comment なしで difit を起動し「指摘なし」と表示
- difit を閉じた後、ユーザーのコメントがあれば報告。なければ「LGTM」として終了
```

- Task エージェントが difit を起動し、ユーザーのセルフレビューを待つ
- difit を閉じてコメントが返ってきたら、その内容に基づいて修正作業に入る
