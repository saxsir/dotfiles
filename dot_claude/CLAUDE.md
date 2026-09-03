# Conversation Guidelines

- 指示の不明瞭さは、読み方によって成果物が大きく変わるものだけ質問する (操作の承認は [[role-separation]] が正)。些細な解釈は自分で決めて進め、完了報告に書く ([[implementation-notes]])。
- AI モデル・開発ツールなど数か月で状況が変わる領域の話題は、記憶で答えず先に検索して現状を確かめる。知っている名前でも省かず、ユーザーが書いた表記そのままを 1 回はクエリに含める (部分的に知っていることが、古い答えを自信ありげにする原因)。

# Orchestration

- 高コストモデル (Fable / Opus) で動いているときはオーケストレーターに徹する。着手時に難易度を判定し、資料の読み込み・観点抽出・grep のような単純作業は `model: sonnet` の subagent に降ろす。判定と実行者を 1 行で宣言する。詳細は [[delegation]]。

# Core Principles

## Core practices (always-on)
@rules/writing-style.md
@rules/tidy-first.md
@rules/non-sycophancy.md
@rules/role-separation.md
@rules/delegation.md

## Coding workflow
@rules/commit-discipline.md
@rules/docs-lifecycle.md
@rules/git-branch-workflow.md
@rules/implementation-notes.md
@rules/scope.md

## Specialty (task-specific)
@rules/github-workflow.md
@rules/github-writing.md
@rules/review-cycle.md
@rules/planning-workflow.md
@rules/brain-first.md
@rules/research-report.md

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理 (`~/src/github.com/owner/repo`)

# Tool Preferences

- MCP の配置先: OAuth / クラウド認証で完結するサービスは claude.ai Web 連携 MCP として設定する。localhost 依存または API token 認証が必要なものは `~/.claude.json` に登録する
- 大量・機械的なデータ取得に MCP を使わない (取得内容が全部モデルを通り token 消費が激しい)。CLI / API 直叩きの script に落として Claude の外で実行し、MCP は少数ファイルの探索・形式確認・トリアージまでに使う
- JSON は Python ではなく `jq` で処理する (shell のパイプラインに収まり、中間ファイルも一時スクリプトも要らない)
- 個人プロジェクトの JS/TS ツールチェーンは bun をデフォルトにする (runtime / package manager / test runner)。新規プロジェクトは bun で始める。既存プロジェクトの移行は勝手に始めず提案に留める
- `gh api graphql` はエラー時も exit 0 を返すので、レスポンスの `.errors[]` を必ず確認する (チェックを飛ばすと jq が invalid JSON を受け取って連鎖クラッシュする)
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避けるため)
