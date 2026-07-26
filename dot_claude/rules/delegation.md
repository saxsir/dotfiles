# 委譲 (Delegation)

機械的作業は subagent に降ろし、自分は設計・統合・最終検証に専念する。

- **高コストモデル時 (Opus / Fable) は計画者・レビュワーに回る**: 自分は計画・レビュー・統合・最終検証を持ち、実行は `model: sonnet` の subagent に明示委譲する。
  - 機械的作業: grep / 大量読み込み / 定型修正 / 戻りの大きい MCP 呼び出し (Drive / Slack 等は read-only subagent で要約だけ受け取る)。
  - やることが明確な実装: 観測可能な完了条件 (通すべきテスト名・実行コマンド・確認する出力・閾値) を宣言できる粒度まで分解できたら降ろす (実行手段は `subagent-driven-development`)。分解できないうちは委譲せず、まず計画を詰める。
  - built-in 実行系 agent (`Explore` / `general-purpose` / `claude-code-guide` 等) の呼び出しは `model: sonnet` を明示する。`model` 省略 (`inherit`) は親モデル継承となり、Opus / Fable 実行時に機械的作業まで高コストで走る。
- **委譲プロンプトの構造**: `dispatching-parallel-agents` skill に従う (完了条件宣言を委譲時にも適用)。
- **避ける**: 大規模・繊細・原因不明の作業を Sonnet に委譲 (品質劣化の往復が一番高くつく)、自己検証・二重チェック目的の subagent (モデル自身の検証と重複して過検証になる。ユーザー起動のレビューゲートは [[review-cycle]] が正)。

Why: 高価なモデルの context は判断・レビューに使い、量産できる実行は安価なモデルに降ろすのが費用対効果で正しい。
