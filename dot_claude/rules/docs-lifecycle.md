# 仕様と経緯の置き場 (Docs Lifecycle)

仕様とコードは最新のものだけを保ち、同期させる。経緯・紆余曲折は commit / PR / issue に落とし、決定に昇格したものだけを `docs/adr/` に残す。責務分担 (Code=How / Test=What / Commit=Why / Comment=Why-not) は [[commit-discipline]] が正。

## 仕様の正は 1 箇所

正は `CONTEXT.md` (用語集) と最新の spec 1 本。更新はファイルを足すのではなく既存を書き換えて行う。

skill が吐く日付付きの計画・設計ファイルは下書きであって恒久ドキュメントではない。`docs/` に積まず、merge までに正の spec / CONTEXT.md へ反映して消すか、`.scratch/` のような使い捨て領域に置く。

## ADR は decision record であって journal ではない

`docs/adr/` に足すのは、可逆性が低く、文脈なしで見ると驚き、本当のトレードオフの結果である決定 (`domain-modeling` skill の 3 条件)。

試して捨てた案・方針転換・行き詰まりの既定の置き場は commit log / PR description / issue の側で ([[implementation-notes]]、wayfinder の ticket)、ADR はそこからの昇格先。
