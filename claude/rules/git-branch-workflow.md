# Git ブランチワークフロー

実装タスクは master or main から切ったフィーチャーブランチで作業する。

## 手順

`git com` は 「デフォルトブランチ (master/main) に switch する」エイリアス。`~/.gitconfig` で定義されている。

```bash
# 開始: デフォルトブランチを最新化してブランチを切る
git com && git pull
git checkout -b <branch-name>
```

## ~/.gitconfig

ユーザーのカスタム Git エイリアス (`git f`, `git wb`, `git com`, `git delete-merged-branches` 等) を読み込む。

@~/.gitconfig