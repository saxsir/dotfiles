# レビューサイクル

書く側のレビューは 2 トラック。実装中は構造改善を回し、PR 提出前にバグ検出のゲートを 1 回置く。コミット境界では回さない ([[commit-discipline]] の可否判断だけで通す、速度優先)。

書く側のレビュー (`/simplify` / `/review` / `/security-review`) は必ず subagent (context を共有しない別セッション) で回す。呼び出したセッションのバイアス (実装意図・直前の議論・自分の書いたコードへの愛着) を持ち込ませず、diff だけを見て判断させるため。モデルはその時点で使える最良のものを指定する (特定のモデル名で固定しない)。Sonnet には降ろさない。[[delegation]] のデフォルト (機械的作業は sonnet) に対する例外で、判断・レビューは高コストモデル側に置くという同 rule の Why に従った結果。

## 実装中: `/simplify`

編集する箇所を開いて「触りにくい・読みにくい・無関係な責務と絡んでいる」と感じたら、その場で回すのが理想。working tree が clean なときに回すと [[tidy-first]] の構造/振る舞いの分離が自然に保たれる。

構造変更 (refactor) と振る舞い変更は PR を分ける。実装中に構造変更したほうがよいと判断したら、先に refactor PR を作り、feature はその上に積む (refactor branch から feature branch を切るか、merge を待つ)。同じ PR に混ぜると、レビュワーが振る舞いの差分を構造の差分から選り分けることになる。

気づくのが遅れて feature branch に構造変更コミットが混ざったときは、cherry-pick で refactor PR に切り出す。分離できないほど絡んでいるときだけ同じ PR に残し、commit message で構造変更と分かるようにする ([[tidy-first]])。順序が逆転したこと自体は retrospective-codify の材料として残す。

## PR 提出前: `/review` → `/crit`

実装が一段落したら (task 完了報告を出す前・draft PR を作る前) Claude が subagent で `/review` を自動発火する。ユーザーの承認は要らない — findings は表示のみで採否はユーザー ([[role-separation]] に反しない)。修正の自動適用もしない。`/crit` はユーザーが diff を対話レビューする場なので、終わるまで `gh pr create --draft` に進まない。plan のレビューは ExitPlanMode hook の `crit plan-hook` が自動発火するので、ここで扱うのは diff だけ。

`/review` の findings は terminal にしか残らない。`crit comment` で各 finding を対象の `<path>:<line>` にインラインコメントとして流し込んでから `/crit` を開くと、ユーザーの指摘と同じ画面で採否を捌ける。

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload あたりに触れていたら、`/review` と並行で `/security-review` も subagent で自動発火する。該当するかは Claude が diff から判定する。

## 他人の PR

自分にレビュー依頼 / アサインされている PR から対象を選び、トリアージしてから、投稿予定のコメント一覧をユーザーに提示して承認を得る。承認後に GitHub のインラインコメントとして投稿する ([[github-writing]] の規約に従う)。投稿の締めはユーザー。専用 skill は退役済みで、この節が source of truth。
