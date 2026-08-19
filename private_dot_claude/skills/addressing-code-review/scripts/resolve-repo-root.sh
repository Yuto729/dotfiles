#!/bin/bash
# Resolve the main checkout root of the repo the current working directory belongs to.
#
# Works correctly even when the cwd is inside a git worktree: `git rev-parse
# --git-common-dir` always points at the main repo's .git directory (shared
# across all worktrees), so its parent is the main checkout root regardless
# of where this script is invoked from.
#
# Usage: resolve-repo-root.sh
# Output (stdout): absolute path to the main repo root
# Exit code: non-zero if not inside a git repository.
set -euo pipefail

common_git_dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
  echo "Error: not inside a git repository" >&2
  exit 1
}

# git-common-dir may be relative to cwd; resolve to absolute path.
common_git_dir=$(cd "$(dirname "$common_git_dir")" && pwd)/$(basename "$common_git_dir")

dirname "$common_git_dir"
