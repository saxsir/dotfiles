# 過程と結果の分離

ユーザーが「何を作るか・採否・対外的な締め・失敗時の方針」を持ち、Claude は「探索・実装・検証・リファクタリング」の過程の品質を持つ。役割を混ぜない。

## 不可逆操作はユーザーに委ねる

ユーザーの明示承認なしに実行しない:

- `gh pr ready` (絶対実行しない)
- `git push --force` / `git reset --hard` (共有 ref)
- 本番反映、外部サービス送信
- `rm -rf` 等の不可逆な削除

承認不要 (通常運用の範囲): 通常の `git push`、`gh pr create --draft`。

## 外部認証 CLI の書き込みはユーザーに委ねる

外部サービスの認証情報を使う CLI (`aws`, `terraform`, `kaggle` 等) のうち、状態を変更するコマンド (create / update / delete / submit / apply 等) はコマンド本文を提示してユーザーに実行を依頼する。read-only (describe / list / get / logs 等) は Claude が直接実行してよい。

Why: 認証済み CLI での書き込みは外部アカウントへの操作そのものであり、その採否・対外影響はユーザーの領分。

## 学びはファイルに固定する

「最初に知っていれば遠回りしなかった」知見は `retrospective-codify` で rule / skill / CLAUDE.md に残す。
