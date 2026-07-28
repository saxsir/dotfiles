# 計画・設計ワークフロー

skill のフェーズ別の割り当て。ユーザーの明示指示があればそちらが優先。重複する領域は [[delegation]] を source of truth とする。ここに書いてあるのは主に自動発火しない skill (`disable-model-invocation: true`) で、自動発火するものは skill 側の description に任せる。

## 起動 / 合意

前提を潰して収束させるのは `grill-with-docs` (CONTEXT.md / docs/adr/ があることが前提)。無ければ `grill-me`。

## 計画 / 作業場

1 セッションに収まらない規模の計画は `wayfinder` で issue tracker 上に map を張って fog を晴らす。委譲を前提に spec 化するなら `to-spec`、作業分解は `to-tickets` (必要に応じて `triage`)。

`writing-plans` は `subagent-driven-development` の入力 plan を作る用途に限る。SDD の task-brief と Global Constraints の照合が writing-plans の形式を前提にしているため。SDD で実行しないなら、計画は to-tickets か `implement` 側に寄せる。

## 実行

`using-git-worktrees` による隔離は常時の前提であって分岐条件ではない。同一 checkout でブランチを切り替えると作業状態が干渉する問題の対策も兼ねている。

実装者の分岐は「完了条件を宣言できる粒度まで分解済みか」の 1 軸だけで見る ([[delegation]] と同じ基準)。分解済み (チケットか計画がある) なら `subagent-driven-development`、未分解で小さいならソロで `implement`。context が逼迫してセッションを跨ぐときは `handoff`。

選択肢に入れないものが 3 つある。`executing-plans` は subagent が使えない環境向けのフォールバック。`dispatching-parallel-agents` は計画実行用ではなく、独立した複数の問題 (調査・バグ修正) を並列で回すためのもの。`brainstorming` (superpowers) は使わない — 起動・合意は grill 系が担当しており、日付付き spec を積む設計が [[docs-lifecycle]] (最新のものだけを残す) と衝突するため。

## 終了 / 改善

skill 自体を育てるときの執筆規範は `writing-great-skills`。
