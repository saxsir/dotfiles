# レビューサイクル

書く側のレビューは 2 トラック。実装中は構造改善を回し、PR 提出前にバグ検出のゲートを 1 回置く。コミット境界では回さない ([[commit-discipline]] の可否判断だけで通す、速度優先)。

書く側のレビュー (`/simplify` / `/review` / `/security-review`) を subagent に降ろすときは、その時点で使える最良のモデルを指定する (特定のモデル名で固定しない)。Sonnet には降ろさない。[[delegation]] のデフォルト (機械的作業は sonnet) に対する例外で、判断・レビューは高コストモデル側に置くという同 rule の Why に従った結果。

## 実装中: `/simplify`

編集する箇所を開いて「触りにくい・読みにくい・無関係な責務と絡んでいる」と感じたら、その場で回すのが理想。working tree が clean なときに回すと [[tidy-first]] の構造/振る舞いの分離が自然に保たれる。

構造変更が feature の差分と物理的に重なる範囲なら、同じブランチで構造変更コミットを先頭に積む。共有モジュール・公開 API・ディレクトリ移動など feature の差分と重ならない範囲なら、別 PR に切り出すかをユーザーに確認する (cherry-pick で分離できる)。

気づくのが遅れて実装コミットの後ろに積むことになっても、commit message で構造変更と分かるなら実害は小さい。順序が逆転したこと自体は retrospective-codify の材料として残す。

## PR 提出前: `/review` → `/crit`

draft PR を作る前にこの順で回す。`/review` がブランチ唯一の品質ゲートで、修正の自動適用はしない (採否はユーザー、[[role-separation]])。`/crit` はユーザーが diff を対話レビューする場なので、終わるまで `gh pr create --draft` に進まない。plan のレビューは ExitPlanMode hook の `crit plan-hook` が自動発火するので、ここで扱うのは diff だけ。

`/review` の findings は terminal にしか残らない。`crit comment` で各 finding を対象の `<path>:<line>` にインラインコメントとして流し込んでから `/crit` を開くと、ユーザーの指摘と同じ画面で採否を捌ける。

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload あたりに触れていたら、`/review` とは別に `/security-review` も回したい (起動はユーザー承認後)。

## 他人の PR

自分にレビュー依頼 / アサインされている PR から対象を選び、トリアージしてから、投稿予定のコメント一覧をユーザーに提示して承認を得る。承認後に GitHub のインラインコメントとして投稿する ([[github-writing]] の規約に従う)。投稿の締めはユーザー。専用 skill は退役済みで、この節が source of truth。
