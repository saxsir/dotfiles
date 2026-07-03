# Implementation Notes

実装中に判断したことは commit message と PR description に残す。

## 何を書くか

依頼から逸脱・解釈した点を残す (該当なしは省略可):

- **Design decisions**: 自分で決めざるを得なかった選択
- **Deviations**: 依頼から意図的に外れた箇所と理由
- **Tradeoffs**: 採用した案を選んだ理由
- **Open questions**: ユーザーに確認・再検討してほしい事項

## どこに書くか

- **commit に閉じる判断 (Design decisions / Tradeoffs)**: 当該 commit message の本文に書く ([[commit-discipline]] の "Commit log is Why")。
- **PR 横断の判断 / 採否を求める事項 (Deviations / Open questions)**: PR description に書く。[[github-workflow]] のテンプレ (What / Why) に節を追加する形で載せる。
- **Why-not がコード読解上必要なら**: コード内コメント ([[commit-discipline]] の "Comment is Why-not")。

## 完了報告

チャット末尾に該当カテゴリの判断があれば短く列挙する (commit / PR との重複可、「目を通して」用)。
