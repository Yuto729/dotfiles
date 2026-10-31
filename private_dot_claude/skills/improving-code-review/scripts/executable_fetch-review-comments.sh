#!/bin/bash
# Fetch a PR's inline review comments, trimmed to what a triage/plan step
# actually needs: human-authored threads only, grouped by thread, with the
# diff_hunk dropped (it's the same few KB repeated on every reply in a
# thread — see path/line instead).
#
# This exists because `gh api .../pulls/<n>/comments` dumps every field
# (diff_hunk, node_id, _links, reactions, ...) and every bot comment
# (coderabbitai, etc.), which blows up context for no benefit when the task
# is "read what a human reviewer said."
#
# Usage: fetch-review-comments.sh <owner> <repo> <pr_number> [--include-bots]
#
# Output: JSON array of threads to stdout, each:
#   {
#     "path": "...",
#     "line": 92,
#     "root_comment_id": 3772966024,
#     "html_url": "https://github.com/.../pull/381#discussion_r...",
#     "comments": [
#       {"author": "reviewer-name", "created_at": "...", "body": "...", "html_url": "..."},
#       ...
#     ]
#   }
# Threads are sorted by path, then line. Within a thread, comments are in
# chronological order (root first, replies after).
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <owner> <repo> <pr_number> [--include-bots]" >&2
  exit 1
fi

OWNER="$1"
REPO="$2"
PR_NUMBER="$3"
INCLUDE_BOTS=false
if [ "${4:-}" = "--include-bots" ]; then
  INCLUDE_BOTS=true
fi

gh api --paginate "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/comments" | jq '
  map(select(
    (.user.login | test("\\[bot\\]|coderabbitai|github-actions|dependabot|copilot"; "i")) as $is_bot
    | if '"$INCLUDE_BOTS"' then true else ($is_bot | not) end
  ))
  | group_by(.in_reply_to_id // .id)
  | map(sort_by(.created_at))
  | map({
      path: .[0].path,
      line: (.[0].line // .[0].original_line),
      root_comment_id: (.[0].in_reply_to_id // .[0].id),
      html_url: .[0].html_url,
      comments: map({
        author: .user.login,
        created_at: .created_at,
        body: .body,
        html_url: .html_url
      })
    })
  | sort_by([.path, (.line // 0)])
'
