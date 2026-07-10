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

- ソロ実装: `implement` (自動発火なし)
- 委譲・並列: `subagent-driven-development` / `dispatching-parallel-agents` ([[delegation]] の実行手段)
- セッション越境: `handoff` (context 逼迫時、自動発火なし)

## 4. 終了 / 改善

- 書く側レビュー: [[review-cycle]] の 2 トラック
- 他人 PR: [[review-cycle]] の「他人 PR」節
- skill 育成: `writing-great-skills` (執筆規範、自動発火なし)
