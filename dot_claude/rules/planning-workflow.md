# 計画・設計ワークフロー

skill のフェーズ別割り当て。明示指示があれば優先。重複領域は rule ([[delegation]] [[verification-by-declaration]]) を source of truth とする。以下は自動発火しない skill (`disable-model-invocation: true`) を明示するのが主目的。自動発火する skill は description に任せる。

## 1. 起動 / 合意

- 収束・前提潰し: `grill-with-docs` (CONTEXT.md / docs/adr/ 前提) / 無いときは `grill-me` (いずれも自動発火なし)

## 2. 計画 / 作業場

- 1 セッションに収まらない大規模計画: `wayfinder` (issue tracker 上に map を張って fog を晴らす、自動発火なし)
- Spec 化 (ready-for-agent): `to-spec`
- 作業分解: `to-tickets` →(`triage`)
- 今すぐ自分で回す計画 (`to-spec`/`to-tickets` の委譲前提と使い分け): `writing-plans`

## 3. 実行

- 隔離: `using-git-worktrees` は常時前提 (分岐条件ではない。同一 checkout でブランチ切替時に作業状態が干渉する問題の対策も兼ねる)
- 実装者の分岐は「完了条件を宣言できる粒度まで分解済みか」の 1 軸のみ ([[delegation]] と同じ基準):
  - 分解済み (チケット / 計画あり) → `subagent-driven-development`
  - 未分解・小さい → ソロ実装: `implement` (自動発火なし)
- 選択肢に含めないもの:
  - `executing-plans` は subagent 不可環境向けフォールバック
  - `dispatching-parallel-agents` は計画実行用ではなく、独立した複数問題 (調査・バグ修正) の並列用
- セッション越境: `handoff` (context 逼迫時、自動発火なし)

## 4. 終了 / 改善

- skill 育成: `writing-great-skills` (執筆規範、自動発火なし)
