# Implementation Notes

実装中に判断したことは最終的に commit message と PR description に残す。

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

## 作業途中の進捗メモ

PR を作る規模のタスク (feat / fix / リファクタ / rule・skill・CLAUDE.md・dotfiles 設定更新など) では、着手と同時に scratchpad (`<scratchpad>/<slug>.md`) を作り、進捗・判断・気づきを逐次追記する。

質問・調査・既存コード説明のみ / 1-2 行の自明な小修正では不要。

PR 作成時 / 完了時に scratchpad の内容を commit message / PR description に転記する。scratchpad 自体は永続化せず、セッション内の作業領域として使い捨てる (リポジトリにコミットしない)。

## 完了報告

チャット末尾に該当カテゴリの判断があれば短く列挙する (commit / PR との重複可、「目を通して」用)。

Why: 判断の最終的な置き場を「読まれる場所」に絞る。commit log と PR description はレビュー時に必ず通るが、リポ内の作業ノートファイルは読まれず腐る。scratchpad は走り書きの場として残し、最終的な判断だけを PR に集約する。
