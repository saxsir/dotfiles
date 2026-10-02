# GitHub に書く文章

GitHub の Issue / PR / コメント / レビューコメントを書く・書き直すときは、投稿前に `github-writing` skill (saxsir/skills) を開いてそれに従う。構成 (「3行まとめ」と `<details>` の 2 層構造)、種別ごとの骨格、文体プロファイル、推敲手順は skill が正本で、この rule には持たない。

この rule が持つのは hook が機械的に強制する 2 点だけ。hook の実装と揃える必要があるので、この 2 点はこの rule を正とする。

## 根拠を示す

Issue / PR の参照は `owner/repo#番号` で書く。リポジトリ名の無い `#番号` は、同一リポを指すときも使わない。`#番号` は投稿先のリポジトリ内でしか解決されないので、別リポの Issue を指すつもりで書くと、投稿先の無関係な同番号へ黙ってリンクされる。誤リンクは見た目が正常なリンクと変わらず、投稿後に気づく手がかりが無い。同一リポ参照を例外にすると、書くたびにどちらのつもりかを判断することになる。誤るのはその判断だ。だから例外を置かず、一律に owner/repo を付ける。

closing keyword (`Closes` / `Fixes` / `Resolves`) の行も同じ書式で、`Closes owner/repo#番号` と書く。GitHub の自動クローズはこの構文を受け付け、フル URL では効かない ([GitHub Docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue))。別リポのつもりで書いた `Closes #番号` は、投稿先の無関係な Issue を merge 時に閉じる。

短縮形で書けないもの (コメントの permalink、コードの行) は完全な URL で書く。

投稿本文にリポジトリ名の無い `#番号` が残っていると hook がブロックする (`hooks/block-gh-issue-shorthand.sh`)。検査するのは本文だけで、GitHub がリンク化しないコードブロック内とインラインコード内は対象外。

## 既存本文の更新

PR / Issue の description と投稿済みコメントを直すときは、全文を書き直さず変更箇所だけを編集する。全文を再生成すると、前に書いた経緯や他人の追記が消える。

手順は固定する。

1. 現在値をファイルに取る (`gh pr view <n> --json body --jq .body > <scratch>/body.md`。Issue は `gh issue view`、コメントは `gh api repos/{owner}/{repo}/issues/comments/<id> --jq .body`)。
2. そのファイルを Edit tool で局所編集する。書き直しではなく置換で直す。
3. `diff` で元との差分を出してユーザーに見せ、承認を得る。
4. ファイル渡しで反映する (`gh pr edit <n> --body-file <scratch>/body.md`)。コメントは自分の最新のものだけ `gh pr comment --edit-last --body-file` で直せる。それ以外は `gh api -X PATCH repos/{owner}/{repo}/issues/comments/<id> -F body=@<scratch>/body.md` で渡す。

インラインの `--body`、stdin (`--body-file -`、heredoc)、`gh api` のインライン `-f body=` で既存本文を更新する呼び出しは hook がブロックする。GitHub MCP の書き込みツール (update_pull_request / issue_write 等) は全文差し替えしかできないので、既存本文の更新には使わない。新規作成 (`gh pr create`、新規コメント) はこの手順の対象外。
