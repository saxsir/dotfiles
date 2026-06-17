---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git log:*), Bash(git fetch:*), Task(*)
description: origin/master (main) との diff を /code-review と /pr-review-toolkit:review-pr で並列レビューし、findings をトリアージして difit に注入してセルフレビューする。draft PR / ローカル merge 前の最終ゲート
---

## Context

- Base branch (remote/branch): !`git rev-parse --abbrev-ref origin/HEAD`
- Current branch: !`git branch --show-current`
- Commits vs base: !`git log --oneline origin/HEAD..HEAD`
- Diff stat vs base: !`git diff --stat origin/HEAD..HEAD`
- Uncommitted changes: !`git status --short`

## あなたのタスク

origin/master (main) との差分を 2 つのレビュー skill で並列レビューし、findings をトリアージして 1 つの difit に注入して開く。
これは書く側の唯一の品質ゲート（`@rules/review-cycle.md` のトラック 1）。

## ワークフロー

進捗を追跡:

```
- [ ] ステップ1: 事前チェック（diff の有無、uncommitted の確認）
- [ ] ステップ2: 2 つのレビュー skill を並列実行
- [ ] ステップ3: findings をトリアージ（マージ・重複統合・低確信除外・provenance タグ）
- [ ] ステップ4: difit skill に渡して起動し、ユーザーにセルフレビューを促す
```

### ステップ1: 事前チェック

Context の結果から base ブランチ名を確定する。**`<BASE>` は必ず `origin/<branch>` 形式の remote-tracking ref（例: `origin/master`、`origin/main`）を使うこと。local の `master`/`main` は使わない。**

remote-tracking を最新化するため、先に `git fetch origin <branch>` を実行する（`<branch>` は `git rev-parse --abbrev-ref origin/HEAD` が指す名前の branch 部分、通常は `master` または `main`）。

- `<BASE>..HEAD` の diff がゼロかつ uncommitted もゼロ → 「レビュー対象なし」と表示して終了
- uncommitted changes がある場合は警告:

```
⚠️  uncommitted changes があります。
difit <base> HEAD は committed diff のみ表示します。
先にコミットしてから /self-review を再実行することを推奨します。
```

uncommitted がある場合でも、レビュー自体は続行する（committed diff があれば）。

### ステップ2: 2 つのレビュー skill を並列実行

**Task tool で以下の 2 エージェントを同時に dispatch する（1 回のメッセージで 2 つの Task 呼び出し）。**

---

**エージェント A — code-review**

```
Skill ツールで skill 名 `code-review` を呼び出してください。

引数: `--json --effort high --min-impact medium`
（取りこぼしを最小にするため effort は high。ブランチにつき 1 回だけ回るゲートなのでコストは許容する）

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

### ステップ3: findings をトリアージ

2 つのエージェントの findings を 1 つに統合する（`@rules/review-cycle.md` の共通トリアージ）:

- 同一ファイル・同一行の重複指摘を 1 件にまとめる。
- 低確信・ノイズの指摘を落とす。
- 各指摘に provenance タグを付ける: code-review 由来は `[code-review]`、toolkit 由来は `[toolkit:<観点>]`（例 `[toolkit:silent-failure]`）。観点が判別できなければ `[toolkit]`。
- severity を difit 表示用に正規化する（critical / high / medium / low。toolkit の Critical / Important / Suggestion は high / medium / low に対応づける）。

### ステップ4: difit skill に渡して起動する

トリアージ済み findings の difit への注入と起動は、**自前で difit コマンドを組み立てず `difit` skill に委譲する**。
difit の canonical な `--comment` スキーマ（1 件 1 フラグ・範囲は `{start,end}` オブジェクト）を単一の source of truth に保つため、ここでスキーマを再実装しない。

**Task tool で 1 エージェントを dispatch し、以下を渡す（`<...>` を実際の値に置き換える）:**

```
Skill ツールで skill 名 `difit` を呼び出し、以下の diff を difit で開いてください。
トリアージ済み findings は startup comments（`--comment`）として注入してください。

対象 diff: `<base> HEAD`（例: `difit origin/master HEAD`）。
`<base>` は必ず remote-tracking ref（`origin/master` / `origin/main`）。local の `master`/`main` は渡さない。

各 finding を 1 件ずつ difit の thread コメントにすること。difit skill が知っている canonical スキーマに従う:
- `type` は `"thread"`
- `position.side` は変更後側なら `"new"`、削除側なら `"old"`
- 複数行は `position.line` を `{"start":N,"end":M}` のオブジェクトに、単一行は数値にする
- body 先頭に severity 絵文字（🔴critical / 🟠high / 🟡medium / 🟢low）と provenance タグ（`[code-review]` / `[toolkit:...]`）を付ける

findings がゼロなら `--comment` なしで difit を起動し「指摘なし」と伝える。

[トリアージ済み findings]
<ステップ3 の結果を貼り付け>
```

- Task エージェントが difit を起動し、ユーザーのセルフレビューを待つ。
- difit を閉じてユーザーのコメントが返ってきたら、その内容に基づいて修正作業に入る。コメントがなければ「LGTM」として終了する。
