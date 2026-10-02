# レビューサイクル

書く側のレビューは dude の完了ゲート (`implement-work` の Verify → `simplify-code` → `review-code`) が正本。ラウンドの進め方、直す指摘の範囲、止める条件は dude に従う。この rule が持つのは、dude と食い違う箇所でこの環境が採るほうと、dude に無いゲートだけ。完了ゲートはコミット境界では回さない ([[commit-discipline]] の可否判断だけで通す、速度優先)。`implement-work` の実行方法が自分の手順として持つタスク単位のレビューは、その手順に従う。

ゲートを回すのは、ユーザーと対話しているメインのセッションだけ。subagent として起動されたセッションは、依頼された作業を検証して報告するところまでを担い、レビューや判定用の subagent は起こさない。rules は subagent にも読み込まれるので、ここで限定しないと worker が自分でゲートを発火して孫 subagent を生む ([[delegation]])。

完了ゲートの reviewer と判定役のモデルは、その時点で使える最良のものを指定する (特定のモデル名で固定しない)。Sonnet には降ろさない ([[delegation]] の検出系 worker の扱い)。

## 判定役は 1 ラウンドに 1 体

dude は指摘ごとに判定 worker を 1 体起こすが、この環境ではラウンドごとに 1 体だけ立て、そのラウンドの findings をまとめて渡す。最良 tier の subagent は起動のたびに初回 context の固定費が乗り、指摘の数だけ起こすとゲートの費用がそれに比例して増えるためだ。`pr-to-ready` が外部レビューの指摘を判定するときも同じにする。

それ以外は dude どおり。採否をメインのセッションで判定せず、メインは判定を覆さない。判定役に渡すのは findings・diff の範囲・要件・過去ラウンドの記録で、実装側の議論は渡さない。

## `/security-review` を並行で回す条件

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload あたりに触れていたら、`review-code` と並行で `/security-review` も subagent で回し、その findings も同じラウンドの判定役に渡す。該当するかは Claude が diff から判定する。2 周目以降は、`/security-review` の subagent にも過去ラウンドの記録 (直した指摘と、却下した指摘とその理由) を渡す。

## 構造変更は PR を分ける

`simplify-code` が整えるのは、その PR が足した diff。既存コードの構造変更 (refactor) が要ると判断したら、先に refactor PR を作り、feature はその上に積む (refactor branch から feature branch を切るか、merge を待つ)。同じ PR に混ぜると、レビュワーが振る舞いの差分を構造の差分から選り分けることになる。

気づくのが遅れて feature branch に構造変更コミットが混ざったときは、cherry-pick で refactor PR に切り出す。分離できないほど絡んでいるときだけ同じ PR に残し、commit message で構造変更と分かるようにする ([[tidy-first]])。順序が逆転したこと自体は retrospective-codify の材料として残す。

## `/crit`: draft PR の後、`pr-to-ready` の前

`implement-work` が draft PR を作ったら、ゲートの結果 (ラウンド数・直した指摘・却下した指摘と理由・Minor・未解決の指摘) を報告して止まる。`/crit` はその後にユーザーが diff を対話レビューする場で、終わるまで `pr-to-ready` に進まない。`pr-to-ready` は外部の reviewer を呼び、スレッドへの返信まで進む flow なので、ユーザーが diff を見る前に始めない。

ゲートが残した指摘 (Minor・却下・未解決) は terminal にしか残らない。`crit comment` で各指摘を対象の `<path>:<line>` にインラインコメントとして流し込んでから `/crit` を開くと、ユーザーの指摘と同じ画面で採否を捌ける。

plan のレビューは ExitPlanMode hook の `crit plan-hook` が自動発火するので、ここで扱うのは diff だけ。

## 他人の PR

自分にレビュー依頼 / アサインされている PR から対象を選び、トリアージしてから、投稿予定のコメント一覧をユーザーに提示して承認を得る。承認後に GitHub のインラインコメントとして投稿する (`github-writing` skill の規約に従う)。投稿の締めはユーザー。この節が source of truth。
