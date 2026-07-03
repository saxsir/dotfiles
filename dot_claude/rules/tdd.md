# TDD

Kent Beck / t-wada の実践に従う。

- Red → Green → Refactor を厳密に守る。
- 縦の tracer-bullet スライス: 全層を貫く薄い一本を end-to-end で通し、increment ごとに太らせる。
- テストは public interface に書く (実装詳細・private に結合しない)。
- リファクタは Green でのみ、1 度に 1 つ、各ステップでテスト再実行。
