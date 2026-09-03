#!/bin/bash
# built-in の Explore subagent を model 未指定で呼んだら sonnet を補う PreToolUse フック
# (matcher: Agent。rules/delegation.md の機械的強制)。
# built-in Explore は CLAUDE_CODE_SUBAGENT_MODEL の対象外でメイン会話のモデルを継承する
# (Opus 上限) ため、Fable / Opus のセッションでは探索が高コストで走る。
# user agent で Explore を上書きすると公式の改善に追従できないので、
# 定義は built-in のままにして呼び出し時の model だけを hook で補う。
# 呼び出し側が model を明示していればそのまま通す。Plan は判断側の作業なので触らない。
INPUT=$(cat)
TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""')
MODEL=$(echo "$INPUT" | jq -r '.tool_input.model // ""')

[ "$(echo "$TYPE" | tr '[:upper:]' '[:lower:]')" = "explore" ] || exit 0
[ -z "$MODEL" ] || exit 0

echo "$INPUT" | jq '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    updatedInput: (.tool_input + {model: "sonnet"}),
    additionalContext: "Explore は model 未指定だったため hook が sonnet を補った (rules/delegation.md)"
  }
}'
