---
name: brain-distill
description: auto-memory (~/.claude/projects/*/memory/) を横断レビューし、プロジェクトを跨いで再利用できる知見・思考パターンを蒸留して brain (saxsir/brain-mcp の brain/) への追加を提案する。「蒸留して」「memory を brain にまとめて」と言われたとき、または /brain-distill で使う。引数でパスを渡すと、そのディレクトリ / ファイル群を蒸留元にできる。
---

# Brain Distill

auto-memory(短期の作業記憶)から、長期で再利用される知識だけを brain(キュレーション層)へ蒸留する。
brain の実体は `~/src/github.com/saxsir/brain-mcp/brain/*.md`(private repo で git 管理)。
運用方針の原典は brain の `brain-policy` ページ。

## 蒸留の基準

**採用**(brain に入れる):

- 複数プロジェクト・将来のセッションで再利用される判断基準・思考パターン・原則
- ユーザーの強い好み・働き方(レビュー観点、委譲の閾値、ツール選定の哲学など)
- 繰り返し参照されている知見(複数の memory ページに同じ話が散らばっているのは統合のシグナル)

**不採用**(memory に残す):

- 単一リポジトリ固有の事実(それは memory の役割。蒸留後も元ページは消さない)
- コード・git 履歴・公開ドキュメントから導出できる事実
- 一時的な作業状態・進行中タスクのメモ

## 手順

1. **収集を subagent に委譲する**(main context を生データで汚さない)。
   蒸留元は引数があればそのパス、なければ `~/.claude/projects/*/memory/*.md`(`MEMORY.md` 除く)。
   subagent には「各ページの name / description / 蒸留候補になりうる要点」だけを返させる
2. **既存 brain ページと突き合わせる**。`~/src/github.com/saxsir/brain-mcp/brain/` の既存ページを読み、
   重複候補は新規作成ではなく既存ページへの追記・統合として扱う
3. **候補ごとに提案してユーザー承認を得る**。提示する内容: name(kebab-case)/ description /
   本文案 / 出典(元 memory ページ名とプロジェクト)。**承認なしに書かない**(brain-policy の原則)
4. **承認分のみ書き込む**。`brain/<name>.md` に memory と同じ形式
   (frontmatter: `name` / `description` / `metadata.type`)で Write する。
   関連ページへは `[[name]]` リンクを張る(出典 memory ページへのリンクを含める)
5. **コミット**。brain-mcp リポジトリで日本語メッセージ(prefix 英語)でコミットする。
   push はユーザーに委ねる
6. **検証**。brain MCP がセッションにあれば `brain_search` で新ページがヒットすることを確認する。
   なければ JSON-RPC スモークで代替:
   `printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' '{"jsonrpc":"2.0","method":"notifications/initialized"}' '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"brain_search","arguments":{"query":"<新ページの特徴語>"}}}' | npx tsx ~/src/github.com/saxsir/brain-mcp/src/index.ts 2>/dev/null | tail -1`

## 書き方の流儀

- 逐語 > 要約: ユーザーの言い回しが特徴的な部分は原文を保持する
- 1 ページ 1 知識。盛り込みすぎない
- description は検索でヒットの重みが付く(name/description ヒット = 2 点)ので、検索語になりそうな言葉を入れる
