# シェル素の設定 (オプション / alias / 補完)

# ============================================================
# シェルオプション
# ============================================================
setopt hist_ignore_all_dups

# ============================================================
# エイリアス
# ============================================================
alias vi='vi -u NONE'
alias vim='nvim'
alias -g G='| grep'
alias -g L='| lv'
alias -g V='| vim -'
alias -g C='| pbcopy'
alias matrix="cmatrix -s -u 6"
alias gce='git commit --allow-empty'
# cmux 内では `claude` を `cmux claude-teams` に差し替え、sub-agent を cmux split で可視化する。
# cmux 外では従来通り $HOME/.local/bin/claude を直接呼ぶ。
if [[ -n "${CMUX_SOCKET_PATH:-}" ]] && command -v cmux > /dev/null 2>&1; then
  alias claude='cmux claude-teams'
else
  alias claude="$HOME/.local/bin/claude"
fi
alias claude-vm="limactl shell claude-dev -- bash -c 'claude --dangerously-skip-permissions'"
