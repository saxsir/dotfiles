# 計画・設計ワークフロー

変更 (diff を出す作業) と調査の flow は dude plugin が正本。タスクの分類、入口、各段の手順は `dude:using-dude` に従う。この rule が持つのは、dude と食い違う箇所でこの環境が採るほうと、dude に無い局面で呼ぶ skill だけ。ユーザーの明示指示があればそちらが優先。委譲の基準は [[delegation]]、レビューの gate は [[review-cycle]] が source of truth。

## dude と食い違う箇所

次の点は dude の既定ではなく、この環境の rule を採る。理由と詳細は右列の rule が持つ。

| dude の既定 | この環境で採るもの | 正本 |
|---|---|---|
| `plan-work` は TODO の項目ごとに sub-issue を作る | 作る前に分割案を見せ、ユーザーの承認を得る | [[github-workflow]] の Umbrella Issue |
| `pr-to-ready` はレビュースレッドへの返信と resolve を確認なしで行う | 返信文と resolve の対象を見せ、承認を得てから投稿する | [[github-workflow]] のレビューコメントへの応答 |
| `review-code` と `pr-to-ready` は指摘ごとに判定 worker を 1 体起こす | 判定役は 1 ラウンドに 1 体 | [[review-cycle]] |
| `implement-work` は完了ゲートの後に draft PR を作り、そのまま `pr-to-ready` に渡せる | draft PR の後、`pr-to-ready` の前にユーザーの `/crit` を挟む | [[review-cycle]] |
| PR 本文の Issue 参照は、同一リポなら `#NNN` | 書式は rule に従う | [[github-writing]] の「根拠を示す」 |
| `implement-work` の Execution は、メインが実装を書く場面を認める (設計判断の無い変更の lane の manual、些細で独立した変更の inline、理由付きの manual) | 高コストモデルで動いているときは、これらも worker に降ろす | [[delegation]] |

git worktree による隔離は常時の前提で、作るかどうかをユーザーに尋ねない。同一 checkout でブランチを切り替えると、他のセッションの作業状態と干渉するためだ。配置先は `.claude/worktrees/<branch>`。dude の flow では、`implement-work` が決めた branch 名と base を指定して `git worktree add` で作る (EnterWorktree tool の新規作成は base を選べないので、既存の worktree に入るときだけ使う)。Agent tool の `isolation: worktree` は flow の外の単発の委譲に限る。

`superpowers:brainstorming` と `superpowers:writing-plans` が出す設計文書と計画ファイルは、リポジトリに commit しない。決定は tracking issue のコメントに残す ([[docs-lifecycle]])。

## dude に無い局面

| 局面 | skill |
|---|---|
| 前提を潰して収束させたい (ユーザー起動) | `grill-me`。`plan-work` の中の設計合意は dude どおり `superpowers:brainstorming` で行う。`grill-with-docs` は CONTEXT.md / ADR を作るので使わない |
| 会話で決められない問い | `handoff` で切り出し、別セッションで `prototype`、`handoff` で戻す |
| 巨大で全体が見えない | `wayfinder` で決定チケットの map を張る。晴れたら `plan-work` へ |
| 他人起点の issue / bug 報告 | `triage` |
| 一次情報で 1 つの問いに答える | `research` |
| architecture の改善候補を探す | `improve-codebase-architecture` |
| issue を subagent への委譲で進めるよう指示された | `delegate-issue` |

## セッションの区切り

セッションを跨ぐときの選択肢は、続ける / `clear` / `handoff` / subagent / `compact` の 5 つ。`handoff` は新しい harness・新しいディレクトリ・同僚に渡すときだけで、同一ディレクトリで続くなら `compact`。例外として、業務終了で日をまたぐセッションは `eod` で引き継ぎ doc に落とし、翌日はシェルの `resume` から新しいセッションで拾う (夜のうちに prompt cache が切れ、翌朝に長い context を読み直すことになるため)。

## 終了 / 改善

「最初に知っていれば遠回りしなかった」知見は `retrospective-codify` で固定する ([[role-separation]])。skill 自体を育てるときの執筆規範は `writing-for-agents`。
