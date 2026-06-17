# レビューサイクル

コードレビューツールを開発フローに組み込む際の既定。「いつ・どれを・どの順で回すか」を規定する。
原則は **レビューの重さを「コスト × 不可逆性」に合わせる** こと。安いチェックは頻繁に、重いチェックは境界で 1 回だけ。

ツールの棲み分け（混同しやすいので明記）:

- `/code-review`（組み込み）: current diff の correctness + reuse/簡素化/効率。`--effort low|medium|high|max`、`--comment`（PR インライン投稿）、`--fix`（working tree に適用）。
- `/simplify`（組み込み）: バグ探索をせず構造改善だけを適用する。
- `/pr-review-toolkit:review-pr`（プラグイン）: 6 専門エージェント（code-reviewer / test / silent-failure / type-design / comment / simplifier）。出力はチャット。
- `/review`（組み込み）: PR を 1 回レビューする。
- `/security-review`: pending changes のセキュリティレビュー（whitebox/exploit/blackbox、issue 起票）。重い。
- 複合スキル: `self-review`（書く側の境界ゲート）、`review-assigned-pr` / `review-and-post-inline`（他人の PR をレビュー）。

## トラック 1: 自分が書くとき

コミット境界ではレビューしない。`@rules/commit-discipline.md` の可否判断（tests green / 警告解消 / 単一論理単位）だけで通す（速度・コスパ優先）。

唯一の品質ゲートは **ブランチ境界**（draft PR 直前、または PR を作らないリポではローカル merge 直前）の `self-review`。
ここで `/code-review --effort high` と `/pr-review-toolkit:review-pr` を並列で回し、findings をトリアージして difit に出す。

### Tidy First との両立

`/code-review --fix` と `/simplify` の自動適用は、**working tree が clean（振る舞いの変更がコミット済み）なときにだけ** 回す。
出力が定義上「構造変更だけ」になり、`@rules/tidy-first.md` のコミット分離が機械的に保たれる。
authoring 中に correctness を見たいときは `/code-review`（`--fix` なし）を read-only で使い、指摘は手で振る舞いコミットに畳む。

### security ゲート（条件付き）

diff が次のいずれかに触れたら、self-review とは別に `/security-review` を回す:
認証 / 認可 / 入力検証 / ファイルアップロード / redirect・SSRF / secret・credential / 外部 API 呼び出し / デシリアライズ / SQL・クエリ組立 / テンプレート描画。
起動と target URL 等の対話セットアップは **ユーザーが確認する**（`@rules/role-separation.md`）。触れなければ回さない。

## トラック 2: 他人の PR をレビューするとき

`review-assigned-pr` で対象を選び、findings をトリアージしたうえで **投稿予定コメント一覧をユーザーに提示し、承認を得てから** `review-and-post-inline` で GitHub インライン投稿する。
インラインコメントは対外行為なので、投稿の締めはユーザーが持つ（`@rules/role-separation.md` / `@rules/github-writing.md`）。

## 両トラック共通: findings のトリアージ

difit / GitHub に出す前に必ずトリアージする:

- `/code-review` と toolkit の findings をマージし、同一ファイル・同一行の重複を 1 件に統合する。
- 低確信・ノイズの指摘を落とす。
- どのツール / 専門エージェント発かが分かる provenance タグを付ける（例 `[code-review]`、`[toolkit:silent-failure]`）。

高コストモデルで動いているときは、fan-out するレビュー実行を subagent に降ろし、自分は findings の査読・採否に専念する（`@rules/model-tiering.md`）。
