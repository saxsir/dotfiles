---
paths:
  - "dot_claude/rules/**/*.md"
  - ".claude/rules/**/*.md"
---

# Claude Rules File Format

rule ファイル (`dot_claude/rules/*.md` はグローバル、`.claude/rules/*.md` はこのリポ限定) を書くときの約束。仕様の最新は https://code.claude.com/docs/en/memory を見る。

1 ファイル 1 トピックにし、ファイル名でトピックが分かるようにする。本文は [[writing-style]] に従い、振る舞いの規則は理由を添えた地の文で書く。箇条書きは参照用の列挙 (コマンド、パス、承認が要る操作の一覧など) に使う。規則と理由を箇条で切り離すと、適用範囲を読み手が推測することになるため。

`paths` frontmatter は、その規則が特定のファイル群を触るときにしか意味を持たない場合だけ付ける。
