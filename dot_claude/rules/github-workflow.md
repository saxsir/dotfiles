# GitHub ワークフロー

GitHub Issue / PR を扱うときの前提。git 操作は [[git-branch-workflow]]、文章規約は `github-writing` skill (hook と連動する必須事項は `rules/github-writing.md`)。

## PR

PR は draft で作り (`gh pr create --draft`)、作ったらブラウザで開く (`gh pr view --web`)。ready にするのはユーザー ([[role-separation]])。タイトルは元の Issue に揃えるのが基本で、内容に合わせて調整してよい。

本文は `.github/` にテンプレがあればそれに従う。無ければ「何をしたか」を数行と「なぜ必要か」、それに Issue との紐付けを書く。`Closes owner/repo#n` を書けば merge 時に自動クローズされる。閉じたくないときは `Relates to owner/repo#n` にするか `gh pr edit <n> --add-issue <n>` で紐付けだけ張る。Issue / PR の参照は同一リポでも `owner/repo#n` で書き、リポジトリ名の無い `#n` は使わない ([[github-writing]] の「根拠を示す」)。

description を後から直す手順は [[github-writing]] の「既存本文の更新」に従う (現在値を取り、変更箇所だけ編集し、差分の承認を得て `--body-file` で反映)。既存 PR にコミットを積んだら、description と紐づく Issue description が古くなっていないか確かめ、古ければこの手順で直す。

## 画像・動画の添付

Issue / PR / コメントにスクリーンショットや動画を載せるときは `gh` の `--attach` を使う (gh 2.99.0 以降)。対応コマンドは `gh issue create` / `issue edit` / `issue comment` / `pr create` / `pr edit` / `pr comment` で、フラグは複数回指定できる。

```bash
gh pr comment 123 --attach './before.png#修正前' --attach './after.png#修正後'
```

`#` の後ろが alt text になる (省略時はファイル名)。本文に同じローカルパスへの参照があればそこが upload 後の URL に置き換わり、無ければ末尾に追記される。書きたい位置に置くなら本文側に `![alt](./before.png)` を先に書いておく。

制約は次のとおり。画像・GIF は 10 MB まで、動画は Free 10 MB / 有料 100 MB まで、1 回の投稿で 50 ファイルまで。対応形式は PNG / JPEG / GIF / WebP / SVG / MP4 / MOV / WebM。リポジトリへの write 権限が要り、GitHub Enterprise Server では使えない。

## レビューコメントへの応答

unresolved なコメントを集めて応答計画をユーザーに見せ、承認を得てから直す。コミットをコメント単位に分けておくと、どの指摘にどう答えたかを追いやすい。push した後の返信も、ユーザーの確認を得てから投稿する。

dude の `pr-to-ready` のラウンド内は扱いが違う。修正は判定役の accept に従って承認なしで進める。返信文と resolve の対象は、投稿する前に承認を取る。修正は過程の品質で Claude が持つ側、返信と resolve は対外的な締めでユーザーが持つ側だからだ ([[role-separation]])。

## Umbrella Issue

タイトル prefix は `[Umbrella]` で、進捗はチェックリストで管理する。子 issue の切り出しはユーザーの明示指示があるときだけ行う。dude の `plan-work` が sub-issue を作る段では、作る前に分割案を見せて承認を得る。その承認が明示指示に当たる。
