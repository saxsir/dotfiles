#!/bin/bash
# aws-vault / avt の実行を readonly profile (-readonly サフィックス) に限定する PreToolUse フック
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# aws-vault / avt に言及がなければスキップ
echo "$CMD" | grep -qiE 'aws-vault|(^|[^a-zA-Z0-9_-])avt([^a-zA-Z0-9_-]|$)' || exit 0

# keychain を変更するサブコマンドは無条件ブロック
if echo "$CMD" | grep -qiE 'aws-vault[[:space:]]+(add|remove|rm|rotate|clear)([[:space:]]|$)'; then
  echo "Blocked: aws-vault の credential 管理 (add/remove/rotate/clear) は Claude から実行しない。必要ならユーザーが '! <command>' で手動実行する: $CMD" >&2
  exit 2
fi

# fail-closed: aws-vault / avt の出現数と、readonly profile をリテラルで確認できる
# 呼び出しの数を突き合わせ、1 つでも確認できない呼び出しがあればブロックする。
# 変数展開・コマンド置換・値が分離したフラグ (--duration 1h) は profile 名を静的に
# 確定できないため許可数に入らない (フラグは --opt=value 形式で書く)。
total=$(echo "$CMD" | grep -oiE 'aws-vault|(^|[^a-zA-Z0-9_-])avt([^a-zA-Z0-9_-]|$)' | wc -l)
allowed_aws_vault=$(echo "$CMD" | grep -oE "(^|[^A-Za-z0-9_.-])aws-vault[[:space:]]+(exec|login|export)[[:space:]]+(--?[A-Za-z0-9-]+(=[^[:space:]]+)?[[:space:]]+)*[\"']?[A-Za-z0-9_.-]+-readonly[\"']?([[:space:]]|\$)" | wc -l)
allowed_avt=$(echo "$CMD" | grep -oE "(^|[^A-Za-z0-9_-])avt[[:space:]]+[\"']?[A-Za-z0-9_.-]+-readonly[\"']?([[:space:]]|\$)" | wc -l)

if [ "$((allowed_aws_vault + allowed_avt))" -lt "$((total))" ]; then
  echo "Blocked: aws-vault / avt は '-readonly' で終わる profile 名 (リテラル) でのみ実行できる: $CMD" >&2
  echo "対処: profile を '<name>-readonly' に書き換える。フラグは '--opt=value' 形式で profile の前に置く。書き込みが必要な操作はユーザーが '! <command>' で手動実行する" >&2
  exit 2
fi

exit 0
