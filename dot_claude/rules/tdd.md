# TDD (Test-Driven Development)

Kent Beck / 和田卓人 (t-wada) の実践に従う。

- `Red → Green → Refactor` を厳密に守る。
- 縦の tracer-bullet スライスで進める（全層を貫く薄い一本を end-to-end で通し、increment ごとに太らせる）。
- テストは public interface に対して書く（実装詳細・private に結合させない）。
- リファクタリングは Green でのみ、1 度に 1 つ行い、各ステップでテストを再実行する。
