# 計画・設計ワークフロー

skill のフェーズ別の割り当て。ユーザーの明示指示があればそちらが優先。重複する領域は [[delegation]] を source of truth とする。ここに書いてあるのは主に自動発火しない skill (`disable-model-invocation: true`) で、自動発火するものは skill 側の description に任せる。

## 起動 / 合意

前提を潰して収束させるのは `grill-with-docs` (CONTEXT.md / docs/adr/ があることが前提)。無ければ `grill-me`。

## 計画 / 作業場

1 セッションに収まらない規模の計画は `wayfinder` で issue tracker 上に map を張って fog を晴らす。委譲を前提に spec 化するなら `to-spec`、作業分解は `to-tickets` (必要に応じて `triage`)。

計画は to-tickets か `implement` 側に寄せ、別形式の plan 文書は作らない。日付付き spec / plan を積む設計は [[docs-lifecycle]] (最新のものだけを残す) と衝突する。

## 実行

git worktree による隔離は常時の前提であって分岐条件ではない。同一 checkout でブランチを切り替えると作業状態が干渉する問題の対策も兼ねている。配置先は `.claude/worktrees/<branch>` (EnterWorktree tool か `git worktree add`)。subagent に実装を降ろすときは Agent tool の `isolation: worktree` で足りる。

実装者の分岐は「完了条件を宣言できる粒度まで分解済みか」の 1 軸だけで見る ([[delegation]] と同じ基準)。分解済み (チケットか計画がある) なら `delegate-issue`、未分解で小さいならソロで `implement`。context が逼迫してセッションを跨ぐときは `handoff`。

## 終了 / 改善

skill 自体を育てるときの執筆規範は `writing-great-skills`。
