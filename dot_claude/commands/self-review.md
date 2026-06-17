---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git log:*), Bash(git fetch:*), Task(*)
description: origin/master (main) との diff を /code-review と /pr-review-toolkit:review-pr で並列レビューし、findings をトリアージして markdown でチャットに出力する。draft PR / ローカル merge 前の最終ゲート
---

## Context

- Base branch (remote/branch): !`git rev-parse --abbrev-ref origin/HEAD`
- Current branch: !`git branch --show-current`
- Commits vs base: !`git log --oneline origin/HEAD..HEAD`
- Diff stat vs base: !`git diff --stat origin/HEAD..HEAD`
- Uncommitted changes: !`git status --short`

## あなたのタスク

origin/master (main) との差分を 2 つのレビュー skill で並列レビューし、findings をトリアージして markdown でチャットに出力する。
これは書く側の唯一の品質ゲート（`@rules/review-cycle.md` のトラック 1）。draft PR 作成 / ローカル merge の **前** に回す。

**修正の自動適用はしない**。ユーザーが採否を決め、必要なら明示的に `/simplify` や `/code-review --fix` を追打ちする（`@rules/role-separation.md` / `@rules/review-cycle.md`）。

## ワークフロー

進捗を追跡:

```
- [ ] ステップ1: 事前チェック（diff の有無、uncommitted の確認）
- [ ] ステップ2: 2 つのレビュー skill を並列実行（Sonnet subagent）
- [ ] ステップ3: findings をトリアージ（マージ・重複統合・低確信除外・provenance タグ）
- [ ] ステップ4: severity 順に markdown で出力し、次のアクションをユーザーに委ねる
```

### ステップ1: 事前チェック

Context の結果から base ブランチ名を確定する。**`<BASE>` は必ず `origin/<branch>` 形式の remote-tracking ref（例: `origin/master`、`origin/main`）を使うこと。local の `master`/`main` は使わない。**

remote-tracking を最新化するため、先に `git fetch origin <branch>` を実行する（`<branch>` は `git rev-parse --abbrev-ref origin/HEAD` が指す名前の branch 部分、通常は `master` または `main`）。

- `<BASE>..HEAD` の diff がゼロかつ uncommitted もゼロ → 「レビュー対象なし」と表示して終了
- uncommitted changes がある場合は警告:

```
⚠️  uncommitted changes があります。
レビューは committed diff を対象に行います。uncommitted も含めたい場合は先にコミットしてから /self-review を再実行してください。
```

uncommitted がある場合でも、レビュー自体は続行する（committed diff があれば）。

### ステップ2: 2 つのレビュー skill を並列実行

**Task tool で以下の 2 エージェントを同時に dispatch する（1 回のメッセージで 2 つの Task 呼び出し）。
両方とも `model: sonnet` を明示する**（`@rules/model-tiering.md`）。

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
- severity を正規化する（critical / high / medium / low。toolkit の Critical / Important / Suggestion は high / medium / low に対応づける）。

### ステップ4: markdown で出力する

トリアージ済み findings を **severity 降順**（critical → high → medium → low）で並べ、以下のフォーマットでチャットに出力する。

```markdown
## Self-review findings (<BASE>..HEAD)

対象: <件数> 件（critical: N / high: N / medium: N / low: N）

### 🔴 critical
- **<file>:<line>** `[provenance]` — <要約>
  > <根拠 / suggestion>

### 🟠 high
- ...

### 🟡 medium
- ...

### 🟢 low
- ...

---

次のアクション（必要に応じてユーザーが選ぶ）:
- 構造改善だけ自動適用したい → `/simplify`
- correctness 含めて自動適用したい → `/code-review --fix`
- 修正方針を相談したい → そのまま会話を続ける
```

ルール:

- findings がゼロなら「指摘なし。draft PR 作成 / ローカル merge に進んで OK」と 1 行で返して終わる。
- ファイルパスは作業中リポジトリのルートからの相対パスで書く。
- `<file>:<line>` は Claude Code のチャット上でリンクとして開けるよう、必ず単一行番号 (`src/foo.ts:42`) か行範囲 (`src/foo.ts:42-48`) で書く。
- 各 finding の `>` 引用ブロックには根拠（コードのどこが・なぜ問題か）か suggestion を 1〜2 行で。長い再現コードや巨大な diff は貼らない（要約に留める）。
- **修正は自動適用しない**。「次のアクション」ブロックを必ず最後に出して、判断をユーザーに渡す（`@rules/role-separation.md`）。
