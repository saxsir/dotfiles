# レビューサイクル

ブランチ境界 (draft PR 直前) で self-review を回す。**コミット境界ではレビューしない** ([[commit-discipline]] の可否判断だけで通す、速度優先)。

## 書く側 (self-review)

draft PR 直前に `/code-review --effort high` と `/pr-review-toolkit:review-pr` を Sonnet subagent で **並列**実行。findings をマージ・重複統合・provenance タグ付けして severity 順に markdown で出力。**修正の自動適用はしない** (採否はユーザー、[[role-separation]])。

`/code-review --fix` と `/simplify` を回すのは **working tree が clean** な時だけ ([[tidy-first]] の構造/振る舞いコミット分離が機械的に保たれる)。

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload などに触れたら、self-review と別に `/security-review` を回す (起動はユーザー承認後)。

## 他人 PR

`review-assigned-pr` で対象選定 → トリアージ → **投稿予定コメント一覧をユーザーに提示し承認後**、`review-and-post-inline` で GitHub インライン投稿。投稿の締めはユーザー。
