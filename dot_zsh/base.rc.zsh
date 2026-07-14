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
# cmux claude-teams は split panel の挙動が不安定なため一旦無効化 (2026-07-14)。
# 復帰するには下のブロックのコメントを外し、素の alias 定義を消す。
#
# cmux 内では `claude` を `cmux claude-teams` に差し替え、sub-agent を cmux split で可視化する。
# cmux 外では従来通り $HOME/.local/bin/claude を直接呼ぶ。
#
# cmux の shell integration が first prompt の precmd で `claude` を unalias + function 化
# するため、素の alias は必ず消される。cmux の precmd より後ろで alias を張り直す one-shot
# precmd を仕込む (cmux 側は .zshenv で登録、こちらは .zshrc から登録なので実行順が後)。
# alias 経由で `cmux claude-teams` を叩くと cmux が PATH shim を経由するため、Claude Code
# Integration の wrapper (session tracking / notification hook) も teams モードと共存する。
# if [[ -n "${CMUX_SOCKET_PATH:-}" ]] && command -v cmux > /dev/null 2>&1; then
#   autoload -Uz add-zsh-hook
#   _dotfiles_reinstall_claude_teams_alias() {
#     unset -f claude 2> /dev/null
#     unalias claude 2> /dev/null
#     alias claude='cmux claude-teams'
#     add-zsh-hook -d precmd _dotfiles_reinstall_claude_teams_alias
#   }
#   add-zsh-hook precmd _dotfiles_reinstall_claude_teams_alias
# else
alias claude="$HOME/.local/bin/claude"
# fi
alias claude-vm="limactl shell claude-dev -- bash -c 'claude --dangerously-skip-permissions'"
