# GitHub に書く文章

GitHub の Issue / PR / コメント / レビューコメントを書く・書き直すときは、投稿前に `github-writing` skill (saxsir/skills) を開いてそれに従う。構成 (TL;DR と `<details>` の 2 層構造)、種別ごとの骨格、文体プロファイル、推敲手順は skill が正本で、この rule には持たない。

この rule が持つのは hook が機械的に強制する 2 点だけ。hook の実装と揃える必要があるので、この 2 点はこの rule を正とする。

## 根拠を示す

リンクは完全な URL で書く。`#番号` は同一リポを指すときも使わない。`#番号` は投稿先のリポジトリ内でしか解決されないので、別リポの Issue を指すつもりで書くと、投稿先の無関係な同番号へ黙ってリンクされる。誤リンクは見た目が正常なリンクと変わらず、投稿後に気づく手がかりが無い。同一リポ参照を例外にすると、書くたびにどちらのつもりかを判断することになる。誤るのはその判断だ。だから例外を置かず、一律にフル URL で書く。

例外は closing keyword (`Closes` / `Fixes` / `Resolves`) の行だけ。GitHub の自動クローズが受け付ける構文は `KEYWORD #番号` と `KEYWORD owner/repo#番号` の 2 つで、フル URL では効かない ([GitHub Docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue))。短縮形以外に書きようがないのでここだけ許す。閉じたくないときの `Relates to` はこの制約が無いのでフル URL で書く。

投稿本文に `#番号` が残っていると hook がブロックする (`hooks/block-gh-issue-shorthand.sh`)。検査するのは本文だけで、GitHub がリンク化しないコードブロック内とインラインコード内、それに行全体が closing keyword + 参照になっている行は対象外。

## 既存本文の更新

PR / Issue の description と投稿済みコメントを直すときは、全文を書き直さず変更箇所だけを編集する。全文を再生成すると、前に書いた経緯や他人の追記が消える。

手順は固定する。

1. 現在値をファイルに取る (`gh pr view <n> --json body --jq .body > <scratch>/body.md`。Issue は `gh issue view`、コメントは `gh api repos/{owner}/{repo}/issues/comments/<id> --jq .body`)。
2. そのファイルを Edit tool で局所編集する。書き直しではなく置換で直す。
3. `diff` で元との差分を出してユーザーに見せ、承認を得る。
4. ファイル渡しで反映する (`gh pr edit <n> --body-file <scratch>/body.md`)。コメントは自分の最新のものだけ `gh pr comment --edit-last --body-file` で直せる。それ以外は `gh api -X PATCH repos/{owner}/{repo}/issues/comments/<id> -F body=@<scratch>/body.md` で渡す。

インラインの `--body`、stdin (`--body-file -`、heredoc)、`gh api` のインライン `-f body=` で既存本文を更新する呼び出しは hook がブロックする。GitHub MCP の書き込みツール (update_pull_request / issue_write 等) は全文差し替えしかできないので、既存本文の更新には使わない。新規作成 (`gh pr create`、新規コメント) はこの手順の対象外。
