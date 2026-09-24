# 計画・設計ワークフロー

タスクの分類と、局面ごとに呼ぶ skill の対応表。ユーザーの明示指示があればそちらが優先。委譲の基準は [[delegation]]、レビューの gate は [[review-cycle]] が source of truth で、ここは順番だけを持つ。ここに書いてあるのは主に自動発火しない skill (`disable-model-invocation: true`) で、各 skill の詳しい使い分けは `/ask-matt` (mattpocock skills の router) に書いてある。迷ったらそれを読む。

## 分類

着手時に成果物で分ける。

| 成果物 | 分類 | 入口 |
|---|---|---|
| diff (機能追加・原因の分かっている修正・refactor) | 変更 | 起動 → 計画 → 実装 → PR |
| 説明・判断 (原因不明のバグ、性能低下、一次情報で答える問い) | 調査 | `diagnosing-bugs` / `research`。編集を始めない |
| 1 つの skill が出すもの (レビュー結果、spec、チケット、handoff) | 単一 deliverable | その skill を直接呼ぶ。前後に flow を巻かない |

原因不明のバグは調査が先で、直すと決めたら調査結果を入力に「変更」へ入る。再現手順は fix の回帰テストとして持ち越す。

変更は到達している段から入る。合意した設計が無ければ起動から、PR 粒度のチケットが手にあれば実装から、PR があれば PR の段から。設計判断を含まない変更 (述べた時点で interface も構造も決まっている修正) は起動と計画を飛ばしてよいが、飛ばしたことを着手時の一言に書く。設計判断が出てきたらその場で起動へ戻る。

## 変更の flow

### 起動 / 合意

| 局面 | skill |
|---|---|
| リポ初回 | `setup-matt-pocock-skills` (issue tracker / triage label / CONTEXT.md を整える) |
| 前提を潰して収束させる | `grill-with-docs` (CONTEXT.md / docs/adr/ がある前提)。無ければ `grill-me` |
| 会話で決められない問い | `handoff` で切り出し、別セッションで `prototype`、`handoff` で戻す |
| 巨大で全体が見えない | `wayfinder` で決定チケットの map を張る。晴れたら `to-spec` へ (直接 implement に流さない) |
| 他人起点の issue / bug 報告 | `triage`。`to-tickets` 産のチケットには使わない |

### 計画

1 セッションに収まらないなら `to-spec` → `to-tickets`。収まるなら計画ファイルを書かず実装へ。起動から to-tickets までは 1 つの context で通す (compact / clear しない)。

計画は to-tickets か `implement` 側に寄せる。日付付き spec / plan ファイルをリポジトリに積む形式は [[docs-lifecycle]] (最新のものだけを残す) と衝突するので採らない。

### 実装

実装者の分岐は「完了条件を宣言できる粒度まで分解済みか」の 1 軸だけで見る ([[delegation]] と同じ基準)。分解済み (チケットか計画がある) なら `delegate-issue`、チケットが無い単発は Agent tool を直接起こす。未分解で小さいならソロで `implement` (内部で `tdd` を回す)。チケットが複数あれば実装 → PR を 1 チケットずつ回し、後の PR は前の PR の検証を引き継がない。

git worktree による隔離は常時の前提であって分岐条件ではない。同一 checkout でブランチを切り替えると作業状態が干渉する問題の対策も兼ねている。配置先は `.claude/worktrees/<branch>` (EnterWorktree tool か `git worktree add`)。subagent に実装を降ろすときは Agent tool の `isolation: worktree` で足りる。

実装中に構造が触りにくいと感じたら `simplify` ([[review-cycle]])。

### PR

draft PR を作る前に `review` → `crit` の gate を通す ([[review-cycle]])。commit と PR 作成は `commit` / `commit-and-pr`。ready と merge はユーザー ([[role-separation]])。

## 段の境界

段が変わるところで、探索の dump と古い tool 出力を落とした要約を書く。圧縮を理由に gate を緩めない。セッションを跨ぐときの選択肢は、続ける / `clear` / `handoff` / subagent / `compact` の 5 つ。`handoff` は新しい harness・新しいディレクトリ・同僚に渡すときだけで、同一ディレクトリで続くなら `compact`。例外として、業務終了で日をまたぐセッションは `eod` で引き継ぎ doc に落とし、翌日はシェルの `resume` から新しいセッションで拾う (夜のうちに prompt cache が切れ、翌朝に長い context を読み直すことになるため)。

## 終了 / 改善

「最初に知っていれば遠回りしなかった」知見は `retrospective-codify` で固定する ([[role-separation]])。skill 自体を育てるときの執筆規範は `writing-for-agents`。
