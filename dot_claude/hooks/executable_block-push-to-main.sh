#!/bin/bash
# master/main ブランチへの push をブロックする PreToolUse フック
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# PUSH_RE と区切りの sed は block-force-push.sh と揃える。片方だけ直すと 2 つの hook で
# push とみなす範囲がずれる。
PUSH_RE="git([[:space:]]+-[^[:space:]]+([[:space:]]+(\"[^\"]*\"|'[^']*'|[^[:space:]-][^[:space:]]*))?)*[[:space:]]+push([[:space:]]|\$)"

echo "${CMD}" | grep -qE "${PUSH_RE}" || exit 0

segments=$(echo "${CMD}" | sed -E -e 's/&&|;|\|/\n/g' -e 's/([^<>&])&([^&]|$)/\1\n\2/g')

is_protected_ref() {
  case "$1" in
    main|master|refs/heads/main|refs/heads/master) return 0 ;;
  esac
  return 1
}

while IFS= read -r seg; do
  echo "${seg}" | grep -qE "${PUSH_RE}" || continue

  args=$(echo "${seg}" | sed -E "s/.*${PUSH_RE}//")
  read -ra tokens <<< "${args}"

  positionals=()
  skip_next=0
  for token in "${tokens[@]}"; do
    if [ "${skip_next}" = "1" ]; then
      skip_next=0
      continue
    fi
    token="${token//\"/}"
    token="${token//\'/}"
    case "${token}" in
      -o|--push-option|--repo|--receive-pack|--exec) skip_next=1 ;;
      -*) ;;
      *[\<\>]) skip_next=1 ;;
      *[\<\>]*) ;;
      *) positionals+=("${token}") ;;
    esac
  done

  if [ "${#positionals[@]}" -ge 2 ]; then
    for refspec in "${positionals[@]:1}"; do
      dest="${refspec#+}"
      dest="${dest##*:}"
      if is_protected_ref "${dest}"; then
        echo "Blocked: push to main/master is not allowed: $CMD" >&2
        exit 2
      fi
    done
  else
    CURRENT=$(git -C "${CWD:-.}" branch --show-current 2>/dev/null)
    if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
      echo "Blocked: currently on $CURRENT — push to main/master is not allowed" >&2
      exit 2
    fi
  fi
done <<< "${segments}"

exit 0
