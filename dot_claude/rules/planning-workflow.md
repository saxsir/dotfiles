# 計画・設計ワークフロー

設計を詰める〜作業に割るフェーズで、superpowers と mattpocock/skills のどちらを既定で使うかのデフォルト。迷ったとき用であり、明示指示があればそちらを優先する。

- **発散（任意）**: ふわっとした要望から設計空間を広げる段は `superpowers:brainstorming`
- **収束＋言語化**: 設計を詰める既定は `grill-with-docs`（決定木を質問で潰しつつ `CONTEXT.md` / `docs/adr/` を更新）。それらが無いプロジェクトでは `grill-me` で代替
- **作業分解**: queue / 委譲する作業は `to-issues` →（`triage`）。今すぐ自分で回す作業は `superpowers:writing-plans` を手動で使う
- **実行**: `superpowers` の実行メカニクス（`using-git-worktrees` / `subagent-driven-development` / `verification-before-completion`）

superpowers の計画 skill は無効化していない（手動でいつでも呼べる）。TDD / デバッグの重複 skill は `rules/tdd.md` 等を source of truth とする。
