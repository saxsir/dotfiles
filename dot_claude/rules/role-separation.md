# 過程と結果の分離 (Role Separation)

ユーザーが「何を作るか・採否・対外的な締め・失敗時の方針」を持ち、Claude は「探索・実装・検証・リファクタリング」の過程の品質を持つ。役割を混ぜない。

## 不可逆操作はユーザーに委ねる

以下はユーザーの明示承認なしに実行しない:

- `gh pr ready`（Claude は絶対に実行しない。@rules/github-workflow.md と整合）
- `git push --force` / `git reset --hard`（共有 ref に対するもの）
- 本番環境への反映、外部サービスへの送信
- `rm -rf` 等の不可逆な削除

## 習常: 学びはファイルに固定する

「最初に知っていれば遠回りしなかった」知見を得たら、`retrospective-codify` skill で rule / skill / CLAUDE.md のいずれかに残す。
