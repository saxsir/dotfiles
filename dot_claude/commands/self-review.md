---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git log:*), Bash(command -v difit:*), Bash(difit:*), Bash(npx difit:*), Bash(jq:*), Task(*)
description: master/main との diff を /review と /pr-review-toolkit:review-pr で並列レビューし、findings を 1 つの difit に注入してセルフレビューする。draft PR 前の最終確認に使う
---

## Context

- Base branch (remote/branch): !`git rev-parse --abbrev-ref origin/HEAD`
- Current branch: !`git branch --show-current`
- Commits vs base: !`git log --oneline origin/HEAD..HEAD`
- Diff stat vs base: !`git diff --stat origin/HEAD..HEAD`
- Uncommitted changes: !`git status --short`

## あなたのタスク

master/main との差分を 2 つのレビュー skill で並列レビューし、findings を 1 つの difit に注入して開く。

## ワークフロー

進捗を追跡:

```
- [ ] ステップ1: 事前チェック（diff の有無、uncommitted の確認）
- [ ] ステップ2: 2 つのレビュー skill を並列実行
- [ ] ステップ3: findings をマージして --comment 引数に変換
- [ ] ステップ4: difit を起動してユーザーにセルフレビューを促す
```

### ステップ1: 事前チェック

Context の結果から base ブランチ名を確定する。

- `<base>..HEAD` の diff がゼロかつ uncommitted もゼロ → 「レビュー対象なし」と表示して終了
- uncommitted changes がある場合は警告:

```
⚠️  uncommitted changes があります。
difit HEAD <base> は committed diff のみ表示します。
先にコミットしてから /self-review を再実行することを推奨します。
```

uncommitted がある場合でも、レビュー自体は続行する（committed diff があれば）。

### ステップ2: 2 つのレビュー skill を並列実行

**Task tool で以下の 2 エージェントを同時に dispatch する（1 回のメッセージで 2 つの Task 呼び出し）。**

---

**エージェント A — review-local-changes**

```
Skill ツールで skill 名 `review-local-changes` を呼び出してください。

引数: `--json --min-impact medium`

追加指示（skill に渡してください）:
- レビュー対象は uncommitted changes だけでなく `git diff <BASE>..HEAD` の変更も含める
- 各ファイルの変更は `git diff <BASE>..HEAD -- <ファイル>` で確認する
- GitHub への post は行わない（output only）

最終的に以下の JSON 形式で findings を返してください:
{
  "issues": [
    {
      "file": "src/foo.ts",
      "lines": "42-48",
      "severity": "critical|high|medium|low",
      "description": "...",
      "evidence": "...",
      "suggestion": "（任意）"
    }
  ]
}
```

**（`<BASE>` は実際の base ブランチ名に置き換えること）**

---

**エージェント B — pr-review-toolkit:review-pr**

```
Skill ツールで skill 名 `pr-review-toolkit:review-pr` を呼び出してください。

追加指示（skill に渡してください）:
- レビュー対象は `git diff <BASE>..HEAD` の範囲（uncommitted があれば含む）
- GitHub には post しない（findings は output only）

最終的に以下の JSON 形式で findings を返してください:
[
  {
    "file": "src/bar.ts",
    "line_start": 10,
    "line_end": 15,
    "severity": "Critical|Important|Suggestion",
    "body": "..."
  }
]
```

**（`<BASE>` は実際の base ブランチ名に置き換えること）**

---

両エージェントの結果を受け取ったら次へ進む。

### ステップ3: findings → `--comment` 変換

severity を絵文字にマップ:

| severity | 絵文字 |
|---|---|
| critical | 🔴 |
| high / important | 🟠 |
| medium | 🟡 |
| low / suggestion | 🟢 |

各 finding について `jq -nc` で JSON を組み立て、`COMMENTS` 配列に追加する。
**必ず `jq -nc` を使うこと（シェル特殊文字のエスケープ事故を防ぐため）。**

```bash
# 範囲コメントの例（/review 由来）
jq -nc \
  --arg file "src/foo.ts" \
  --argjson line_start 42 \
  --argjson line_end 48 \
  --arg body "🔴 [/review] description

Evidence: ...

Suggestion: ..." \
  '{type:"thread",filePath:$file,position:{side:"new",line:{start:$line_start,end:$line_end}},body:$body}'

# 単一行の例（pr-review-toolkit 由来）
jq -nc \
  --arg file "src/bar.ts" \
  --argjson line 10 \
  --arg body "🟠 [pr-review-toolkit] description" \
  '{type:"thread",filePath:$file,position:{side:"new",line:$line},body:$body}'
```

変換ルール:
- `line_start == line_end` の場合は `line: N`（整数）、範囲は `line: {start: N, end: M}`
- `side` は基本 `"new"`。削除側のコード（old line）を指す場合のみ `"old"`
- body 先頭: `<絵文字> [/review]` または `<絵文字> [pr-review-toolkit]` の origin タグを付与
- evidence / suggestion は body 内に改行で続けて含める

全 finding を COMMENTS 配列に格納:

```bash
COMMENTS=()
# 各 finding ごとに:
COMMENTS+=(--comment "$(jq -nc ...)")
```

### ステップ4: difit を起動

```bash
DIFIT=$(command -v difit >/dev/null 2>&1 && echo difit || echo "npx difit")

if [ ${#COMMENTS[@]} -eq 0 ]; then
  echo "✅ 指摘なし。difit を素のまま開きます。"
  $DIFIT HEAD "$base"
else
  $DIFIT HEAD "$base" "${COMMENTS[@]}"
fi
```

- `npx difit` がネットワーク制限で失敗した場合は `npm i -g difit` を案内して終了
- difit 起動後、ユーザーへ一言:
  ```
  difit でセルフレビューしてください。
  コメントを書き込んで difit を閉じると、内容がここに返ってきます。
  ```
- ユーザーが difit を閉じてコメントが返ってきたら、その内容に基づいて修正作業に入る
- コメントなしで閉じた場合は「指摘なし / LGTM」として扱い、終了する
