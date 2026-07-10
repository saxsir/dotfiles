# Implementation Notes

実装中に判断したことは commit message と PR description に残す。

## 何をどこに書くか

依頼から逸脱・解釈した点を残す (該当なしは省略可):

- **Design decisions** (自分で決めざるを得なかった選択) / **Tradeoffs** (採用した案を選んだ理由): commit に閉じる判断。当該 commit message の本文に書く。
- **Deviations** (依頼から意図的に外れた箇所と理由) / **Open questions** (確認・再検討してほしい事項): PR 横断の判断。PR description ([[github-workflow]] の What/Why テンプレ) に節を追加して書く。
- Why-not がコード読解上必要なら、コード内コメント ([[commit-discipline]] の責務分担に従う)。

## 完了報告

チャット末尾に該当カテゴリの判断があれば短く列挙する (commit / PR との重複可、「目を通して」用)。
