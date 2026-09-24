#!/bin/bash
# force / 履歴破壊的な git push を止める PreToolUse フック。
# 背景: git rebase / commit --amend による未 push 履歴の書き換えはローカルに
# 閉じていれば reflog で復元できるため許容するが、書き換えた履歴を共有 ref へ
# push すると他者の作業を壊す。ここが最終ゲートになる。
#
# 検出対象は「force / 履歴破壊を伴う push」で、通常の push は素通りする。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# git push らしき呼び出しを表す正規表現。"git" の直後から push サブコマンドまでの
# 間に挟まる global option (`-C <dir>`, `-c <k>=<v>`, `--no-pager`,
# `--git-dir=<path>` 等、任意の `-` 始まりトークン + 任意の値) を許容する。
# 値はクオート無し (空白を含まない 1 トークン) とダブル/シングルクオート文字列
# (`-C "a b"` のように空白を含むもの) の両方を受け付ける。
# push サブコマンド自身の引数 (`-m "push"` 等) まで global option として食わない
# ように、option 列は "git" に直接連続する位置でのみマッチする。
PUSH_RE="git([[:space:]]+-[^[:space:]]+([[:space:]]+(\"[^\"]*\"|'[^']*'|[^[:space:]-][^[:space:]]*))?)*[[:space:]]+push([[:space:]]|\$)"

# コマンド全体に git push の兆候が無ければ即スキップ。
echo "${CMD}" | grep -qE "${PUSH_RE}" || exit 0

# `cd x &&` や `;`, `|`, 単独の `&` (job control) で連結されたコマンドの中に
# 潜む push も見るため、セグメントごとに判定する。単独の `&` は `2>&1` や
# `command 2>&1` のような fd 複製 (直前が `<`/`>`/`&`) と区別し、それ以外の
# 位置に出る `&` だけを区切りとして扱う。
# Why-not: シェルの完全な構文解析はしていないので、引用符内の &&/;/|/& を
# 誤って分割する可能性がある。同様に、`-o "merge_request.title=fix -f flag"`
# のような引用符付き引数の中に force/delete 用のフラグ文字列が偶然含まれると
# 危険フラグ判定が誤検出する。この hook の脅威モデルは通常運用での force push
# の混入防止であり、難読化・injection や引用符内の偶然の一致は対象外
# (block-aws-vault-write.sh と同方針)。
segments=$(echo "${CMD}" | sed -E -e 's/&&|;|\|/\n/g' -e 's/([^<>&])&([^&]|$)/\1\n\2/g')

while IFS= read -r seg; do
  echo "${seg}" | grep -qE "${PUSH_RE}" || continue

  danger=0

  # -f / --force / --force-with-lease[=...] / --force-if-includes / --mirror / --delete / -d
  if echo "${seg}" | grep -qE -- '(^|[[:space:]])(-f|--force|--force-with-lease(=[^[:space:]]*)?|--force-if-includes|--mirror|--delete|-d)([[:space:]]|=|$)'; then
    danger=1
  fi

  # 結合された短縮オプション (-uf, -fu, -ud 等) に紛れた -f / -d
  if echo "${seg}" | grep -qE '(^|[[:space:]])-[a-zA-Z]*[fd][a-zA-Z]*([[:space:]]|$)'; then
    danger=1
  fi

  # refspec が + で始まる (force push の別形)
  if echo "${seg}" | grep -qE '(^|[[:space:]])\+[^[:space:]]+'; then
    danger=1
  fi

  # refspec が : で始まる (リモート ref 削除)
  if echo "${seg}" | grep -qE '(^|[[:space:]]):[^[:space:]]+'; then
    danger=1
  fi

  if [ "${danger}" = "1" ]; then
    echo "Blocked: force / destructive push (force, force-with-lease, +refspec, --mirror, delete) is not allowed: ${seg}" >&2
    echo "必要なら '! git push ...' でユーザー自身が手動実行する" >&2
    exit 2
  fi
done <<< "${segments}"

exit 0
