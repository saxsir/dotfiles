---
name: retrospective-codify
description: セッション終了時または「学びを残して」と指示されたときに、今回のタスクから「最初に知っていれば遠回りしなかった」知見を抽出し、ast-grep ルール / skill / CLAUDE.md(rules) ルールのいずれかに固定する。プロンプトに頼らず再現可能な形に落とすことを優先する。
---

# Retrospective Codify

直近のタスクから学びを抽出し、Claude を継続的に育てるための skill。

原典: [mizchi/skills/retrospective-codify](https://github.com/mizchi/skills/blob/main/retrospective-codify/SKILL-ja.md) を本 dotfiles 環境向け（chezmoi 管理 / `~/.claude/rules/*.md` 体系）に調整。

## いつ使うか

- セッション終了時の Stop hook から自動起動される（既定）
- ユーザーから「学びを残して」「ルール化して」と指示されたとき
- 試行錯誤の末に解にたどり着いたとき（初手で詰まった、誤った仮説を立てた、ドキュメント不足で時間を溶かした 等）

使わない場面:

- 一発で通った単純なタスク（抽出する学びがない → 「採用候補なし」で正常終了）
- プロジェクト固有の一回限りの対応（コミットメッセージで十分）

## ワークフロー

1. **失敗⇄成功の対応付け**: 今回のタスクから次の 3 点を書き出す。
   - 最初の試行（何をした / どう失敗した）
   - 最終解（何が効いた）
   - 橋渡しになった気付き（なぜ最初の試行では届かなかったか）
2. **「最初に知るべきだったこと」の言語化**: 気付きを 1〜3 文で要約する。回顧でなく未来の自分への指示形で書く（"〜するな" / "〜を先に確認せよ"）。
3. **分類**: 下の判定表に従って出力先を決める。
4. **重複チェック（必須）**: 提案前に既存の知見と照合する。重複や近接する規則があれば「新規追加」ではなく「既存への追記 / 更新」を選ぶ。これを怠ると skill / ルールが肥大化する。

   検索キー候補は気付きから 2〜3 語抽出する（ツール名・API 名・症状語・対義語）。

   照合先と最低限の検索:

   ```bash
   # global skill
   ls ~/.claude/skills/
   grep -rli "<key>" ~/.claude/skills/*/SKILL.md

   # global CLAUDE.md / rules
   grep -li "<key>" ~/.claude/CLAUDE.md ~/.claude/rules/*.md

   # project CLAUDE.md（該当プロジェクトがある場合）
   grep -li "<key>" <repo>/CLAUDE.md

   # ast-grep ルール（既存があれば）
   ls <repo>/rules/ 2>/dev/null
   ```

   結果を 4 段階に分類:

   - **新規**: ヒット無し → 通常の提案
   - **既存追記**: 関連 skill/ルールが存在し、追加情報が補完的 → 「既存に追記」を提案
     - 「部分重複」（学びの一部だけが既存カバー、残りが新規）もこの分類に含める。重複した部分は「重複検出」節に、新規部分は「採用候補」節（`[skill 追記]` または `[rule]`）に分けて書く。
   - **既存と重複（提案不要）**: 既存が同じ知見を完全カバー → 提案ゼロ。ただし提示フォーマットには「重複検出」行を残す（監査可能性のため）。重複検出行には根拠として既存 skill 名 + 該当節名（または行番号）を添える。
   - **判断保留**: 重複かどうか agent が判定できない → ユーザーに照合結果を見せて判断を仰ぐ
5. **書き出し**: 選んだ形式のテンプレート（後述）に沿って artifact を生成する。
6. **確認**: ユーザーに diff を見せて採用可否を取る。棄却された場合は skill ではなくセッション内のメモに留める。

## 分類判定

```dot
digraph classify {
    "機械的に検出可能？" [shape=diamond];
    "毎回適用すべき短い指示？" [shape=diamond];
    "複数ステップの手順や判断を伴う？" [shape=diamond];
    "ast-grep ルール / lint" [shape=box];
    "CLAUDE.md / rules ルール" [shape=box];
    "skill" [shape=box];
    "メモに留める" [shape=box];

    "機械的に検出可能？" -> "ast-grep ルール / lint" [label="yes"];
    "機械的に検出可能？" -> "毎回適用すべき短い指示？" [label="no"];
    "毎回適用すべき短い指示？" -> "CLAUDE.md / rules ルール" [label="yes"];
    "毎回適用すべき短い指示？" -> "複数ステップの手順や判断を伴う？" [label="no"];
    "複数ステップの手順や判断を伴う？" -> "skill" [label="yes"];
    "複数ステップの手順や判断を伴う？" -> "メモに留める" [label="no"];
}
```

| 判定軸 | 出力先 | 例 |
|---|---|---|
| コード/設定の構文レベルで検出可能 | `ast-grep` ルール または既存 linter 設定 | "`Array.from(set).length` を使うな、`set.size` を使え" |
| 短く、常時適用、判断を伴わない | `~/.claude/CLAUDE.md` / `~/.claude/rules/*.md` / project `CLAUDE.md` | "pnpm は v10 以上を使う" |
| 手順・文脈判断・テンプレが必要 | 新規 skill または既存 skill への追記 | "PR レビューコメント投稿手順" |
| プロジェクト固有で一回限り | 採用しない（コミットメッセージ / PR 説明に留める） | — |

**ast-grep を優先する原則**: 静的に検出可能なものはプロンプトやドキュメントに書かず、必ず `ast-grep` ルールにする。プロンプト/散文で書くとエージェントは守らない。

**CLAUDE.md / rules の書き出し先**:

- 言語横断・ツール横断の一般則 → `~/.claude/CLAUDE.md`（chezmoi 管理: 実体は `~/src/github.com/saxsir/dotfiles/dot_claude/CLAUDE.md` を編集）
- 既存ルール体系（TDD / Tidy First / commit / git / github / code-quality）に該当 → `~/.claude/rules/<topic>.md`（実体: `dot_claude/rules/<topic>.md`）
- 既存ルール体系に収まらない新トピック → `dot_claude/rules/<topic>.md` を新設し `dot_claude/CLAUDE.md` に `@rules/<topic>.md` 参照を追加
- 特定リポジトリ限定 → そのリポジトリの `CLAUDE.md`

**chezmoi を経由する**: `~/.claude/` 配下を直接編集しない。`~/src/github.com/saxsir/dotfiles/dot_claude/` を編集 → `chezmoi apply` で反映。直接編集すると次の apply で消える。

## 出力テンプレート

### ast-grep ルール

`<repo>/rules/` ディレクトリに YAML を追加し、`<repo>/rule-tests/` に valid / invalid ペアを必ず書く。

```yaml
id: <kebab-case-id>
language: <TypeScript|Python|...>
severity: warning
rule:
  pattern: <検出パターン>
message: <修正方針 1 行>
```

### CLAUDE.md / rules への追記

```markdown
# <既存セクション or 該当 rules/*.md に追記>
- <命令形の 1 文>（理由: <短い根拠>）
```

理由を括弧書きで必ず添える（将来の自分が edge case を判断できるように）。

### 新規 skill

`superpowers:writing-skills` の最小テンプレに従う:

```markdown
---
name: <kebab-case>
description: Use when <具体的な状況> / <症状>
---

# <Title>

## 目的
## いつ使うか
## ワークフロー
## 落とし穴
```

## 具体例

### 例 1: ast-grep ルール化（機械検出可能）

- 最初の試行: TypeScript で集合のサイズを `Array.from(set).length` で取得していたが、レビューで非効率と指摘された。
- 最終解: `set.size` を使う。
- 気付き: `Set` / `Map` のサイズ取得は `.size` プロパティを使う。`Array.from(...).length` は構文レベルで検出可能。

→ `rules/no-array-from-size.yml` を追加:

```yaml
id: no-array-from-size
language: TypeScript
severity: warning
rule:
  pattern: Array.from($COLL).length
message: Set/Map のサイズは .size プロパティを使う。
```

### 例 2: rules/*.md 追記（短い常時ルール）

- 最初の試行: `pnpm install` を実行したら lockfile 形式の差分で CI が落ちた。
- 最終解: pnpm のバージョンを v10 系に揃えた。
- 気付き: pnpm はバージョン差で lockfile が変わる。常に v10 以上を使う。

→ `dot_claude/CLAUDE.md` の「Tool Preferences」節に追記（または既存 rules に該当節がなければそこへ）:

```markdown
- pnpm は v10 以上を使う（理由: lockfile 形式が v9 以前と非互換で CI 差分が出る）
```

### 例 3: 新規 skill 化（手順 + 判断を伴う）

- 最初の試行: PR のレビューコメントに対して個別に手作業で返信していた。
- 最終解: `gh api` で unresolved コメントを取得 → 計画提示 → コメント単位でコミット → push 後にスレッド返信、という固定手順。
- 気付き: 単一手順では収まらず、取得・計画・コミット・返信の 4 段を一括理解する必要がある。

→ 新規 skill `post-pr-review-comments` として手順とテンプレを切り出し（既に存在するため、本例は「重複チェックで既存への追記」を選ぶケース）。

## Red flags（合理化に注意）

下記の思考が出たら一度止まる。

| 出てくる合理化 | 実態 |
|---|---|
| 「プロジェクト固有だけど一応 skill にしておこう」 | skill が肥大化し検索性が落ちる。コミットメッセージ / PR で十分。 |
| 「承認は省いて先に書き出しておこう、後で見せればいい」 | 勝手に CLAUDE.md / skill を変更すると将来の挙動が読めなくなる。必ず提案 → 承認 → 書き出し。 |
| 「ast-grep で書ける気もするけど、自然言語でルールに書いた方が早い」 | 静的検出可能なものを散文で書くと、エージェントが守らない。ast-grep を優先。 |
| 「気付きが薄いけど、何か書かないと格好がつかない」 | 提案ゼロも正解。空の retrospective は害がない。 |
| 「重複チェックは面倒だから飛ばそう、被ったら後で消せばいい」 | 重複ルールが残ると挙動が割れる。dedup は必須工程。 |
| 「失敗の側は省いて、最終解だけ書けばいい」 | 失敗の記述がないと、将来の自分は同じ落とし穴に再度落ちる。 |
| 「`~/.claude/` を直接編集すれば早い」 | 次の `chezmoi apply` で消える。dotfiles source を編集。 |

## ユーザーへの提示フォーマット

タスク終了時に次の形で棚卸しを提示する。**学びは複数あって良い。重複や不採用も明示的に列挙して、判断の足跡を残す。**

```
## Retrospective

### 学び 1: <短いラベル>
- 最初の失敗: <1 行>
- 最終解: <1 行>
- 気付き: <1 行>

### 学び 2: <短いラベル>      # 学びが 1 つだけならこのブロックは省く
- 最初の失敗: <1 行>
- 最終解: <1 行>
- 気付き: <1 行>

## 提案

採用候補:
- [lint] <ルール名>: <1 行>（artifact: <path>, 学び N 由来）
- [skill 追記] <既存 skill 名>: <1 行>（学び N 由来）
- [skill 新規] <skill 名>: <1 行>（学び N 由来）
- [rule] <CLAUDE.md or rules/X.md or project CLAUDE.md>: <1 行>（学び N 由来）

重複検出（提案不要）:
- <学び N>: 既存 <skill/rule 名> の <該当節名 or 行番号> が完全カバー → 追加なし

不採用:
- <学び N>: <不採用理由 1 行>（例: プロジェクト固有 / cross-file で lint 表現困難 / 他の学びに吸収）

採用するものを番号または項目名で指示してください。提案ゼロも妥当な結論です。
```

**書式ルール:**

- 学びが 1 つなら `### 学び N` 見出しは省き、Retrospective ブロックを 1 つだけ書く
- 「採用候補」「重複検出」「不採用」のいずれかが空ならその節ごと省く（"なし" 行は書かない）
- 各提案行末に「学び N 由来」を必ず書く（複数学びを跨ぐ場合は「学び 1, 3 由来」のように列挙して良い）
- 「採用候補」が空で「重複検出」のみ残るときは、末尾文を `採用するものを指示してください` ではなく `採用候補なし。記録目的でレビューしてください。` に置き換える
- ユーザーが採用を指示した項目のみ書き出す。黙って書き出さない

### 提示例: 全学びが既存カバー（重複検出のみ）

```
## Retrospective

### 学び 1: <ラベル>
- 最初の失敗: ...
- 最終解: ...
- 気付き: ...

## 提案

重複検出（提案不要）:
- 学び 1: 既存 skill `<skill 名>` の `<節名>` が完全カバー → 追加なし

採用候補なし。記録目的でレビューしてください。
```

### 提示例: 部分重複（既存追記 + 重複検出）

```
## 提案

採用候補:
- [skill 追記] <既存 skill 名>: <新規部分の 1 行>（学び 1 由来, 既存節 `<節名>` への補完）

重複検出（提案不要）:
- 学び 1（version 値部分）: 既存 `~/.claude/CLAUDE.md` Tool Preferences 節が既にカバー → 追記不要
```

## よくある失敗

- **粒度が細かすぎる**: その一回限りの事情（特定の関数名、特定のバージョン）までルール化してしまう → 抽象化して「何を確認するか」レベルに引き上げる
- **プロンプトで書きがち**: 静的に検出可能な規則を自然言語で CLAUDE.md に書く → `ast-grep` ルールに移す
- **理由を書かない**: ルールの根拠が残らず、将来の自分がなぜそれを守るのか判断できなくなる → 必ず `理由:` を添える
- **勝手に書き出す**: ユーザー承認なしに CLAUDE.md や skill を更新する → 必ず提案 → 承認 → 書き出し の順を守る
- **失敗の言語化を省く**: 「最終解は X」だけ書いて、なぜ初手で詰まったかを残さない → 失敗側の記述が無いと、将来の自分は同じ落とし穴にまた落ちる
- **chezmoi を経由しない**: `~/.claude/` 直下を直接編集すると次の `chezmoi apply` で消える → 必ず `dot_claude/` を編集

## 関連 skill

- `superpowers:writing-skills` — 新規 skill を書くときのテンプレと TDD フロー
- `claude-md-management:claude-md-improver` — CLAUDE.md 専用の改善 skill。`[rule]` 提案を CLAUDE.md に書き出す際に内部呼び出ししても良い
- `update-config` — `settings.json` / permissions の変更が必要な場合
