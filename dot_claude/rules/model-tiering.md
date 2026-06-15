# モデル階層と委譲 (Model Tiering)

高コストモデルで動いているときは、安価なモデルでこなせる作業を自分の context で消費しない。

## トリガ

セッションの自分（main agent）が **高コスト / premium モデル**で動いているとき。
具体的には Opus 4.8（model ID `claude-opus-4-8`）等。
環境情報の "You are powered by the model named ..." で自分のモデルを確認できる。
（model ID `claude-fable-5` の Fable で動く場合も同様に適用する。）

## 振る舞い

- 小さく機械的なタスクは Sonnet subagent に **ちぎって投げる**。委譲対象の例:
  - grep / ファイル探索 / 大量読み込み
  - 定型修正・ボイラープレート生成・リネーム等の構造変更
  - テスト実行・ログ確認・依存調査
  - 戻りの大きい MCP 呼び出し（Google Drive / Slack / Snowflake 等のファイル内容・大量の検索結果）。
    read-only の subagent に実行させ、要約・抽出結果だけを受け取る。生データを自分の context に流さない
- 委譲時は `model: sonnet` を明示する（Agent tool の `model`、Workflow `agent()` の `opts.model`）。
- 自分（高コストモデル側）は設計判断・統合・**全力のレビュー**・最終検証に専念する。
  subagent の成果を鵜呑みにせず、必ず自分で査読してから採否を決める。

## 避けるべき

- 高コストモデルの context で grep やボイラープレート量産のような安価作業を直接やる
- 大規模・難易度の高い実装（横断的な変更、繊細なリファクタリング、原因不明のデバッグ）を
  Sonnet に委譲する（品質劣化 → レビュー差し戻しの往復が一番高くつく。これらは自分が直接やる）
- 真に自明な単発 lookup まで subagent に投げる（overhead が成果に見合わない。
  委譲はまとまった量の機械的作業に対して行う。@rules/parallelization-and-subagents.md と同じ閾値）

## Why

- 高コストモデルは単価・token 消費が大きい。高価なモデルの context は判断・レビューに使い、
  量産できる実行は安価なモデルに降ろすのが費用対効果で正しい。
- 実行者（Sonnet）と判定者（高コストモデル側）を分けるのは @rules/role-separation.md とも整合する。
  自己生成物を別 context で査読することでバイアスも減る。
