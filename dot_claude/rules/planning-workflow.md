# 計画・設計ワークフロー

skill のフェーズ別割り当て。明示指示があれば優先。重複領域は rule ([[tdd]] [[delegation]] [[verification-by-declaration]]) を source of truth とする。

## 1. 起動 / 合意

- 発散: `superpowers:brainstorming`
- 収束・前提潰し: `grill-with-docs` (CONTEXT.md / docs/adr/ 前提) / 無いときは `grill-me`
- 会話冒頭ゲート: `superpowers:using-superpowers` (自動発火)

## 2. 計画 / 作業場

- PRD 化 (ready-for-agent): `to-prd`
- 作業分解: `to-issues` →(`triage`)
- 今すぐ自分で回す計画: `superpowers:writing-plans`
- 作業場隔離: `superpowers:using-git-worktrees`

## 3. 実行

- ソロ実装: `implement` + `/tdd`
- 委譲・並列: `superpowers:subagent-driven-development` / `superpowers:dispatching-parallel-agents` ([[delegation]] の実行手段)
- セッション越境: `handoff` (context 逼迫時)

## 4. 品質

- TDD: `tdd` / `superpowers:test-driven-development`
- デバッグ: `diagnosing-bugs` / `superpowers:systematic-debugging`
- 完了検証: `superpowers:verification-before-completion`

## 5. 終了 / 改善

- 書く側レビュー: [[review-cycle]] の 2 トラック
- 他人 PR: [[review-cycle]] の「他人 PR」節 (専用 skill は退役済み)
- レビュー受け: `superpowers:receiving-code-review` ([[non-sycophancy]] の実行手段)
- ブランチ完了: `superpowers:finishing-a-development-branch`
- skill 育成: `writing-great-skills` (執筆規範) / `superpowers:writing-skills` (pressure test)
- 振り返り: `retrospective-codify`
