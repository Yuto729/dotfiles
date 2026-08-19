#!/bin/bash
# Resolve the review checklist path for the repo the current working directory belongs to.
#
# Works correctly even when the cwd is inside a git worktree: `git rev-parse
# --git-common-dir` always points at the main repo's .git directory (shared
# across all worktrees), so its parent is the main checkout root regardless
# of where this script is invoked from.
#
# Usage: resolve-checklist-path.sh
# Output (stdout): absolute path to <repo-root>/.claude/review-checklists/checklist.md
# Exit code: non-zero if not inside a git repository.
set -euo pipefail

common_git_dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
  echo "Error: not inside a git repository" >&2
  exit 1
}

# git-common-dir may be relative to cwd; resolve to absolute path.
common_git_dir=$(cd "$(dirname "$common_git_dir")" && pwd)/$(basename "$common_git_dir")

repo_root=$(dirname "$common_git_dir")

echo "$repo_root/.claude/review-checklists/checklist.md"
