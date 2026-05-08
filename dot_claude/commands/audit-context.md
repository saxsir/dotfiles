---
allowed-tools: Bash(wc *), Bash(cat *), Bash(jq *)
description: グローバル CLAUDE.md / rules / ローカル MCP のサイズを棚卸しレポートする。たまに思い出して呼ぶ。
---

以下の集計結果を使って、グローバル Claude 設定の棚卸しレポートを作成してください。
**判断や評価はしないこと。数字と事実だけを出力すること。**

## ファイルサイズ

行数:
!`wc -l ~/.claude/CLAUDE.md ~/.claude/rules/*.md`

文字数（推定トークン = 文字数 ÷ 3）:
!`wc -m ~/.claude/CLAUDE.md ~/.claude/rules/*.md`

## ローカル MCP

`~/.claude.json` の mcpServers:
!`jq -r '.mcpServers | keys[]' ~/.claude.json 2>/dev/null || echo "(なし)"`

`~/.claude/plugins/installed_plugins.json` のプラグイン:
!`jq -r '.installed[]?.name // empty' ~/.claude/plugins/installed_plugins.json 2>/dev/null || echo "(なし)"`

---

## レポート形式

以下の 2 セクションのマークダウン表を出力してください:

**セクション1: CLAUDE.md / rules サイズ**

| File | Lines | ~Tokens |
|------|-------|---------|
| ~/.claude/CLAUDE.md | X | Y |
| ~/.claude/rules/xxx.md | X | Y |
| **TOTAL** | **合計行数** | **合計トークン** |

（推定トークン = 文字数 ÷ 3。日本語多めのため保守的な推定）

**セクション2: ローカル MCP**

有効化されているローカル MCP サーバーの一覧のみ（箇条書き）。

末尾に 1 行注記:
> claude.ai web 連携 MCP（Slack/Drive 等）はローカル設定から見えないため列挙していません。要不要は claude.ai で確認してください。
