# GitHub ワークフロー

GitHub Issue / PR を扱うときの前提。git 操作は [[git-branch-workflow]]、文章規約は [[github-writing]]。

## PR

PR は draft で作り (`gh pr create --draft`)、作ったらブラウザで開く (`gh pr view --web`)。ready にするのはユーザー ([[role-separation]])。タイトルは元の Issue に揃えるのが基本で、内容に合わせて調整してよい。

本文は `.github/` にテンプレがあればそれに従う。無ければ「何をしたか」を数行と「なぜ必要か」、それに Issue との紐付けを書く。`Closes #n` を書けば merge 時に自動クローズされる。閉じたくないときは `Relates to #n` にするか `gh pr edit <n> --add-issue <n>` で紐付けだけ張る。

description を後から直すときは、`gh pr view <n> --json body --jq .body` で現在の body を取ってから変更箇所だけ編集する。全文を再生成して上書きすると過去に書いた経緯が失われる。差分をユーザーに見せて承認を得てから `gh pr edit` する。既存 PR にコミットを積んだら、description と紐づく Issue description が古くなっていないか見ておきたい。

## レビューコメントへの応答

unresolved なコメントを集めて応答計画をユーザーに見せ、承認を得てから直す。コミットをコメント単位に分けておくと、どの指摘にどう答えたかを追いやすい。push した後の返信も、ユーザーの確認を得てから投稿する。

## 他 Issue / PR の参照

description やコメント本文から他リポの Issue / PR を指すときは完全な URL を使う。GitHub の自動リンクは同一リポ内の `#番号` しか確実に解決しないため。同一リポ内なら `#番号` のままでよい。

## Umbrella Issue

タイトル prefix は `[Umbrella]` で、進捗はチェックリストで管理する。子 issue の切り出しはユーザーの明示指示があるときだけ行う。
