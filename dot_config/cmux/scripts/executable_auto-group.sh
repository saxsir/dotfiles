#!/usr/bin/env bash
# cmux の workspace を、作業対象の GitHub issue の最上位の親 issue ごとの
# workspace group に振り分ける。親 issue が分からない workspace は
# リポジトリ単位の group に入れる。
#
# 作業対象 (owner/repo#n) の根拠は確実なものだけ使う:
#   1. cmux が紐づけた PR (`cmux sidebar-state` の `pr=` 行の URL)
#   2. title / description 中の `owner/repo#n`、issue / PR の URL、
#      GitHub のページタイトル形式 (`Pull Request #n · owner/repo`)
# PR は closingIssuesReferences の先頭 issue を起点にし、parent を辿る。closes が無ければ
# 本文の `Relates to` 等の行、無ければ本文で最初に出る issue を起点にする。
# 起点に parent があれば root の group、parent が無く sub-issue を持てば
# 起点自身の group、どちらでもなければ repo group (directory の repo root)。
#
# 常駐させず、Claude Code の hook (SessionStart と `gh pr create` の後。
# dot_claude/hooks/executable_cmux-auto-group.sh) から --once で走らせる前提で使う。
# --once は全 workspace を見直すので、hook が走らなかった間の変化も次の実行で追いつく。
#
# Usage:
#   ~/.config/cmux/scripts/auto-group.sh              # reconcile 後、events を監視
#   ~/.config/cmux/scripts/auto-group.sh --once       # reconcile 1 回で終了
#   ~/.config/cmux/scripts/auto-group.sh --once --dry-run
#                                 # 変更せず "<workspace ref>\t<現在 group>\t<目標 group>"
#   LOG=/tmp/cmux-auto-group.log; nohup ~/.config/cmux/scripts/auto-group.sh >>"$LOG" 2>&1 &
#
# Why: group の同一性は名前でなく external-id で判定する。cmux の
# `workspace-group create --external-id` は同じ id の group が残っている間は
# 既存を返す (created=false、--from も --name も無視)。title が変わったら
# rename で追従する。
#
# Why-not: auto-ungroup.sh と同時に動かさない。1 件だけの group を
# auto-ungroup が解散し、この script が作り直すループになる。
#
# どの前提が欠けても何もせず exit 0。
set -uo pipefail

once=0
dry_run=0
for arg in "$@"; do
  case "${arg}" in
    --once) once=1 ;;
    --dry-run) dry_run=1 ;;
  esac
done

for cmd in cmux gh jq git; do
  command -v "${cmd}" >/dev/null 2>&1 || exit 0
done

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/cmux"
cursor_file="${state_dir}/auto-group.seq"
cache_dir="${state_dir}/auto-group-cache"
cache_ttl_min=60
max_parent_depth=5
title_max_chars=30
debounce_sec=1
mkdir -p "${cache_dir}"

log() { printf '[cmux-auto-group] %s %s\n' "$(date -u +%FT%TZ)" "$*" >&2; }

# issue / PR の URL を受け取り、GraphQL の resource を JSON で返す。
# 失敗時は非 0 で、キャッシュしない (gh の一時的な失敗で振り分けを変えないため)。
gh_resource() {
  local url="$1" key cache_file resp
  key=$(printf '%s' "${url}" | tr -c 'A-Za-z0-9' '_')
  # Why: PullRequest に body を足した時点で形が変わった。.v2 で古い cache を読まない。
  cache_file="${cache_dir}/${key}.v2.json"
  if [[ -n "$(find "${cache_file}" -mmin "-${cache_ttl_min}" 2>/dev/null)" ]]; then
    cat "${cache_file}"
    return 0
  fi
  # shellcheck disable=SC2016 # GraphQL の変数で、shell 展開しない
  resp=$(gh api graphql -f url="${url}" -f query='
    query($url: URI!) {
      resource(url: $url) {
        __typename
        ... on PullRequest { body closingIssuesReferences(first: 1) { nodes { url } } }
        ... on Issue { url number title parent { url } subIssues { totalCount } }
      }
    }' 2>/dev/null) || return 1
  # gh api graphql は GraphQL エラーでも exit 0 を返す。
  printf '%s' "${resp}" | jq -e '(.errors // []) | length == 0' >/dev/null 2>&1 ||
    return 1
  resp=$(printf '%s' "${resp}" | jq -c '.data.resource') || return 1
  printf '%s' "${resp}" >"${cache_file}"
  printf '%s' "${resp}"
}

# 文字列から最初の owner/repo#n を見つけ、issue / PR の URL で返す。
# owner/repo#n は issue か PR か区別できないので /issues/ で返す。
extract_ref_url() {
  local text="$1" m
  m=$(printf '%s' "${text}" |
    grep -Eo 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/(issues|pull)/[0-9]+' |
    head -n 1)
  if [[ -n "${m}" ]]; then
    printf '%s' "${m}"
    return 0
  fi
  # 直前が path の一部でない owner/repo#n だけを拾う (a/b/c#1 の b/c#1 を拾わない)。
  m=$(printf '%s' "${text}" |
    grep -Eo '(^|[^A-Za-z0-9_./-])[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+' |
    head -n 1 | grep -Eo '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+$')
  if [[ -n "${m}" ]]; then
    printf 'https://github.com/%s/issues/%s' "${m%%#*}" "${m##*#}"
    return 0
  fi
  # GitHub のタブタイトル: "<title> by <user> · Pull Request #n · owner/repo"
  m=$(printf '%s' "${text}" |
    grep -Eo '(Issue|Pull Request) #[0-9]+ · [A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' |
    head -n 1)
  if [[ -n "${m}" ]]; then
    local num repo kind=issues
    [[ "${m}" == "Pull Request"* ]] && kind=pull
    num=$(printf '%s' "${m}" | sed -E 's/.*#([0-9]+) · .*/\1/')
    repo=$(printf '%s' "${m}" | sed -E 's/.* · //')
    printf 'https://github.com/%s/%s/%s' "${repo}" "${kind}" "${num}"
    return 0
  fi
  return 1
}

# PR 本文から参照 issue の URL 候補を出現順に最大 5 件返す (1 行 1 件)。
# `Relates to` / `Refs` / `Ref` / `Part of` の行の参照を先に、続けて本文全体の参照を並べる。
# owner/repo#n は issue か PR か区別できないので /issues/ で返す。
body_ref_urls() {
  local body="$1" ref_re line
  ref_re='https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/(issues|pull)/[0-9]+|(^|[^A-Za-z0-9_./-])[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+'
  {
    printf '%s\n' "${body}" | grep -Ei '^[[:space:]>*-]*(relates to|refs?|part of)\b' |
      while IFS= read -r line; do printf '%s\n' "${line}" | grep -Eo "${ref_re}"; done
    printf '%s\n' "${body}" | grep -Eo "${ref_re}"
  } | sed -E 's|^[^A-Za-z0-9_.-]?([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#([0-9]+)$|https://github.com/\1/issues/\2|' |
    awk '!seen[$0]++' | head -n 5
}

# workspace の repo root。worktree は main checkout に寄せる。
repo_root_of() {
  local dir="$1" top
  [[ -z "${dir}" ]] && return 1
  dir="${dir%%/.claude/worktrees/*}"
  top=$(git -C "${dir}" rev-parse --show-toplevel 2>/dev/null) || top="${dir}"
  printf '%s' "${top}"
}

# 1 workspace の目標 group を "<external id>\t<group 名>\t<根拠>" で返す。
# 目標なし (group に入れない) は external id を空にする。
# 判定できない (gh 失敗) ときは非 0 を返し、呼び出し側は現状維持にする。
target_of() {
  local ws_json="$1" ref dir pr_url start_url src res typ issue i parent root
  ref=$(printf '%s' "${ws_json}" | jq -r '.ref')
  dir=$(printf '%s' "${ws_json}" | jq -r '.current_directory // empty')

  pr_url=$(cmux sidebar-state --workspace "${ref}" 2>/dev/null |
    sed -n 's/^pr=//p' | grep -Eo 'https?://[^[:space:]]+' | head -n 1) || true
  if [[ -n "${pr_url}" ]]; then
    start_url="${pr_url}"
    src="sidebar pr"
  elif start_url=$(extract_ref_url "$(printf '%s' "${ws_json}" | jq -r '.title // ""')"); then
    src="title"
  elif start_url=$(extract_ref_url "$(printf '%s' "${ws_json}" | jq -r '.description // ""')"); then
    src="description"
  else
    start_url=""
    src=""
  fi

  issue=""
  if [[ -n "${start_url}" ]]; then
    res=$(gh_resource "${start_url}") || return 1
    # Why: `/issues/<n>` の URL で引くと PR でも __typename が Issue になり
    # closingIssuesReferences が取れない (url だけ /pull/ を指す)。PR の URL で引き直す。
    local canonical
    canonical=$(printf '%s' "${res}" | jq -r '.url // empty')
    if [[ "${canonical}" == */pull/* && "${canonical}" != "${start_url}" ]]; then
      start_url="${canonical}"
      res=$(gh_resource "${start_url}") || return 1
    fi
    typ=$(printf '%s' "${res}" | jq -r '.__typename // empty')
    case "${typ}" in
      PullRequest)
        local closing
        closing=$(printf '%s' "${res}" | jq -r '.closingIssuesReferences.nodes[0].url // empty')
        if [[ -n "${closing}" ]]; then
          issue=$(gh_resource "${closing}") || return 1
          src="${src} ${start_url} -> closes ${closing}"
        else
          # closes が無い PR は、本文が参照する最初の issue (PR は飛ばす) で代用する。
          local cand cand_res related=""
          while IFS= read -r cand; do
            [[ -z "${cand}" || "${cand}" == "${start_url}" ]] && continue
            cand_res=$(gh_resource "${cand}") || return 1
            if [[ "$(printf '%s' "${cand_res}" | jq -r '.__typename // empty')" == "Issue" &&
              "$(printf '%s' "${cand_res}" | jq -r '.url // empty')" != */pull/* ]]; then
              related=$(printf '%s' "${cand_res}" | jq -r '.url')
              issue="${cand_res}"
              break
            fi
          done < <(body_ref_urls "$(printf '%s' "${res}" | jq -r '.body // ""')")
          if [[ -n "${related}" ]]; then
            src="${src} ${start_url} -> relates ${related}"
          else
            src="${src} ${start_url} (closes なし)"
          fi
        fi
        ;;
      Issue)
        issue="${res}"
        src="${src} ${start_url}"
        ;;
      *) src="${src} ${start_url} (解決できず)" ;;
    esac
  fi

  root=""
  if [[ -n "${issue}" ]]; then
    parent=$(printf '%s' "${issue}" | jq -r '.parent.url // empty')
    if [[ -n "${parent}" ]]; then
      root="${issue}"
      i=0
      while [[ -n "${parent}" ]] && ((i < max_parent_depth)); do
        root=$(gh_resource "${parent}") || return 1
        src="${src} -> parent ${parent}"
        parent=$(printf '%s' "${root}" | jq -r '.parent.url // empty')
        i=$((i + 1))
      done
    elif [[ "$(printf '%s' "${issue}" | jq -r '.subIssues.totalCount // 0')" -gt 0 ]]; then
      root="${issue}"
      src="${src} (sub-issue を持つ)"
    fi
  fi

  if [[ -n "${root}" ]]; then
    printf '%s' "${root}" | jq -r --argjson n "${title_max_chars}" --arg src "${src}" '
      (if (.title | length) > $n then .title[0:$n] + "…" else .title end) as $t
      | [.url, "#\(.number) \($t)", $src] | @tsv'
    return 0
  fi

  local repo_root
  if repo_root=$(repo_root_of "${dir}"); then
    printf 'repo:%s\t%s\t%s\n' "${repo_root}" "$(basename "${repo_root}")" "${src:-根拠なし} -> repo"
  else
    printf '\t\t%s\n' "${src:-根拠なし} -> directory なし"
  fi
}

groups_json=""
refresh_groups() {
  groups_json=$(cmux workspace group list --json 2>/dev/null) || {
    log "group list failed"
    return 1
  }
}

# ws が属する group を JSON で返す (無ければ空)。
group_of() {
  printf '%s' "${groups_json}" |
    jq -c --arg ws "$1" '.groups[]? | select(.member_workspace_refs | index($ws))' | head -n 1
}

group_by_external_id() {
  printf '%s' "${groups_json}" |
    jq -r --arg id "$1" '.groups[]? | select(.external_id == $id) | .ref' | head -n 1
}

# ws を今の group から外せる状態にする。
# Why: cmux 0.65.2 ではアンカーを `add` すると invalid_state で失敗し、
# `remove` するとアンカー以外のメンバーごと group が解散する。そのため
# 他のメンバーが居れば先にアンカーを譲り、1 人だけなら group を ungroup する。
# Why-not: `delete` は使わない (--close-workspaces を付け間違えると workspace を閉じる)。
detach_anchor() {
  local ws="$1" cur="$2" gref anchor other
  gref=$(printf '%s' "${cur}" | jq -r '.ref')
  anchor=$(printf '%s' "${cur}" | jq -r '.anchor_workspace_ref')
  [[ "${anchor}" != "${ws}" ]] && return 0
  other=$(printf '%s' "${cur}" |
    jq -r --arg ws "${ws}" '[.member_workspace_refs[] | select(. != $ws)][0] // empty')
  if [[ -n "${other}" ]]; then
    cmux workspace-group set-anchor --group "${gref}" --workspace "${other}" >/dev/null 2>&1
  else
    cmux workspace-group ungroup "${gref}" >/dev/null 2>&1
  fi
}

reconcile() {
  local ws_list ws_json ws target ext_id name reason cur cur_ext cur_name dest changes=0
  ws_list=$(cmux workspace list --json 2>/dev/null) || {
    log "workspace list failed"
    return 0
  }
  refresh_groups || return 0

  while IFS= read -r -u 3 ws_json; do
    [[ -z "${ws_json}" ]] && continue
    ws=$(printf '%s' "${ws_json}" | jq -r '.ref')
    target=$(target_of "${ws_json}") || {
      log "${ws}: issue lookup failed, keep as is"
      continue
    }
    IFS=$'\t' read -r ext_id name reason <<<"${target}"

    cur=$(group_of "${ws}")
    cur_ext=""
    cur_name="-"
    if [[ -n "${cur}" ]]; then
      # cmux が作った仮のアンカーは動かさない (group の見出し専用の workspace)。
      if [[ "$(printf '%s' "${cur}" |
        jq -r --arg ws "${ws}" '.anchor_workspace_is_generated and .anchor_workspace_ref == $ws')" == "true" ]]; then
        continue
      fi
      cur_ext=$(printf '%s' "${cur}" | jq -r '.external_id // empty')
      cur_name=$(printf '%s' "${cur}" | jq -r '.name // "-"')
    fi

    if ((dry_run)); then
      printf '%s\t%s\t%s\n' "${ws}" "${cur_name}" "${name:--}"
      log "${ws}: ${reason}"
      continue
    fi

    if [[ -n "${ext_id}" && "${cur_ext}" == "${ext_id}" ]]; then
      if [[ "${cur_name}" != "${name}" ]]; then
        log "rename $(printf '%s' "${cur}" | jq -r '.ref') to ${name}"
        cmux workspace-group rename "$(printf '%s' "${cur}" | jq -r '.ref')" \
          --name "${name}" >/dev/null 2>&1 || log "rename failed"
        changes=$((changes + 1))
        refresh_groups || return 0
      fi
      continue
    fi
    [[ -z "${ext_id}" && -z "${cur}" ]] && continue

    log "${ws}: ${cur_name} -> ${name:--} (${reason})"
    changes=$((changes + 1))
    if [[ -n "${cur}" ]]; then
      detach_anchor "${ws}" "${cur}" || log "${ws}: detach failed"
      refresh_groups || return 0
    fi

    if [[ -z "${ext_id}" ]]; then
      if [[ -n "$(group_of "${ws}")" ]]; then
        cmux workspace-group remove --workspace "${ws}" >/dev/null 2>&1 ||
          log "${ws}: remove failed"
      fi
    else
      dest=$(group_by_external_id "${ext_id}")
      if [[ -n "${dest}" ]]; then
        cmux workspace-group add --group "${dest}" --workspace "${ws}" >/dev/null 2>&1 ||
          log "${ws}: add to ${dest} failed"
      else
        cmux workspace-group create --name "${name}" --from "${ws}" \
          --external-id "${ext_id}" >/dev/null 2>&1 ||
          log "${ws}: create ${name} failed"
      fi
    fi
    refresh_groups || return 0
  done 3< <(printf '%s' "${ws_list}" | jq -c '.workspaces[]?')

  ((dry_run)) || log "reconciled (${changes} changes)"
}

reconcile
((once)) && exit 0

cmux events \
  --category workspace \
  --no-ack --no-heartbeat \
  --cursor-file "${cursor_file}" \
  --reconnect --json |
  while IFS= read -r _line; do
    # 連続するイベント (自分の group 操作が出すものを含む) をまとめて 1 回にする。
    while IFS= read -r -t "${debounce_sec}" _line; do :; done
    reconcile </dev/null
  done
exit 0
