# コミット規律

## コミット可否

全部満たすときだけコミット:

1. 全テスト通過
2. lint / 警告解消
3. 単一論理単位
4. 構造変更か振る舞い変更か commit message で判別可

大きく稀でなく、小さく頻繁に。message は日本語 (prefix は `feat:` `fix:` 等英語)。

## ドキュメンテーション責務分担

- **Code is How**: 具体実装
- **Test is What**: 仕様・振る舞い
- **Commit log is Why**: 変更の背景・目的
- **Comment is Why-not**: なぜ他の選択肢でなくこの実装か
