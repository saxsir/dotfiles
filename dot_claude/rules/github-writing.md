# GitHub に書く文章

読み手は人間。情報の網羅性より読者の認知負荷を優先する。AI 実行向けの issue にも同じ書き方をする (AI は人間向けの文章を読めるが逆は成り立たない)。

この rule は要約で、詳細版は `github-writing` skill (saxsir/skills、ユーザー起動専用) が持つ。種別ごとの骨格・レビューコメントのラベル・GitHub Markdown の落とし穴はそちらを開く。両者が食い違ったら、GitHub の機構に関する事実は skill、投稿・承認の手順はこの rule を採り、この rule を直して揃える。

## 2 層構造

本文には人間向けの文章だけを置く。行番号付きのコード根拠・網羅チェック表・仕様準拠表・生データは末尾の `<details>` にまとめる。details の中は AI が再調査するための領域なので、密度に制限はない。

## 本文

冒頭に `## TL;DR` を短く置き、見出しや表より先に結論を出す。文体は [[writing-style]] に従う。書き始める前に `~/.claude/style-profile.md` (本人が AI 以前に書いた issue / PR から抽出した文体) を読み、見出しのラベル・節の役割の示し方・締め方を下敷きにする。プロファイルは `~/.claude/rules/*.md` より下位で、規則と食い違う傾向はプロファイル末尾の「下書きで採らない傾向」に従って持ち込まない。主語と述語が欠けた断片を並べるのは避けるが、文末を常体に落とした結果の体言止めや、短い括弧補足は使ってよい。

表に入れるのは短い列挙事実だけにして、複文や根拠やコード参照をセルに詰めない。行番号付きのコード参照は details に送り、本文では言葉で指す。

状態記号 (✅⚠️❌) は本文で使わない。太字は要所だけに絞る。

## 根拠を示す

調査結果を書くときは、結論の根拠を一次情報へのリンクで示す。読み手が自分で確かめられる状態にするのが目的なので、ソースコードなら該当箇所へのリンク、仕様なら公式ドキュメントの URL を置く。

リンクは完全な URL で書く。GitHub は短縮形 `owner/repo#番号` も自動リンクするが、URL のほうが読み手が飛び先をひと目で判別できる。ソースコードの行位置は短縮形では書けないので、そもそも URL (commit SHA 入りの permalink) しか選択肢がない。

`#番号` は同一リポを指すときも使わない。`#番号` は投稿先のリポジトリ内でしか解決されないので、別リポの Issue を指すつもりで書くと、投稿先の無関係な同番号へ黙ってリンクされる。誤リンクは見た目が正常なリンクと変わらず、投稿後に気づく手がかりが無い。同一リポ参照を例外にすると、書く時点でどちらのつもりかを毎回判断することになり、その判断こそが誤る箇所なので、例外を置かず一律にフル URL で書く。

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

## コメント投稿

短い相槌以外、手順・ログ・コード片・表を含むものは `<details><summary>1 行要約</summary>本文</details>` で畳む (summary の直後に空行を入れる)。
