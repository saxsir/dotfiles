# レビューサイクル

書く側のレビューは **2 トラック**。実装中は機械的に回し、PR 提出前にゲートを 1 回置く。**コミット境界では回さない** ([[commit-discipline]] の可否判断だけで通す、速度優先)。

## モデル指定の原則

書く側のレビュー (`/simplify` / `/code-review` / `/review` / `/security-review`) を subagent に降ろす場合は、**モデルに Opus (現在使える最良モデル) を指定する**。Sonnet には降ろさない。これは [[delegation]] の Why (判断・レビューは高コストモデル側に置く) に従う例外であり、同 rule のデフォルト sonnet 委譲を上書きする。

## 書く側 (実装中)

### `/simplify` (構造改善)

実装初手 (Red 直前 / 編集する箇所を開いた瞬間) で「触りにくい・読みにくい・無関係な責務と絡んでいる」と感じたら、その瞬間に `/simplify` を回す。

**回す条件**: working tree が clean ([[tidy-first]] の構造/振る舞いコミット分離が機械的に保たれる)。

**コミット先の判断 (範囲の独立性基準)**:
- simplify 対象が **feature の差分と物理的に重なる** ファイル中心 → 同ブランチで構造変更コミットを先頭に積む
- 共有モジュール / 公開 API / ディレクトリ移動など **feature 差分と重ならない範囲** → 別 PR に切り出すかをユーザーに確認する (cherry-pick で分離)

**気づきが遅れた場合 (Case 2)**: 実装が進んでから「先に simplify しておけばよかった」と気づいた場合は、その時点で `/simplify` を回し、**実装コミットの後ろ** に構造変更コミットを積む。tidy-first 順序は崩れるが、commit message で「構造変更」と明示すれば判別性は維持される。順序逆転は「気づきが遅れた」メタ情報として残す ([[role-separation]] の retrospective-codify 対象)。

### `/code-review xhigh --fix` (バグ修正)

コミット前に `/code-review xhigh --fix` を回す。修正の自動適用込み。

**回す条件**: working tree が clean。`/simplify` を先に回した場合は構造変更コミットを積んだ後で。

## 書く側 (PR 提出前)

draft PR / ローカル merge の **前** に `/review` を 1 回回す。これがブランチ唯一の品質ゲート。**修正の自動適用はしない** (採否はユーザー、[[role-separation]])。

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload などに触れたら、`/review` と別に `/security-review` を回す (起動はユーザー承認後)。

## 他人 PR

自分にレビュー依頼 / アサインされている PR から対象を選定 → トリアージ → **投稿予定コメント一覧をユーザーに提示し承認後**、GitHub インラインコメントとして投稿 ([[github-writing]] の規約に従う)。投稿の締めはユーザー。専用 skill は退役済みで、手順はこの節が source of truth。
