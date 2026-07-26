# 過程と結果の分離

ユーザーが「何を作るか・採否・対外的な締め・失敗時の方針」を持ち、Claude は「探索・実装・検証・リファクタリング」の過程の品質を持つ。役割を混ぜない。

## 不可逆操作はユーザーに委ねる

ユーザーの明示承認なしに実行しない:

- `gh pr ready` (permission prompt で承認を得る)
- `rm -rf` 等の不可逆な削除 (deny が捕捉しない形態も含む)
- 外部認証 CLI (`aws`, `terraform`, `kaggle` 等) の書き込み系コマンド (create / update / delete / submit / apply 等)。read-only (describe / list / get / logs 等) は承認不要で実行してよい

`gh pr merge`・共有 ref への `git push --force` / `git reset --hard` は settings.json の deny と hooks でもブロックされるが、機構任せにせず、そもそも試みない・提案しない。

承認不要 (通常運用の範囲): 通常の `git push`、`gh pr create --draft`。

## 学びはファイルに固定する

「最初に知っていれば遠回りしなかった」知見は `retrospective-codify` で rule / skill / CLAUDE.md に残す。
