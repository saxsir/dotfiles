# ドキュメントの鮮度 (Docs Lifecycle)

仕様・設計ドキュメントは実装に合わせて更新し、常に最新のものだけを残す。古い版を別ファイルとして積むと、後から読んだときにどれが現在の仕様か分からなくなり、実装と食い違った記述に引っ張られる。更新はファイルを足すのではなく既存を書き換えて行う。

経緯 (試して捨てた案・方針転換・行き詰まり) はドキュメント側に残さず、commit log / PR description / issue に置く ([[implementation-notes]])。責務分担 (Code=How / Test=What / Commit=Why / Comment=Why-not) は [[commit-discipline]] が正。

ADR を運用するかどうか、どこに何を置くかはプロジェクトによる。プロジェクト側の CONTEXT.md / CLAUDE.md に従う。
