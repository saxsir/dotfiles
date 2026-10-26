# GitHub ワークフロー

実装は default branch を最新化してから切ったフィーチャーブランチで行う。`git com` が default branch へ switch するエイリアス。

PR を作ったらブラウザで開く (`gh pr view --web`)。

レビューコメントへの返信と thread の resolve は、投稿する前に文面と対象をユーザーに見せて承認を得る。

dude の `pr-to-ready` が Step 3 の再確認を通したら、mark-ready (ready-on-clean = no なら clean の報告) の前に、最終ラウンドより前にこの run が投稿した review comment と verdict comment を `~/.claude/scripts/minimize-comments.sh <owner> <repo> <comment-id>...` で OUTDATED に折りたたむ。id は各ラウンドの Request identity に記録したものを使う。ラウンドごとの投稿が積もると、PR の timeline で最終状態が読みにくくなるためだ。最終ラウンドの 2 つと、Step 3 に入る直前の投稿は残す。third terminal state と Escalation で止まるときは折りたたまない。
