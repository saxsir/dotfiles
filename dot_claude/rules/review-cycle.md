# レビューサイクル

書く側のレビューは dude の完了ゲート (`implement-work` の Verify → `simplify-code` → `review-code`) に従う。この rule は dude と食い違う箇所でこの環境が採るほうと、dude に無いゲートだけを持つ。完了ゲートはコミット境界では回さない (速度優先)。`implement-work` の実行方法が持つタスク単位のレビューは、その手順に従う。

ゲートを回すのは、ユーザーと対話しているメインのセッションだけ。subagent として起動されたセッションは、依頼された作業の検証と報告までで止め、レビューや判定の subagent を起こさない。

dude の marked worker は、skill が指定する tier の agent 定義で起こす。`high` は `subagent_type: dude:high-tier`、`highest` は `dude:highest-tier`。型も `model` も指定しないと sonnet で動く。

## 判定役は 1 ラウンドに 1 体

dude の `vet-code`・`pr-to-ready`・`simplify-code` は指摘 (提案) ごとに判定 worker を起こすが、この環境ではラウンドごとに 1 体だけ立て、そのラウンドの findings をまとめて渡す。marked worker は起動のたびに初回 context の固定費が乗るためだ。

## `/security-review` を並行で回す条件

diff が auth / 入力検証 / secret / 外部 API / SQL / template / SSRF / file upload に触れていたら (該当は Claude が diff から判定する)、`review-code` と並行で `/security-review` を `dude:high-tier` の subagent で回し、findings を同じラウンドの判定役に渡す。2 周目以降は、直した指摘と、却下した指摘とその理由の記録も渡す。

## 構造変更は PR を分ける

既存コードの refactor が要ると判断したら、先に refactor PR を作り、feature はその上に積む (`simplify-code` が整えるのはその PR が足した diff だけ)。feature branch に構造変更コミットが混ざったら、cherry-pick で refactor PR に切り出す。分離できないほど絡んでいるときだけ同じ PR に残し、commit message で構造変更と分かるようにする ([[tidy-first]])。順序が逆転したこと自体は retrospective-codify の材料として残す。

## `/crit`: draft PR の後、`pr-to-ready` の前

`implement-work` が draft PR を作ったら、ゲートの結果 (ラウンド数・直した指摘・却下した指摘と理由・Minor・未解決の指摘) を報告して止まる。ユーザーが `/crit` で diff を対話レビューし終えるまで、`pr-to-ready` (外部の reviewer を呼び、返信まで進む flow) に進まない。

ゲートが残した指摘 (Minor・却下・未解決) は terminal にしか残らない。`crit comment` で各指摘を `<path>:<line>` のインラインコメントとして流し込んでおくと、ユーザーが `/crit` の同じ画面で採否を捌ける。

## 他人の PR

自分にレビュー依頼 / アサインされている PR から対象を選んでトリアージし、dude の `review-pr` に渡す。下書きを見せる前に、本文とインラインコメントを `github-writing` skill の規約 (ラベル、参照書式) に揃える。
