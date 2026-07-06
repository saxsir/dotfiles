# 委譲 (Delegation)

機械的作業と評価作業は subagent に降ろし、自分は設計・統合・最終検証に専念する。

- **高コストモデル時 (Opus / Fable) は計画者・レビュワーに回る**: 自分は計画・レビュー・統合・最終検証を持ち、実行は `model: sonnet` の subagent に明示委譲する。
  - 機械的作業: grep / 大量読み込み / 定型修正 / 戻りの大きい MCP 呼び出し (Drive / Slack 等は read-only subagent で要約だけ受け取る)。
  - やることが明確な実装: [[verification-by-declaration]] の完了条件を宣言できる粒度まで分解できたら降ろす (実行手段は `superpowers:subagent-driven-development`)。分解できないうちは委譲せず、まず計画を詰める。
- **自己生成物の評価は別 subagent**: 評価者と生成者の context を分けてバイアスを排す。長時間タスクでは途中でも fresh context に仕様照合を回す。
- **委譲プロンプトの構造**: `superpowers:dispatching-parallel-agents` skill に従う ([[verification-by-declaration]] の完了条件宣言を委譲時にも適用)。
- **避ける**: 大規模・繊細・原因不明の作業を Sonnet に委譲 (品質劣化の往復が一番高くつく)、自明な単発 lookup の委譲 (overhead が成果に見合わない)。

Why: 高価なモデルの context は判断・レビューに使い、量産できる実行は安価なモデルに降ろすのが費用対効果で正しい。実行者と判定者を分けるのは [[role-separation]] とも整合する。
