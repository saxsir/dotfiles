---
name: review-and-post-inline
description: >
  /review と /pr-review-toolkit:review-pr の両方を並列に実行し、
  findings を 1 レビューに集約して GitHub にインラインコメント投稿する統合レビュースキル。
  「PR をインラインレビューして」「review-and-post-inline」と言われたとき、
  または PR URL / 番号 / owner/repo#番号 と共に呼ばれたときに使う。gh CLI が必要。
argument-hint: "[PR番号 or PR URL or owner/repo#番号]"
model: opus
---

# review-and-post-inline

/review（汎用コードレビュー）と /pr-review-toolkit:review-pr（マルチエージェント・スコアリング付き）を
並列に走らせ、findings を 1 件のレビューに集約して GitHub にインラインコメントとして投稿するスキル。

## 前提条件

- `gh` CLI がインストール済みで認証済みであること
- 対象 PR のリポジトリに対して書き込み権限があること

## Phase 0: 入力解決・検証

引数 `$ARGUMENTS` から PR を解決し、`PR_NUM`・`OWNER`・`REPO` を確定する。

| 引数フォーマット | 解決方法 |
|---|---|
| `https://github.com/owner/repo/pull/N` | そのまま分解 |
| `owner/repo#N` | `#` で分割 |
| 数字のみ | カレントリポジトリの PR |
| 引数なし | カレントブランチの PR を自動解決 |

```bash
# 引数なし・数字のみの場合
gh pr view [<N>] --json number,title,state,url,baseRepository \
  --jq '{number:.number, state:.state, url:.url, owner:.baseRepository.owner.login, repo:.baseRepository.name}'
```

PR が OPEN でない場合は警告してユーザーに確認を取る。

## Phase 1: 並列レビュー (Agent 2 本)

Agent ツールを **2 つ同一メッセージで**（並列に）起動する。
**両 Agent とも GitHub への直接書き込みは絶対に行わない（POST / PATCH 禁止）。**

---

### Agent A — 汎用コードレビュー

```
目的:
  PR の diff を読んで汎用コードレビューを実施し、
  findings を JSON として $TMPDIR/pr-review-findings-A-<PR_NUM>.json に出力する。
  GitHub への書き込み（gh api .../reviews 等の POST/PATCH）は一切しない。

PR: https://github.com/<OWNER>/<REPO>/pull/<PR_NUM>

手順:
1. diff を取得する:
   gh pr diff <PR_NUM> --repo <OWNER>/<REPO> > $TMPDIR/pr-review-<PR_NUM>.diff

2. diff を詳細に読み、以下の観点でレビューする:
   - バグ・実行時エラーのリスク
   - セキュリティ問題（インジェクション・認証・権限）
   - コード品質・可読性・重複
   - テストカバレッジの欠如
   - プロジェクト固有のルール（リポジトリの CLAUDE.md があれば参照）

3. 各 finding について「変更後ファイル」の行番号を算出し検証する:
   - 新規ファイル（ADDED）: diff の + 行を 1 行目からカウント
   - 既存ファイル（MODIFIED）: @@ -a,b +c,d @@ の c を起点に + 行と空白行をカウント（- 行はスキップ）
   - 検証（新規ファイル）: awk 'NR>=<ヘッダー行数+1>{sub(/^\+/,""); print}' diff | sed -n '<line>p'
   - 検証（既存ファイル）: awk '/^@@/{match($0,/\+([0-9]+)/,a); cur=a[1]-1; next} /^[+ ]/{cur++; if(cur==<line>){sub(/^[+ ]/,""); print; exit}} /^-/{next}' diff
   - 表示内容が指摘対象テキストと一致することを確認する

4. $TMPDIR/pr-review-findings-A-<PR_NUM>.json に以下スキーマの JSON 配列を書き出す:
   [
     {
       "path": "src/foo.ts",
       "line": 42,
       "severity": "critical",
       "category": "bug",
       "body": "🔧 変数 `x` が初期化前に参照されています。...",
       "suggestion": "const x = 0;"
     }
   ]
   suggestion は修正後の行の完全テキスト（省略可）。指摘がなければ [] を出力する。
```

---

### Agent B — マルチエージェントレビュー（スコアリング付き）

```
目的:
  ~/.claude/plugins/marketplaces/context-engineering-kit/plugins/review/skills/review-pr/SKILL.md
  の Phase 1〜Phase 3 ステップ 3（スコアリングまで）を実行し、
  impact >= 61 かつ confidence >= 65 の issue を JSON に出力する。

  重要: Phase 3 ステップ 4「Post Inline Comments Only」は実行しない。
        gh api .../reviews・gh pr comment などの POST/PATCH は一切呼ばない。

PR: https://github.com/<OWNER>/<REPO>/pull/<PR_NUM>

レビューエージェントは以下を並列起動する（上記 SKILL.md の Phase 2 に従う）:
  bug-hunter / security-auditor / code-quality-reviewer
  （変更内容によって contracts-reviewer / test-coverage-reviewer / historical-context-reviewer も）

スコアリング後、MIN_IMPACT=high（impact >= 61 / confidence >= 65）を満たした issue を
$TMPDIR/pr-review-findings-B-<PR_NUM>.json に書き出す:
[
  {
    "path": "src/bar.py",
    "line": 15,
    "severity": "high",
    "category": "security",
    "body": "🔧 ユーザー入力が SQL クエリに直接結合されています。...",
    "suggestion": "db.query('SELECT * FROM users WHERE id = ?', [userId])",
    "confidence": 80,
    "impact": 75,
    "agent_name": "security-auditor"
  }
]
指摘がなければ [] を出力する。GitHub への書き込みは一切しない。
```

---

両 Agent の完了を待つ。

## Phase 2: 集約・dedupe

両ファイルを `jq` で統合する。

```bash
A_FILE="$TMPDIR/pr-review-findings-A-${PR_NUM}.json"
B_FILE="$TMPDIR/pr-review-findings-B-${PR_NUM}.json"
OUT_FILE="$TMPDIR/pr-review-findings-${PR_NUM}.json"

# ファイルが空または存在しない場合は [] で補完
[ -s "${A_FILE}" ] || echo "[]" > "${A_FILE}"
[ -s "${B_FILE}" ] || echo "[]" > "${B_FILE}"

jq -s '
  def severity_rank: if . == "critical" then 0 elif . == "high" then 1 elif . == "medium" then 2 else 3 end;
  (.[0] | map(. + {sources: ["review"]})) +
  (.[1] | map(. + {sources: ["toolkit"]}))
  | group_by([.path, (.line | tostring)])
  | map(
      if length == 1 then .[0]
      else
        (sort_by(.severity | severity_rank) | .[0]) as $p
        | (sort_by(.severity | severity_rank) | .[1]) as $s
        | $p + {
            body: ($p.body + "\n\n_(同行を別レビュアーも指摘: " + ($s.body | split("\n")[0]) + ")_"),
            sources: ([.[].sources[]] | unique)
          }
      end
    )
  | sort_by(.severity | severity_rank)
' "${A_FILE}" "${B_FILE}" > "${OUT_FILE}"
```

## Phase 3: ユーザーへの提示と承認

集約結果を以下のフォーマットで提示する:

```
## レビュー集約結果 — <OWNER>/<REPO> PR #<PR_NUM>

投稿予定: <N> 件  ( 🔴 critical: x  /  🟠 high: y  /  🟡 medium: z  /  🟢 low: w )

| # | severity | file:line | 概要 |
|---|----------|-----------|------|
| 1 | 🔴 | src/foo.ts:42 | 🔧 変数 x が初期化前に参照 |
| 2 | 🟠 | src/bar.py:15 | 🔧 SQL インジェクション |
...

投稿してよいですか？（drop したい指摘があれば番号を教えてください）
```

ユーザーが drop 指示をした場合は該当を除いて再提示する。承認が得られたら Phase 4 へ。

## Phase 4: 行番号最終検証と投稿

diff がまだ取得されていない場合は再取得する:

```bash
gh pr diff "${PR_NUM}" --repo "${OWNER}/${REPO}" > "$TMPDIR/pr-review-${PR_NUM}.diff"
```

**各 finding の行番号を検証する（必須・全件実施）。**
算出した行番号と diff の実際のテキストが一致しない finding は行番号を修正するか除外する。

投稿 JSON を構築する。`suggestion` が存在する finding は body 末尾に以下を付加する:

````
\n\n```suggestion\n<suggestion テキスト>\n```
````

```bash
# 投稿 JSON を $TMPDIR/pr-review-post-${PR_NUM}.json に書き出す
# body（サマリー）と comments 配列を組み立てる

gh api "repos/${OWNER}/${REPO}/pulls/${PR_NUM}/reviews" \
  --method POST \
  --input "$TMPDIR/pr-review-post-${PR_NUM}.json"
```

`event` は常に `COMMENT`（`APPROVE` / `REQUEST_CHANGES` はユーザーが明示した場合のみ）。

レスポンスの `.errors[]` を確認する。エラーがあれば内容をユーザーに伝えてリトライ判断を委ねる。

## Phase 5: 結果報告

成功したら投稿件数と PR URL を返す:

```
<N> 件のインラインコメントを投稿しました:
https://github.com/<OWNER>/<REPO>/pull/<PR_NUM>
```

## スタイル基準

- レビュー `body`（サマリー）には件数のみ。指摘の詳細は全てインラインへ
- 各インラインコメントの構成:
  - 1 行目: 絵文字プレフィックス + 1 行サマリー
    - `🔧` 要修正（バグ・事実誤り）
    - `💡` 提案（改善案）
    - `❓` 質問（意図確認）
    - `📝` 軽微（typo・フォーマット）
  - 2 行目以降: 根拠（コード片・関連ファイル・実測値）
  - 末尾: 修正案が確定している場合は suggestion ブロックで対象行の完全置換を提示
- **断定的に書く**（「確認してください」ではなく「〜が間違っています」）
- suggestion ブロックは対象行の**完全置換後テキスト**（部分的な断片は不可）

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| Agent A/B がファイルを生成しなかった | 空配列として扱い、もう一方の findings で続行 |
| 422 Unprocessable Entity | 行番号が不正。該当 finding の行番号を再計算してリトライ |
| 403 Forbidden | 書き込み権限なし。ユーザーに確認 |
| 404 Not Found | PR 番号またはリポジトリが間違っている |

## 注意事項

- Phase 1 の両 Agent は GitHub への書き込みを一切行わない（POST / PATCH 禁止）
- 投稿は Phase 4 の 1 回のみ。`post-pr-review-comments` と重複して呼ばない
- suggestion ブロックの内容は**対象行の完全な置換後テキスト**（差分ではなく行全体）
- 複数行 suggestion は `start_line`（開始行）と `line`（終了行）を指定する
