# 仕様と経緯の置き場 (Docs Lifecycle)

仕様とコードは最新のものだけを保ち、同期させる。経緯・紆余曲折は commit / PR / issue に落とし、決定に昇格したものだけを `docs/adr/` に残す。責務分担 (Code=How / Test=What / Commit=Why / Comment=Why-not) は [[commit-discipline]] が正。

## 仕様の正は 1 箇所

- 正は `CONTEXT.md` (用語集) + 最新の spec 1 本。更新はファイル追加ではなく既存の書き換えで行う。
- skill が生成する日付付き計画・設計ファイル (`docs/superpowers/plans/`, `docs/superpowers/specs/` 等) は下書き。恒久ドキュメントとして `docs/` に積まず、merge までに正の spec / CONTEXT.md へ反映して削除するか、`.scratch/` 等の使い捨て領域に置く。

## ADR は decision record であって journal ではない

- `docs/adr/` に時系列連番で追加するのは、`domain-modeling` skill の 3 条件 (可逆性が低い / 文脈なしで見ると驚く / 本当のトレードオフの結果) を全て満たす決定のみ。
- 紆余曲折 (試して捨てた案・方針転換・行き詰まり) の既定の置き場は commit log / PR description / issue ([[implementation-notes]]、wayfinder の ticket)。ADR はそこからの昇格先であり、既定の置き場ではない。
