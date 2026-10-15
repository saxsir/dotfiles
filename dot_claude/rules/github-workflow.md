# GitHub ワークフロー

GitHub Issue / PR を扱うときの前提。git 操作は [[commit-discipline]]、文章規約と画像・動画の添付 (`gh --attach`) は `github-writing` skill (hook と連動する必須事項は `rules/github-writing.md`)。

## PR

PR は draft で作り (`gh pr create --draft`)、作ったらブラウザで開く (`gh pr view --web`)。ready にするのはユーザー ([[role-separation]])。ユーザーが自分で ready にするか、dude の `pr-to-ready` が冒頭で尋ねる ready-on-clean に yes と答えるかのどちらかで、Claude は ready-on-clean に代わりに答えない。yes の run でも、`mark-ready.sh` の実行は permission の ask ルールで承認プロンプトが出る。タイトルは元の Issue に揃えるのが基本で、内容に合わせて調整してよい。

本文は `.github/` にテンプレがあればそれに従う。無ければ「何をしたか」を数行と「なぜ必要か」、それに Issue との紐付けを書く。`Closes owner/repo#n` を書けば merge 時に自動クローズされる。閉じたくないときは `Relates to owner/repo#n` にするか `gh pr edit <n> --add-issue <n>` で紐付けだけ張る。参照書式は [[github-writing]] に従う。

description を後から直す手順は [[github-writing]] の「既存本文の更新」に従う (現在値を取り、変更箇所だけ編集し、差分の承認を得て `--body-file` で反映)。既存 PR にコミットを積んだら、description と紐づく Issue description が古くなっていないか確かめ、古ければこの手順で直す。

## レビューコメントへの応答

unresolved なコメントを集めて応答計画をユーザーに見せ、承認を得てから直す。コミットをコメント単位に分けておくと、どの指摘にどう答えたかを追いやすい。push した後の返信も、ユーザーの確認を得てから投稿する。

dude の `pr-to-ready` のラウンド内は扱いが違う。修正は判定役の accept に従って承認なしで進める。返信文と resolve の対象は、投稿する前に承認を取る。修正は過程の品質で Claude が持つ側、返信と resolve は対外的な締めでユーザーが持つ側だからだ ([[role-separation]])。

返信と resolve 以外の `pr-to-ready` の書き込み (レビュアーへの依頼、requesting-code-review の指摘コメント、base の付け替え、verbose の集約コメント) は承認なしで進める。自分の PR の上で回すレビューの過程で、対外的な締めではないからだ。

## Umbrella Issue

タイトル prefix は `[Umbrella]` で、進捗はチェックリストで管理する。子 issue の切り出しはユーザーの明示指示があるときだけ行う。dude の `plan-work` が sub-issue を作る段では、作る前に分割案を見せて承認を得る。その承認が明示指示に当たる。
