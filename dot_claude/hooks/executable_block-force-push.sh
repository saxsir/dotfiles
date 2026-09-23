#!/bin/bash
# force / 履歴破壊的な git push を止める PreToolUse フック。
# 背景: git rebase / commit --amend による未 push 履歴の書き換えはローカルに
# 閉じていれば reflog で復元できるため許容するが、書き換えた履歴を共有 ref へ
# push すると他者の作業を壊す。ここが最終ゲートになる。
#
# 検出対象は「force / 履歴破壊を伴う push」で、通常の push は素通りする。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# git push らしき呼び出しを表す正規表現。`git -C <dir>` / `git -c <k>=<v>` を
# 挟んだ形 (`git -C repo push`, `git -c user.name=x push`) も拾う。
PUSH_RE='git([[:space:]]+(-C[[:space:]]+[^[:space:]]+|-c[[:space:]]+[^[:space:]]+))*[[:space:]]+push([[:space:]]|$)'

# コマンド全体に git push の兆候が無ければ即スキップ。
echo "${CMD}" | grep -qE "${PUSH_RE}" || exit 0

# `cd x &&` や `;` で連結されたコマンドの中に潜む push も見るため、
# &&, ;, | で区切ってセグメントごとに判定する。
# Why-not: シェルの完全な構文解析はしていないので、引用符内の &&/;/| を
# 誤って分割する可能性がある。この hook の脅威モデルは通常運用での force push
# の混入防止であり、難読化・injection は対象外 (block-aws-vault-write.sh と同方針)。
segments=$(echo "${CMD}" | sed -E 's/&&|;|\|/\n/g')

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
