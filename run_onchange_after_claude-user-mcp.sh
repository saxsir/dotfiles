#!/usr/bin/env bash
# どのリポジトリで起動したセッションでも使いたい MCP を、Claude Code の user scope に登録する。
# 登録先は ~/.claude.json (CLAUDE_CONFIG_DIR 未設定) と ~/.claude-vanilla/.claude.json の両方。
# ~/.claude.json は Claude Code の状態ファイルなので chezmoi で丸ごと管理せず、claude mcp コマンドで書き込む。
# chezmoi はこのスクリプトの中身が変わったときだけ再実行する (run_onchange_)。
set -uo pipefail

claude_bin="$(command -v claude || true)"
if [[ -z "${claude_bin}" && -x "${HOME}/.local/bin/claude" ]]; then
  claude_bin="${HOME}/.local/bin/claude"
fi
if [[ -z "${claude_bin}" ]]; then
  echo "claude-user-mcp: claude が見つからないので MCP の登録を飛ばす" >&2
  exit 0
fi

splunk_json="$(printf '{"type":"stdio","command":"%s/.local/bin/splunk-mcp","args":[]}' "${HOME}")"
datadog_json='{"type":"http","url":"https://mcp.datadoghq.com/v1/mcp?toolsets=core,error-tracking"}'

register() {
  local config_dir="$1" name="$2" json="$3"
  local -a env_args=(-u CLAUDE_CONFIG_DIR)
  if [[ -n "${config_dir}" ]]; then
    env_args=("CLAUDE_CONFIG_DIR=${config_dir}")
  fi
  # add-json は同名があると失敗するので先に消す
  env "${env_args[@]}" "${claude_bin}" mcp remove -s user "${name}" >/dev/null 2>&1 || true
  if ! env "${env_args[@]}" "${claude_bin}" mcp add-json -s user "${name}" "${json}" >/dev/null; then
    echo "claude-user-mcp: ${name} を ${config_dir:-~/.claude} に登録できなかった" >&2
  fi
}

for config_dir in "" "${HOME}/.claude-vanilla"; do
  if [[ -n "${config_dir}" && ! -d "${config_dir}" ]]; then
    continue
  fi
  register "${config_dir}" splunk-mcp-server "${splunk_json}"
  register "${config_dir}" datadog "${datadog_json}"
done
