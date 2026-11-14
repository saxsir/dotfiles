# 日本語の文章

## 常に守ること

- 前置きを書かずに結論から書く
- 確かでないことだけを推量で書き、確かなことは言い切る
- PR・Issue・コミットメッセージも日本語で書く

## スキルの使い分け

- 人が読む既存の日本語の文書（報告書・記事など）を推敲するときは `yomiyasu:yomiyasu`、素材から新しく文書を書くときは `natural-japanese:natural-japanese` を使う。両方に当てはまりそうなら、元の文をどれだけ残すかで決める（残すなら yomiyasu）。
- PR・Issue の本文を書くときも `natural-japanese:natural-japanese` を使う。構成はリポジトリのテンプレートに従い、スキルは文の中身にだけ当てる。
- 提案書や報告書の論旨を検査してほしいとユーザーが頼んだときだけ `natural-japanese:critical-thinking` を使う。
- チャットの応答、コミットメッセージ、PR・Issue へのコメントのような短い文にはどちらも使わない。

# GitHub

- Issue / PR / コメントに画像や動画を載せるときは `gh` の `--attach` で直接アップロードできる (`gh issue create|edit|comment`, `gh pr create|edit|comment`)。書式は `gh pr comment --help` を見る。
- チャットの応答で PR / Issue を挙げるときは `[owner/repo#123](https://github.com/owner/repo/pull/123)` のような Markdown リンクで書く。
