# 計画・設計ワークフロー

変更と調査の flow は dude plugin (`dude:using-dude`) が正本。dude と食い違う箇所でこの環境が採るほうは、該当する dude の skill 名を挙げて各 rule が持つ ([[delegation]]、[[review-cycle]]、[[github-workflow]]、[[github-writing]])。この rule は環境の前提と、dude に無い局面だけを持つ。

git worktree による隔離は常時の前提で、作るかどうかをユーザーに尋ねない (同一 checkout でのブランチ切り替えは他のセッションと干渉する)。配置先は `.claude/worktrees/<branch>`。dude の flow では `implement-work` が決めた branch 名と base で `git worktree add` する。EnterWorktree は base を選べないので既存の worktree に入るときだけ使う。Agent tool の `isolation: worktree` は flow の外の単発の委譲に限る。

`superpowers:brainstorming` と `superpowers:writing-plans` が出す設計文書と計画ファイルは commit せず、決定は tracking issue のコメントに残す。

## dude に無い局面

| 局面 | skill |
|---|---|
| 前提を潰して収束させたい (ユーザー起動) | `grill-me`。`plan-work` の中の設計合意は dude どおり `superpowers:brainstorming` |
| 会話で決められない問い | `handoff` で切り出し、別セッションで `prototype`、`handoff` で戻す |
| 一次情報で 1 つの問いに答える | `research` |
| architecture の改善候補を探す | `improve-codebase-architecture` |
| issue を subagent への委譲で進めるよう指示された | `delegate-issue` |
| rule・skill を書く、育てる | `writing-for-agents` |

## セッションの区切り

同一ディレクトリで続くなら `compact`。`handoff` は新しい harness・新しいディレクトリ・同僚に渡すときだけ使う。業務終了で日をまたぐなら `eod` で引き継ぎ doc に落とし、翌日はシェルの `resume` から新しいセッションで拾う (夜のうちに prompt cache が切れ、翌朝に長い context を読み直すことになるため)。
