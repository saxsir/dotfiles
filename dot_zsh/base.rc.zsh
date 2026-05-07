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
alias claude-vm="limactl shell claude-dev -- bash -c 'claude --dangerously-skip-permissions'"

# ============================================================
# 補完 (zinit のプラグインを活かすため最後に compinit)
# ============================================================
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
